//
//  CreateAccount.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/4/23.
//

import SwiftUI

struct AccountSettings: View {
    
    @State var userName: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Button {
                
            } label: {
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .padding()
                    .background {
                        Circle()
                            .stroke(lineWidth: 2)
                    }
            }
            
            VStack {
                TextField("Username", text: $userName)
                Rectangle().fill(Color.blue)
                    .frame(height: 1)
            }
            .padding()
            
            Button {
                
            } label: {
                HStack {
                    Text("Create")
                        .frame(maxWidth: .infinity, maxHeight: 45)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .padding()
                }
                
            }
            

            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .padding(.vertical, 50)
        
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettings()
    }
}
