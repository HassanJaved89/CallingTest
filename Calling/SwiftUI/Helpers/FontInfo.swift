//
//  FontInfo.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/12/23.
//

import Foundation
import SwiftUI

enum CustomFontSize: CGFloat {
    case small = 14
    case medium = 16
    case large = 20
    case extraLarge = 30
    case xxLarge = 50
}

extension Font {
    static func customFont(size: CustomFontSize) -> Font {
        return .system(size: size.rawValue)
    }
}

enum AppColors {
    case greenColor
    case redColor
    case redLower
    
    var color: Color {
        switch self {
        case .greenColor:
            return Color(hex: "#01411C") ?? .green
            
        case .redColor:
            return Color(hex: "#F31816") ?? .red
            
        case .redLower:
            return Color(hex: "#F8472C") ?? .red
        }
        
    }
}
