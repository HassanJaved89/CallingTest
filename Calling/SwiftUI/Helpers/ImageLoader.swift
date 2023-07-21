//
//  ImageLoader.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/21/23.
//

import SwiftUI
import Kingfisher

struct ImageLoader: View {
    
    var url: URL?
    
    
    
    var body: some View {
        KFImage(url)
            .placeholder {
                ProgressView()
        }
            .resizable()
    }
}

/*
struct ImageLoader_Previews: PreviewProvider {
    static var previews: some View {
        ImageLoader()
    }
}*/
