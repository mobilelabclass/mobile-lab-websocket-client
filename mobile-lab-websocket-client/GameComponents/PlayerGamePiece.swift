//
//  PlayerGamePiece.swift
//  mobile-lab-websocket-client
//
//  Created by Sebastian Buys on 3/6/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

import Foundation
import UIKit

struct PlayerGamePiece: GamePiece {
    var center: CGPoint
    var color: UIColor
    var radius: CGFloat
    var score: Int
    var id: String
}
