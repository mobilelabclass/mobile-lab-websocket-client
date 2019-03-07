//
//  GamePiece.swift
//  mobile-lab-websocket-client
//
//  Created by Sebastian Buys on 3/6/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

import Foundation
import UIKit

protocol GamePiece {
    var center: CGPoint { get }
    var radius: CGFloat { get }
    var color: UIColor { get }
}
