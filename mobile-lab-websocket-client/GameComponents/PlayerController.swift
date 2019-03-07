//
//  PlayerController.swift
//  mobile-lab-websocket-client
//
//  Created by Sebastian Buys on 3/7/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

import Foundation

class PlayerController {
    enum MovementAxis {
        case x, y
    }
    
    // Give ourselves a guaranteed unique id
    var id = UUID().uuidString
    
    var currentPosition: (row: Int, col: Int)?
    var targetPosition: (row: Int, col: Int)?
    
    // We want to move in a fun zig zag, so we'll use
    
    func getNextMove() -> Direction? {
        // If we don't have a currentPosition or targetPosition, we can't determine the next move
        guard let currentPosition = currentPosition,
            let targetPosition = targetPosition else { return nil }
        
        let deltaCol = targetPosition.col - currentPosition.col
        let deltaRow = targetPosition.row - currentPosition.row
       
        
        // We'll just use a simple rule for movement
        // First move in the X axis (across columns), then move in the Y axis (across rows)
        // Make threshold 1 instead of 0 to prevent bouncing around
        
        if deltaCol > 1 {
            return Direction.right
        }
        
        if deltaCol < -1 {
            return Direction.left
        }
        
        if deltaRow > 1 {
            return Direction.down
        }
        
        if deltaRow < -1 {
            return Direction.up
        }
        
        // Return nil if deltaCol is 0, deltaRow is 0
        // We're on the target so we don't have a next move
        // Remove target position so we don't bounce back and forth
        self.targetPosition = nil
        return nil
    }
}
