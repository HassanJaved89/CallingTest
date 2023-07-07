//
//  ChatLogScreen.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/6/23.
//

import SwiftUI

struct ChatLogView: View {
    
    @ObservedObject var vm: ChatLogViewModel
    @State private var showImagePicker = false
    @State private var isSheetPresented = false
    @State var selectedImage: UIImage?
    static let emptyScrollToString = "Empty"
    
    var body: some View {
        ZStack {
            messagesView
            Text(vm.errorMessage)
        }
        .navigationTitle(vm.chatUser?.userName ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                self.vm.viewScreenRemoved()
        }
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                DispatchQueue.main.async {
                    selectedImage = image
                    isSheetPresented = true
                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            if let image = selectedImage {
                SelectedImageView(image: image) { image in
                    DispatchQueue.main.async {
                        isSheetPresented = false
                        vm.sendImage(image: image)
                    }
                }
            }
        }
    }
    
    func loadImage() {
        guard selectedImage != nil else { return }
        isSheetPresented = true
    }
    
    struct SelectedImageView: View {
        var image: UIImage
        var handleSend: (UIImage) -> ()
        
        var body: some View {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .navigationBarTitleDisplayMode(.inline)
                
                Spacer()
                
                Button {
                    handleSend(image)
                } label: {
                    Text("Send")
                        .frame(width: 80, height: 30)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .font(.title3)
                        .cornerRadius(20)
                        
                }
                .padding()
            }
            
        }
    }
    
    private var messagesView: some View {
        VStack {
            if #available(iOS 15.0, *) {
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack {
                            ForEach(vm.chatMessages) { message in
                                MessageView(message: message)
                            }
                            
                            HStack{ Spacer() }
                            .id(Self.emptyScrollToString)
                        }
                        .onReceive(vm.$count) { _ in
                            withAnimation(.easeOut(duration: 1.0)) {
                                scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                            }
                            
                        }
                        
                    }
                    
                }
                .background(Color(.init(white: 0.95, alpha: 1)))
                .safeAreaInset(edge: .bottom) {
                    chatBottomBar
                        .background(Color(.systemBackground).ignoresSafeArea())
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Button {
                showImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
            }
            
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                vm.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct MessageView: View {
    
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    if message.chatImageUrl != nil && message.chatImageUrl != "" {
                        HStack {
                            Spacer()
                            
                            AsyncImage(url: URL(string: message.chatImageUrl ?? "")) { returnedImage in
                                                returnedImage
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 200, height: 200, alignment: .trailing)
                                                    .shadow(radius: 5)
                                            } placeholder: {
                                                ProgressView()
                                                    .frame(width: 200, height: 200)
                                            }
                            
                        }
                        .padding(.vertical, 5)
                    }
                    else {
                        HStack {
                            Text(message.text)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    
                }
            } else {
                if message.chatImageUrl != nil && message.chatImageUrl != "" {
                    HStack {
                        AsyncImage(url: URL(string: message.chatImageUrl ?? "")) { returnedImage in
                                            returnedImage
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 200, height: 200, alignment: .leading)
                                                .shadow(radius: 5)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 200, height: 200)
                                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                else {
                    HStack {
                        HStack {
                            Text(message.text)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        Spacer()
                    }
                }
                
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(vm: ChatLogViewModel(chatUser: ChatUser(data: ["userName": "Tekrowe"])))
    }
}
