//
//  GamePiece.swift
//  mobile-lab-websocket-client
//
//  Created by Sebastian Buys on 3/6/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

import Foundation
import UIKit

// <T:ProtocolWithAlias>

class GamePieceView: UIView {
    var piece: GamePiece!
    
    func updateAppearance() {
        let radius = piece.radius
        let center = piece.center
        
        // Style
        self.frame.size = CGSize(width: radius * 2, height: radius * 2)
        self.layer.cornerRadius = radius
        self.backgroundColor = piece.color
        
        // Position
        self.center = center
    }
    
    init(with piece: GamePiece) {
        // Initialize with empty frame.
        // We'll use x and y (center) to position the view manually instead
        // using the view's center property
        super.init(frame: .zero)
        
        self.piece = piece
        
        updateAppearance()
        
        // Clip appearance to corner radius
        self.clipsToBounds = true
    }
    
    // Required function for initializing from storyboard
    // Since we won't use storyboards for this view, we just error out
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
