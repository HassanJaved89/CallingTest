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
