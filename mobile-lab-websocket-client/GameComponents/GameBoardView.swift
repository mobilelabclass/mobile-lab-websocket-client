//
//  GameBoardView.swift
//  mobile-lab-websocket-client
//
//  Created by Sebastian Buys on 3/6/19.
//  Copyright © 2019 Sebastian Buys. All rights reserved.
//

import Foundation
import UIKit

class GameBoardView: UIView {
    // Number of columns and rows
    // UIKit is smart enough to not redraw the view unless necessary.
    // We need to let the view know that it should redraw when the number of columns or rows change
    // didSet is a property observer
//
    var columns: Int = 96 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var rows: Int = 54 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIColor.black.setFill()
        let fillPath = CGPath(rect: rect, transform: nil)
        let fillbezierPath = UIBezierPath(cgPath: fillPath)
        fillbezierPath.fill()
        
        let totalWidth = rect.width
        let totalHeight = rect.height
        
        let cellWidth = totalWidth / CGFloat(columns)
        let cellHeight = totalHeight / CGFloat(rows)
        
        UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).setStroke() // update with correct color
        
        let gridLinesPath = UIBezierPath()
        // Divide our desired stroke by the screen scale (e.g. retina)
        gridLinesPath.lineWidth = 1.0 / UIScreen.main.scale
        
        
        // Draw vertical lines
        for columnIndex in 0...columns {
            let p1 = CGPoint(x: CGFloat(columnIndex) * cellWidth, y: 0.0)
            let p2 = CGPoint(x: CGFloat(columnIndex) * cellWidth, y: totalHeight)
            gridLinesPath.move(to: p1)
            gridLinesPath.addLine(to: p2)
        }
        
        // Draw horizontal lines
        for rowIndex in 0...rows {
            let p1 = CGPoint(x: 0.0, y: CGFloat(rowIndex) * cellHeight)
            let p2 = CGPoint(x: totalWidth, y: CGFloat(rowIndex) * cellHeight)
            gridLinesPath.move(to: p1)
            gridLinesPath.addLine(to: p2)
        }
        
        gridLinesPath.stroke()
    }
}
