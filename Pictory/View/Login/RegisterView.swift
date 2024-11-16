//
//  RegisterView.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var userName: String = ""
    @State private var userBio: String = ""
    @State private var userBioLink: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    @State private var userProfilePicData: Data?
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    @AppStorage("log_status") private var logStatus: Bool = false
    @AppStorage("user_profile_url") private var profileURL: URL?
    @AppStorage("user_name") private var userNameStored: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Register Account")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Hello user, have a wonderful journey with us")
                .font(.title3)
                .hAlign(.leading)
            
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    RegisterContentView()
                }
                
                RegisterContentView()
            }
            
            HStack {
                Text("Already Have an account?")
                    .foregroundStyle(.gray)
                
                Button("Login Now") {
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundStyle(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { oldValue, newValue in
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else { return }
                        await MainActor.run {
                            userProfilePicData = imageData
                        }
                    } catch { }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError) { }
    }
    
    @ViewBuilder
    func RegisterContentView() -> some View {
        VStack(spacing: 12) {
            ZStack {
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .contentShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .padding(.top, 25)
            .onTapGesture {
                showImagePicker.toggle()
            }
            
            TextField("UserName", text: $userName)
                .border(1, .gray.opacity(0.5))
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .border(1, .gray.opacity(0.5))
            
            TextField("About you", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link (Optional)", text: $userBioLink)
                .border(1, .gray.opacity(0.5))
            
            Button {
                registerUser()
            } label: {
                Text("Sign up")
                    .foregroundStyle(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .padding(.top, 10)
            .disableWithOpacity(userName == "" || userBio == "" || email == "" || password == "" || userProfilePicData == nil)
        }
    }
    
    func registerUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                guard let imageData = userProfilePicData else { return }
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()
                let user = User(username: userName, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: email, userProfileURL: downloadURL)
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: { error in
                    if error == nil {
                        print("Saved Successfully")
                        self.userUID = userUID
                        userNameStored = userName
                        profileURL = downloadURL
                        logStatus = true
                    }
                })
            } catch {
                try await Auth.auth().currentUser?.delete()
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        }
    }
}


#Preview {
    RegisterView()
}
