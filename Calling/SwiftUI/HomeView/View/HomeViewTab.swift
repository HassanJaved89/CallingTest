//
//  HomeViewTab.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/13/23.
//

import SwiftUI

struct HomeViewTab: View {
    @State private var selectedTab = 0
    @ObservedObject var vm = MainMessagesViewModel()
    @ObservedObject var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    @ObservedObject var accountSettingsVm = AccountSettingsViewModel()
    @ObservedObject var groupsViewModel = GroupsViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainMessagesView(chatUser: ChatUser(data: ["" : ""]), chatLogViewModel: chatLogViewModel, vm: vm)
                .tabItem {
                    Image("Message")
                    Text("Chats")
                }
                .tag(0)
            
            Text("Calls")
                .tabItem {
                    Image("Calls")
                    Text("Calls")
                }
                .tag(1)
            
            GroupsView(groupsViewModel: groupsViewModel)
                .tabItem {
                    Image("Groups")
                    Text("Groups")
                }
                .tag(2)
            
            AccountSettings(accountSettingsVm: accountSettingsVm)
                .tabItem {
                    Image("Settings")
                    Text("Settings")
                }
                .tag(3)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                VStack {
                    Image("MinistryImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40, alignment: .leading)
                }
                .padding(.top, 5)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                VStack {
                    AsyncImage(url: URL(string: vm.chatUser?.profileImageUrl ?? "")) { returnedImage in
                        returnedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipped()
                            .cornerRadius(40)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                            )
                            .shadow(radius: 5)
                    } placeholder: {
                        ProgressView()
                    }
                }
                .padding(.top, 5)
            }
        }
        .navigationBarHidden(false)
        .navigationTitle(titleForSelectedTab(selectedTab))
        .navigationBarTitleDisplayMode(.inline)
        .font(.customFont(size: .medium))
        .tint(AppColors.greenColor.color)
        .edgesIgnoringSafeArea(.all)
    }
    
    func titleForSelectedTab(_ selectedTab: Int) -> String {
        switch selectedTab {
        case 0:
            return "Chats"
        case 1:
            return "Calls"
        case 2:
            return "Groups"
        case 3:
            return "Settings"
        default:
            return ""
        }
    }
}

struct HomeViewTab_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewTab()
    }
}
