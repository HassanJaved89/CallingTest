//
//  ChatLogScreen.swift
//  Calling
//
//  Created by Tekrowe Digital on 7/6/23.
//

import SwiftUI
import Kingfisher

struct ChatLogView<T>: View where T: ChatLogProtocol {
    
    @ObservedObject var vm: T
    @StateObject var countObserver: CountObserver = CountObserver()
    @State private var showImagePicker = false
    @State private var isSheetPresented = false
    @State private var isCallingViewPresented = false
    @State var selectedImage: UIImage?
    @State var isUploadingImage = false
    @StateObject var audioRecorder = AudioRecorder()
    @State private var isSendingAudio = false
    @Environment(\.presentationMode) var presentationMode
    
    let emptyScrollToString = "Empty"
    
    var body: some View {
        ZStack {
            messagesView
            Text(vm.errorMessage)
        }
        //.navigationTitle(vm.chatParticipants[0].userName)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
                self.vm.viewScreenRemoved()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isCallingViewPresented = true
                } label: {
                    Image("CallButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }

            }
        }   
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .fullScreenCover(isPresented: $isCallingViewPresented, content: {
            AgoraRep(presentationMode: $isCallingViewPresented).frame(maxWidth: .infinity, maxHeight: .infinity)
                .onDisappear {
                    isCallingViewPresented = false 
                }
        })
        .onChange(of: isCallingViewPresented, perform: { newValue in
            if newValue {
                Task
                {
                    await vm.sendCall()
                }
            }
        })
        .onChange(of: selectedImage) { image in
            if let image = image {
                DispatchQueue.main.async {
                    selectedImage = image
                    isSheetPresented = true
                }
            }
        }
        .onChange(of: audioRecorder.recordedFileURL, perform: { newValue in
            if audioRecorder.recordedFileURL != nil {
                isSendingAudio = true
                
//                withAnimation(Animation.linear(duration: 4.0).repeatForever(autoreverses: true), {
//                    isSendingAudio = true
//                })
            
                vm.sendAudio(recordedFileURL: audioRecorder.recordedFileURL) { success in
                    isSendingAudio = false
                } failureHandler: { failure in
                    isSendingAudio = false
                }
            }
        })
        .sheet(isPresented: $isSheetPresented) {
            
            if let image = selectedImage {
                SelectedImageView(image: image) { image in
                    DispatchQueue.main.async {
                        isUploadingImage = true
                    }
                    
                    vm.sendImage(image: image) { success in
                        isUploadingImage = false
                        isSheetPresented = false
                    } failureHandler: { failure in
                        isUploadingImage = false
                        isSheetPresented = false
                    }
                }
                .overlay {
                    if isUploadingImage {
                        Color.gray.opacity(0.8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .overlay {
                    if isUploadingImage {
                        ZStack {
//                            Color.gray.opacity(0.8)
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            ProgressView()
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                                .scaleEffect(1.5)
                                .padding()
                        }
                        
                    }
                }
            }
        }
        .onAppear {
            vm.handleCount = handleCount
        }
    }
    
    func loadImage() {
        guard selectedImage != nil else { return }
        isSheetPresented = true
    }
    
    struct SelectedImageView: View {
        var image: UIImage
        var handleSend: (UIImage) async -> ()
        
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
                    Task {
                        await handleSend(image)
                    }
                } label: {
                    Text("Send")
                        .frame(width: 80, height: 30)
                        .padding()
                        .foregroundColor(.white)
                        .background(AppColors.greenColor.color)
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
                                MessageView(message: message, vm: vm)
                            }
                            
                            HStack{ Spacer() }
                            .id(emptyScrollToString)
                        }
                        .onReceive(countObserver.$count) { _ in
                            withAnimation(.easeOut(duration: 1.0)) {
                                scrollViewProxy.scrollTo(emptyScrollToString, anchor: .bottom)
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
        VStack {
            VStack {
              if(self.isSendingAudio == true){
                  VStack {
                      AppColors.greenColor.color
                  }
                  .frame(maxWidth: 500, maxHeight: 5)
                  .background(Color(UIColor.systemBackground))
                  .transition(.move(edge: self.isSendingAudio ? .leading : .trailing))
                 // .offset(x: self.isSendingAudio ? 0 : UIScreen.main.bounds.width)
              }
            }
            .animation(isSendingAudio ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: false) : Animation.easeInOut(duration: 1.0), value: isSendingAudio)
            
            HStack(spacing: 16) {
                Button {
                    showImagePicker.toggle()
                } label: {
                    Image("Attachement")
                        .font(.system(size: 24))
                        .foregroundColor(Color(.darkGray))
                }
                
                ZStack {
                    DescriptionPlaceholder()
                    TextEditor(text: $vm.chatText)
                        .cornerRadius(5)
                        .background(Color.gray.opacity(0.3))
                        .opacity(vm.chatText.isEmpty ? 0.5 : 1)
                }
                .frame(height: 40)
                
                Button {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    } else {
                        audioRecorder.startRecording()
                    }
                    
                    audioRecorder.isRecording.toggle()
                } label: {
                    Image(systemName: audioRecorder.isRecording ? "stop.circle" :  "mic.circle")
                        .font(.system(size: 40))
                }
                .tint(AppColors.greenColor.color)

                Button {
                    vm.handleSend()
                } label: {
                    Image("sendButton")
                        .font(.system(size: 45))
                }
                //.padding(.horizontal)
                //.padding(.vertical, 8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        
    }
    
    func handleCount() {
        countObserver.count += 1
    }
}

struct MessageView: View {
    
    @StateObject var audioPlayerHelper = AudioPlayerHelper()
    @State private var isAnimating = false
    let message: ChatMessage
    var vm: any ChatLogProtocol
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                VStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        if message.chatImageUrl != nil && message.chatImageUrl != "" {
                            HStack {
                                Spacer()
                                chatImageView
                                .frame(width: 200, height: 200, alignment: .trailing)
                            }
                            .padding(.vertical, 5)
                        }
                        else if message.audioUrl != nil && message.audioUrl != "" {
                            HStack {
                                Spacer()
                                audioView
                            }
                        }
                        else {
                            HStack {
                                Text(message.text)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(AppColors.greenColor.color)
                            .cornerRadius(8)
                        }
                    }
                    
                    Text(message.timeString ?? "")
                        .foregroundColor(.gray.opacity(0.9))
                        .font(.customFont(size: .small))
                }
                
            } else {
                VStack(alignment: .leading) {
                    //if vm.chatParticipants.count > 2 {
                        Text(message.senderName ?? "")
                        .padding()
                            .font(.customFont(size: .medium))
                            .fontWeight(.bold)
                    //}
                    if message.chatImageUrl != nil && message.chatImageUrl != "" {
                        HStack {
                            chatImageView
                            .frame(width: 200, height: 200, alignment: .leading)
                            Spacer()
                        }
                        .padding(.vertical, 5)
                    }
                    else if message.audioUrl != nil && message.audioUrl != "" {
                        HStack {
                            audioView
                            Spacer()
                        }
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
                    
                    Text(message.timeString ?? "")
                        .foregroundColor(.gray.opacity(0.9))
                        .font(.customFont(size: .small))
                        .padding(.horizontal)
                }
                
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var chatImageView: some View {
        
        KFImage(URL(string: message.chatImageUrl ?? ""))
            .placeholder {
                ProgressView()
            }
            .resizable()
            .scaledToFit()
            .shadow(radius: 5)
    }
    
    private var audioView: some View {
        Button {

            audioPlayerHelper.isPlaying.toggle()
            
            if audioPlayerHelper.isPlaying {
                audioPlayerHelper.playAudio(from: URL(string: message.audioUrl!)!)
            }
            else {
                audioPlayerHelper.stopAudio()
            }
            
        } label: {
            Image(systemName: "headphones")
                .font(.system(size: 45))
                .foregroundColor(AppColors.greenColor.color)
                .rotationEffect(audioPlayerHelper.isPlaying ? .degrees(0) : .degrees(-10))
                .scaleEffect(audioPlayerHelper.isPlaying ? 1.1 : 1.0)
                .animation(Animation.easeInOut(duration: 0.5).repeat(while: audioPlayerHelper.isPlaying))
        }
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Type here...")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

/*
struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(vm: ChatLogViewModel(chatUser: ChatUser(data: ["userName": "Tekrowe"])))
    }
}*/


extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}


struct LineView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.blue)
                .frame(width: geometry.size.width * 0.3, height: 2)
                .offset(x: isAnimating ? -geometry.size.width * 0.35 : geometry.size.width * 0.35, y: 0)
                .animation(
                    Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: true)
                )
        }
    }
}
