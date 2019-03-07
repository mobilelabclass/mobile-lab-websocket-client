//
//  GameBoardViewController.swift
//  mobile-lab-websocket-client
//
//  Created by Sebastian Buys on 3/6/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

// Constants
let Columns = 96
let Rows = 54

import Foundation
import UIKit

// We write our own delegate protocol
// The primary view controller adopts the protocol
// give the protocol a class type, meaning only instances of classes can adopt

// We would normally put this in a separate file, but we'll keep it here for clarity
protocol GameBoardViewControllerDelegate: class {
    func gameboardDidReceiveTapAt(col: Int, row: Int)
}

class GameBoardViewController: UIViewController {
    // The delegate needs to be labeled weak
    // so that we don't accidentaly create a retain cycle and leak memory
    weak var delegate: GameBoardViewControllerDelegate?
    
    // A lazy variable is created when it is first accessed.
    lazy var tapRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    }()
    
    func updatePickups(_ pickups: [PickupGamePiece]) {
        let newViews: [GamePieceView] = pickups.map {
            GamePieceView(with: $0)
        }
        
        for newView in newViews {
            self.view.addSubview(newView)
        }
    }
    
    func updatePlayers(_ players: [PlayerGamePiece]) {
        let newViews: [GamePieceView] = players.map {
            GamePieceView(with: $0)
        }
        
        for newView in newViews {
            self.view.addSubview(newView)
        }
    }
    
    func clearGamePieces() {
        for view in self.view.subviews.filter({ $0 is GamePieceView }) {
            view.removeFromSuperview()
        }
    }
    
    // GameBoardViewController will use custom view
    override func loadView() {
        self.view = GameBoardView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tapGestureRecognizer to view
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK - Helper functions
    // Calculate size of individual cell
    var cellSize: CGSize {
        let width = view.bounds.width
        let height = view.bounds.height
        return CGSize(width: width / CGFloat(Columns), height: height / CGFloat(Rows))
    }
    
    // Calculate row, col from X, Y location in view
    func calculateGridLocation(from viewLocation: CGPoint) -> (col: Int, row: Int) {
        let width = view.bounds.width
        let height = view.bounds.height
        let col = Int(floor(viewLocation.x / width * CGFloat(Columns)))
        let row = Int(floor(viewLocation.y / height * CGFloat(Rows)))
        return (col: col, row: row)
    }
    
    
    // Calculate X, Y (CENTER POINT) from col, row
    func calculateViewLocation(from col: CGFloat, row: CGFloat) -> CGPoint {
        return CGPoint(x: self.cellSize.width * col + 0.5,
                       y: self.cellSize.height * row + 0.5)
    }
    
    // MARK - Gesture handling
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        let viewLocation = sender.location(in: self.view)
        
        // Example of tuple destructuring
        let (col, row) = calculateGridLocation(from: viewLocation)
        print("User tapped at location: \(col), \(row)")
        
        // Let our delegate know about the tap
        self.delegate?.gameboardDidReceiveTapAt(col: col, row: row)
    }
}


