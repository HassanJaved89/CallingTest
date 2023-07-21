//
//  HelperFunctions.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/21/23.
//

import Foundation

extension Date {
    
    func convertToTime() -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: self)
    }
}
