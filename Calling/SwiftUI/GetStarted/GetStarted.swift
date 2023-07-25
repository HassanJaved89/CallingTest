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
                .aspectRatio(contentMode: .fill)
                //.scaledToFit()
                //.scaledToFill()
                .ignoresSafeArea()
                .overlay {
                    Color.black.opacity(0.3)
                }
            
            VStack {
                if isShowingView {
                    VStack(spacing: 20) {
                        HStack {
                            Image("MinistryImage", bundle: nil)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text("MINISTRY OF INFORMATION AND BROADCASTING")
                                    .fixedSize(horizontal: false, vertical: true)
                                Divider()
                                    .tint(.white)
                                Text("Government of Pakistan")
                            }
                            .foregroundColor(.white)
                            .font(.customFont(size: .medium))
                        }
                        .padding(.top, 120)
                        
                        Text("Connect with your colleagues securely")
                            .foregroundColor(.white)
                            .font(.customFont(size: .xxLarge))
                            //.padding(.top, 10)
                        
                        Text("Our chat app is the perfect way to securely connect with your business contacts")
                            .foregroundColor(.white)
                            .font(.customFont(size: .large))
                            //.padding(.top, 5)
                        
                        Spacer()
                        
                        Button {
                            navigateToNextScreen = true
                        } label: {
                            Text("Get Started")
                        }
                        .buttonStyle(GradientButtonStyle())
                        .padding(.bottom, 10)

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
