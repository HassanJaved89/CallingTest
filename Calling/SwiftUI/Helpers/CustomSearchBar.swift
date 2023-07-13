//
//  CustomSearchBar.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/13/23.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    TextField("Search", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.customFont(size: .large))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                }
            }
            .frame(height: 50)
            .padding(.horizontal)
        }
}
