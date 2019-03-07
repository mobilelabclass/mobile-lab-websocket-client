//
//  ScoreboardCollectionViewCell.swift
//  mobile-lab-websocket-client
//
//  Created by Sebastian Buys on 3/7/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

import Foundation
import UIKit

class ScoreboardCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier = "ScoreboardCollectionViewCell"
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
}
