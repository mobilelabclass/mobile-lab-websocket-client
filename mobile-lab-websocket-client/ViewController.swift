//
//  ViewController.swift
//  mobile-lab-websocket-client
//
//  Created by Sebastian Buys on 3/4/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

import UIKit
import Starscream

enum Direction: String {
    case up = "0"
    case right = "1"
    case down = "2"
    case left = "3"
}

enum GodModeCommand: String {
    case playPause = "p"
    case reset = "r"
}

class ViewController: UIViewController, WebSocketDelegate, GameBoardViewControllerDelegate {
    private var gameboardViewController: GameBoardViewController?
    private var scoreboardViewController: ScoreboardCollectionViewController?
    
    // Object for managing the web socket.
    var socket: WebSocket?
    
    // PlayerController manages our player movement logic
    let playerController = PlayerController()
    
    // GodMode buttons
    @IBAction func didTapPlayPause(_ sender: Any) {
        self.sendGodModeMessage(.playPause)
    }
    
    @IBAction func didTapReset(_ sender: Any) {
        self.sendGodModeMessage(.reset)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get contained view controller
        // First search through all child view controllers for an instance of GameBoardViewController
        // Then cast with "as?"
        // Throw an error if we are unable to find.
        
        // Another approach for getting the contained view controller is in prepareForSegue
        guard let gameboardViewController = (children.filter {
            $0 is GameBoardViewController
        }.first as? GameBoardViewController) else {
            fatalError("Could not find gameboard view controller in children")
        }
        
        // Assign self as delegate to receive tap events
        gameboardViewController.delegate = self
        
        // Assign reference
        self.gameboardViewController = gameboardViewController
        
        // Get contained scoreboard view controller
        guard let scoreboardViewController = (children.filter {
            $0 is ScoreboardCollectionViewController
            }.first as? ScoreboardCollectionViewController) else {
                fatalError("Could not find scoreboard collectionview controller in children")
        }
        
        self.scoreboardViewController = scoreboardViewController
        
        // URL of the websocket server.
        let urlString = "wss://gameserver.mobilelabclass.com"
        
        // Create a WebSocket.
        socket = WebSocket(url: URL(string: urlString)!)
        
        
        // Assign WebSocket delegate to self
        socket?.delegate = self
        
        // Connect.
        socket?.connect()
        
        // Assigning notifications to handle when the app becomes active or inactive.
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - WebSocket delegate methods and helper functions
    func websocketDidConnect(socket: WebSocketClient) {
        print("✅ Connected")
        
        // Send an initial command to the server so we can start our movement logic
        sendDirectionMessage(.up)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("🛑 Disconnected:", error ?? "No message")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        // print("⬇️ websocket did receive message:", text)
        self.process(text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // print("<<< Received data:", data)
    }
    
    func sendDirectionMessage(_ code: Direction) {
        // Get the raw string value from the Direction enum
        // that we created at the top of this program.
        sendMessage("\(playerController.id), \(code.rawValue)")
    }
    
    func sendGodModeMessage(_ code: GodModeCommand) {
        // Get the raw string value from the Direction enum
        // that we created at the top of this program.
        sendMessage(code.rawValue)
    }
    
    func sendMessage(_ message: String) {
        socket?.write(string: message) {
            // This is a completion block.
            // We can write custom code here that will run once the message is sent.
            print("⬆️ sent message to server: ", message)
        }
    }
    
    // Parse the received message payload
    // Update the gameboard and scoreboard
    func process(_ message: String) {
        // Parsing manually by hand.
        // In production -> better to use a library like swiftyjson
        guard let json = message.toJSON() as? [String : Any] else {
            print("Error parsing json")
            return
        }
        
        // See Parse.swift file for function definitions
        let pickups  = parsePickups(from: json)
        let players = parsePlayers(from: json)
        
        gameboardViewController?.clearGamePieces()
        gameboardViewController?.updatePickups(pickups)
        gameboardViewController?.updatePlayers(players)
        scoreboardViewController?.updatePlayers(players)
        
        // Look for ourself in the players array
        // the id of the player should match the id stored in playerController
        
        guard let myServerState = (players.first { $0.id == playerController.id }) else { return }

        // Update player controller with current state
        let gridPosition = gameboardViewController!.calculateGridLocation(from: myServerState.center)
        
        playerController.currentPosition = (row: gridPosition.row, col: gridPosition.col)
        
        // Get next move calculated by playerController
        if let nextMove = playerController.getNextMove() {
            sendDirectionMessage(nextMove)
        }
    }
    
    // MARK: - Parsing utilities
    func parsePickups(from dictionary: [String : Any]) -> [PickupGamePiece] {
        guard let pickups = dictionary["pickups"] as? [[String: Int]] else {
            print("Error parsing pickups")
            return []
        }
        
        return pickups.compactMap { pickup -> PickupGamePiece? in
            guard let x = pickup["x"] else { return nil }
            guard let y = pickup["y"] else { return nil }
            
            let pixelPosition = gameboardViewController!
                .calculateViewLocation(from: CGFloat(x), row: CGFloat(y))
            
            return PickupGamePiece(center: CGPoint(x: pixelPosition.x, y: pixelPosition.y),
                                   radius: gameboardViewController!.cellSize.width / 2.0,
                                   color: .white)
        }
    }
    
    func parsePlayers(from dictionary: [String : Any]) -> [PlayerGamePiece] {
        //         Players shape:
        //        "players": {
        //            Hotshot =     {
        //                color = "#15ff05";
        //                direction = 0;
        //                id = Hotshot;
        //                image = "<null>";
        //                pts = 1;
        //                size = "1.1";
        //                speed = "0.95";
        //                time = 1551926041617;
        //                x = "85.97500000000011";
        //                y = 0;
        //            };
        //        }]
        
        guard let players = dictionary["players"] as? [String: [String : Any]] else {
            print("Error parsing players")
            return []
        }
        
        return players.compactMap { player -> PlayerGamePiece? in
            let value = player.value
            
            guard let size = value["size"] as? CGFloat else {
                print("Error parsing player size")
                return nil
            }
            
            guard let color = value["color"] as? String else {
                print("Error parsing player color")
                return nil
            }
            
            guard let x = value["x"] as? CGFloat else {
                print("Error parsing player x coordinate ")
                return nil
            }
            
            guard let y = value["y"] as? CGFloat else {
                print("Error parsing player y coordinate ")
                return nil
            }
            
            guard let score = value["pts"] as? Int else {
                print("Error parsing player score ")
                return nil
            }
            
            guard let id = value["id"] as? String else {
                print("Error parsing player id ")
                return nil
            }
            
            
            let pixelPosition = gameboardViewController!
                .calculateViewLocation(from: x, row: y)
            
            return PlayerGamePiece(center: CGPoint(x: pixelPosition.x, y: pixelPosition.y),
                                   color: hexStringToUIColor(hex: color),
                                   radius: gameboardViewController!.cellSize.width * size / 2.0,
                                   score: score,
                                   id: id)
        }
    }

    
    // MARK: - GameBoardViewControllerDelegate methods
    func gameboardDidReceiveTapAt(col: Int, row: Int) {
        // On tap, update our target destination
        print(col, row)
        playerController.targetPosition = (row: row, col: col)
    }
    
    @objc func willResignActive() {
        print("💡 Application will resign active. Disconnecting socket.")
        socket?.disconnect()
    }
    
    @objc func didBecomeActive() {
        print("💡 Application did become active. Connecting socket.")
        socket?.connect()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
}
