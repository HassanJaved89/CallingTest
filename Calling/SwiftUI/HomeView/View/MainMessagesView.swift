//
//  MainMessagesView.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/5/23.
//

import SwiftUI

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldShowNewMessageScreen = false
    @State var shouldShowChatLogScreen = false
    @State var chatUser: ChatUser
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        VStack {
            customNavBar
            messagesView
            
            NavigationLink("", destination: ChatLogView(chatUser: self.chatUser), isActive: $shouldShowChatLogScreen)
        }
        .navigationBarHidden(true)
        .overlay(
            newMessageButton, alignment: .bottom)
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            AsyncImage(url: URL(string: vm.chatUser?.profileImageUrl ?? "")) { returnedImage in
                                returnedImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .cornerRadius(50)
                                    .overlay(RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                                    )
                                    .shadow(radius: 5)
                            } placeholder: {
                                ProgressView()
                            }
            
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(vm.chatUser?.userName ?? "")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    vm.signOut()
                }),
                    .cancel()
            ])
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    NavigationLink {
                        Text("Destination")
                    } label: {
                        HStack(spacing: 16) {
                            
                            AsyncImage(url: URL(string: recentMessage.profileImageUrl ?? "")) { returnedImage in
                                                returnedImage
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 64, height: 64)
                                                    .clipped()
                                                    .cornerRadius(64)
                                                    .overlay(RoundedRectangle(cornerRadius: 64)
                                                                .stroke(Color.black, lineWidth: 1))
                                                    .shadow(radius: 5)
                                            } placeholder: {
                                                ProgressView()
                                            }
                            
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.userName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }

                    
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }
    }
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen = true
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                self.chatUser = user
                self.shouldShowChatLogScreen.toggle()
            }
        }
    }
}
