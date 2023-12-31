//
//  CallsView.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/24/23.
//

import SwiftUI

struct CallsView: View {
    
    @State private var searchText = ""
    @State private var isCallingViewPresented = false
    @State private var selectedCallObject: Call = Call(user: ChatUser(data: [:]), timestamp: Date(), status: .Accepted, type: .Outgoing)
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm: CallsViewModel
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                
                ForEach(vm.calls.filter {
                    searchText.isEmpty || $0.user.userName.localizedCaseInsensitiveContains(searchText)
                } ) { call in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            showCallRow(call: call)
                        }
                        .frame(minHeight: 60)
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)

                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedCallObject, perform: { newValue in
            isCallingViewPresented = true
        })
        .fullScreenCover(isPresented: $isCallingViewPresented, content: {
            AgoraRep(presentationMode: $isCallingViewPresented).frame(maxWidth: .infinity, maxHeight: .infinity)
                .onDisappear {
                    isCallingViewPresented = false
                }
        })
        .onChange(of: isCallingViewPresented, perform: { newValue in
            if newValue {
                Task {
                    vm.sendCall(call: selectedCallObject)
                }
            }
        })
        .onAppear {
            //vm.fetch()
        }
        .searchable(text: $searchText)
    }
    
    
    @ViewBuilder
    func showCallRow(call: Call) -> some View {
        
        ImageLoader(url: URL(string: call.user.profileImageUrl))
            .scaledToFill()
            .frame(width: 50, height: 50)
            .clipped()
            .cornerRadius(50)
            .overlay(RoundedRectangle(cornerRadius: 50)
            .stroke(Color(.label), lineWidth: 2)
            )
        
        VStack(alignment: .leading, spacing: 10) {
            Text(call.user.userName)
                .foregroundColor(call.status == .Accepted ? Color(.label) : .red)
                .font(.customFont(size: .large))
            
            HStack {
                Button {
                    
                } label: {
                    Image("PhoneIcon")
                        .font(.customFont(size: .small))
                        .tint(call.status == .Accepted ? Color(.label).opacity(0.5) : .red)
                }
                
                Text(call.status == .Accepted ? call.type.description : CallStatus.Missed.description)
                    .font(.customFont(size: .small))
                    .foregroundColor(call.status == .Accepted ? Color(.label).opacity(0.5) : .red)
            }
            
        }
        
        
        Spacer()
        
        VStack(alignment: .trailing) {
            Text(call.timeAgo)
                .font(.customFont(size: .small))
            
            Button {
                selectedCallObject = call
            } label: {
                Image("CallButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
        }
        
    }
}

/*
struct CallsView_Previews: PreviewProvider {
    static var previews: some View {
        CallsView()
    }
}*/
