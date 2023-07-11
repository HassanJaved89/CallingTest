//
//  GetStarted.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/11/23.
//

import SwiftUI

struct GetStarted: View {
    var body: some View {
        ZStack(alignment: .top) {
            Image("GetStartedBackgroundImage", bundle: nil)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                
                HStack {
                    Image("MinistryImage", bundle: nil)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("MINISTRY OF INFORMATION AND BROADCASTING")
                        Divider()
                        Text("Government of Pakistan")
                    }
                    .foregroundColor(.black)
                    .font(.system(size: 16))
                }
                .padding(.top, 125)
                
                Text("Connect with your colleagues securely")
                    .foregroundColor(.white)
                    .font(.system(size: 50))
                    .padding(.top, 30)
                
                Text("Our chat app is the perfect way to securely connect with your business contacts")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .padding(.top, 30)
                
                Button {
                    
                } label: {
                    Text("Get Started")
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.green)
                                .frame(width: 300, height: 50)
                                
                        }
                }
                .padding(.top, 30)

                
                Spacer()
            }
            .padding()
            
        }
    }
}

struct GetStarted_Previews: PreviewProvider {
    static var previews: some View {
        GetStarted()
    }
}
