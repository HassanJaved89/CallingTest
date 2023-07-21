//
//  MainMessagesView.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/5/23.
//

import SwiftUI
import Kingfisher

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldShowNewMessageScreen = false
    @State var shouldNavigateToChatLogView = false
    @State var chatUser: ChatUser
    @ObservedObject var chatLogViewModel: ChatLogViewModel
    @State private var searchText = ""
    @ObservedObject var vm: MainMessagesViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            //customNavBar
            CustomSearchBar(searchText: $searchText)
            messagesView
            
            NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                ChatLogView(vm: chatLogViewModel)
                    .navigationTitle(chatLogViewModel.chatParticipants.count > 0 ? chatLogViewModel.chatParticipants[0].userName : "")
            }
        }
        .padding(.top, 25)
        .overlay(
            newMessageButton, alignment: .bottomTrailing)
        .padding(.horizontal)
    }
    
    private var customNavBar: some View {
        
        HStack(spacing: 16) {
            
            ImageLoader(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
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
            ForEach(vm.recentMessages.filter {
                searchText.isEmpty || $0.userName.localizedCaseInsensitiveContains(searchText)
            } ) { recentMessage in
                VStack {
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                        self.chatUser = .init(data: [FirebaseConstants.userName: recentMessage.userName, FirebaseConstants.profileImageUrl: recentMessage.profileImageUrl, FirebaseConstants.uid: uid])
                        self.chatLogViewModel.chatParticipants.insert(self.chatUser, at: 0)
                        self.chatLogViewModel.fetch()
                        self.shouldNavigateToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 16) {
                            
                            ImageLoader(url: URL(string: recentMessage.profileImageUrl))
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                            .stroke(Color.black, lineWidth: 1))
                                .shadow(radius: 5)
                            
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.userName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.label))
                                    .multilineTextAlignment(.leading)
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text(recentMessage.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.label))
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
            Image("add")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 64, maxHeight: 64)
                .clipped()
            /*
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
                .shadow(radius: 15)*/
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
                self.chatLogViewModel.chatParticipants.insert(user, at: 0)
                self.chatLogViewModel.fetch()
            }
        }
    }
}
