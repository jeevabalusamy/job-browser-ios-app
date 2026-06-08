//
//  JBSystemImage.swift
//  JobBrowser
//
//  Created by Jeeva Balusamy on 08/06/26.
//

import Foundation

enum JBSystemImage: String {
    case building = "building.2.crop.circle"
    case location = "mappin.and.ellipse"
    case salary = "banknote"
    case externalLink = "arrow.up.right.square"
    case warning = "exclamationmark.triangle"
    
    var name: String {
        self.rawValue
    }
}
