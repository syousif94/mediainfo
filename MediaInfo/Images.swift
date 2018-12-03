//
//  Images.swift
//  MediaInfo
//
//  Created by Sammy Yousif on 11/25/18.
//  Copyright © 2018 Sammy Yousif. All rights reserved.
//

import Foundation

let pauseIcon = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAUNJREFUWAntWcENgkAQ5KyAEiyBDixBS7AD7cRYgbRgBcYKpAQ7kA5w5nATvIC3uDHxsZuMwN3sMI77OkPXdUUIoRjUFvcrYAmk1WLhCtQA7+dUCfIWoDbv07pjQbTjHr0V8aOnsukCYDWLBzgVoC1y2aPRpof4BVKDB6WAvIQvjEK4fipytOZEm1768F4JUkQ251z3FMoUOXM0hVvS2+IlXmVeMrXNL5YrDWdMI3oSg2OEv1hzg9afwRP0BK0JWPt9Bj1BawLWfp9BT9CagLXfZ9ATtCZg7fcZ9AStCVj7fQY9QWsC1n6fQU/QmoC1X2aw+VKoVfRpOGMyvafBGfUJLDnd1Fx/eQRML29HwHwugRvXFaC5DaAtctmj0aYHeokGAxMc+RtiLSQSk2rwfATuyXrucQnCDqgmiC3Wz0At+/T2BMp1tCdh7M06AAAAAElFTkSuQmCC"

let playIcon = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAfVJREFUWAnN2A1xgzAYxvEyBZOAhEpAwiQgoRLqoHPAHOymAAmTgITNAXvetu//GBtpKIQ0d2/78HHNryFJb9v1fb+zuraD3lvVSVWpsjVchAvKpMNqdFzmUOIi/IYNkZZtRJ+3hOIihIGG/FIdVZtAcRFuA31UOyFrVdKGixAPdOinhFUqJS7CfKBDWyH3a0NxEe4HOrQRcrX5iYuwHGhQX0iLBxQXYR2gj2YnYb1EiYuwLtChrZDVPVBchDRAhzZClnOguAhpgQb1+Rm1kHAR0gN9NDth61ujiYuwHdChrZDVFBQXYXugQxshyzEUFyEf0KB/5icuQl6gj2Yn7IuNJi7CYwAdenRXYcFaURSXcD7K/yJXYYqn/JSw4FGBr7D9WeuEP/+c776aH3KRNBokfgYZOEK+EWwF2/NIrwEXYXtgJ8t5zxvj7BgXYTugzbPDf6jhOVyEbYAnIZhnQ9A44yKkBdo8K8eI0DEuQhqgzbMqBJm6houwLtDmWT3Vecx5XIR1gL7RRs2zEBQXYTmwUYdlqNM513AR7gfaAqjmdB5zLy7CfKAtgMmNNgYRugcXIR4YtdGGOo+5hosQB4zeaGMQoXtwEcLAd31YGfrAta/hIlz+u9+ro2ElWQAxX8Zdw79JbO+yR1iqvlUfqjdVlmZAaz9ZBZBbxkMtpAAAAABJRU5ErkJggg=="

extension NSImage {
    var base64String: String? {
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
            ) else {
                print("Couldn't create bitmap representation")
                return nil
        }
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        draw(at: NSZeroPoint, from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        guard let data = rep.representation(using: NSBitmapImageRep.FileType.png, properties: [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]) else {
            print("Couldn't create PNG")
            return nil
        }
        
        return data.base64EncodedString(options: [])
    }
}
