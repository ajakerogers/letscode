//
//  Item.swift
//  LetsCode
//
//  Created by ProCoder123 Rogers on 11/8/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
