//
//  ScoreboardCollectionViewController.swift
//  mobile-lab-websocket-client
//
//  Created by Sebastian Buys on 3/6/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

import Foundation
import UIKit

class ScoreboardCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var players: [PlayerGamePiece] = []
    
    func updatePlayers(_ players: [PlayerGamePiece]) {
        // Sort players by score
        self.players = players.sorted(by: { (a, b) -> Bool in
            a.score > b.score
        })
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScoreboardCollectionViewCell.reuseIdentifier, for: indexPath)
        
        // Get player data
        let player = players[indexPath.row]
        
        if let cell = cell as? ScoreboardCollectionViewCell {
            cell.backgroundColor = player.color
            cell.idLabel.text = player.id
            cell.scoreLabel.text = "\(player.score)"
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.height
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0.0, height: 0.0)
    }
}
