//
//  GetStarted.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/11/23.
//

import SwiftUI

struct GetStarted: View {
    
    @State private var navigateToNextScreen = false
    @State private var isShowingView = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Image("GetStartedBackgroundImage", bundle: nil)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay {
                    Color.black.opacity(0.3)
                }
            
            VStack(alignment: .leading) {
                if isShowingView {
                    VStack {
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
                            .font(.customFont(size: .medium))
                        }
                        .padding(.top, 120)
                        
                        Text("Connect with your colleagues securely")
                            .foregroundColor(.white)
                            .font(.customFont(size: .xxLarge))
                            .padding(.top, 30)
                        
                        Text("Our chat app is the perfect way to securely connect with your business contacts")
                            .foregroundColor(.white)
                            .font(.customFont(size: .large))
                            .padding(.top, 30)
                        
                        Button {
                            navigateToNextScreen = true
                        } label: {
                            Text("Get Started")
                        }
                        .buttonStyle(GradientButtonStyle())
                        .padding(.top, 40)

                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                }
            }
            .padding()
        }
        .background {
            NavigationLink(destination: Login(), isActive: $navigateToNextScreen) {}
        }
        .onAppear {
            withAnimation(.spring(response: 1.0)) {
                isShowingView = true
            }
        }
    }
}

struct GetStarted_Previews: PreviewProvider {
    static var previews: some View {
        GetStarted()
    }
}
