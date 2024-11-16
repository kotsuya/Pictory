//
//  PostCardView.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseStorage

struct PostCardView: View {    
    var post: Post
    var onUpdate: (Post) -> ()
    var onDelete: () -> ()
    
    @AppStorage("user_UID") var userUID: String = ""
    @State private var docListner: ListenerRegistration?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .indicator(.activity)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .frame(height: 200)
                }
                
                PostInteraction()
            }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing) {
            if post.userUID == userUID {
                Menu {
                    Button("Delete Post", role: .destructive) {
                        deletePost()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundStyle(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        }
        .onAppear {
            if docListner == nil {
                guard let postID = post.id else { return }
                self.docListner = Firestore.firestore().collection("Posts")
                    .document(postID)
                    .addSnapshotListener { snapshot, error in
                        guard let snapshot else {
                            print("Error fetching document: \(error!)")
                            return
                        }
                        if snapshot.exists {
                            if let updatedPost = try? snapshot.data(as: Post.self) {
                                onUpdate(updatedPost)
                            }
                        } else {
                            onDelete()
                        }
                    }
            }
        }
        .onDisappear {
            if let docListner {
                docListner.remove()
                self.docListner = nil
            }
        }
    }
    
    @ViewBuilder
    func PostInteraction() -> some View {
        HStack(spacing: 6) {
            Button(action: likePost) {
                Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundStyle(.gray)
            
            Button(action: dislikePost) {
                Image(systemName: post.dislikedIDs.contains(userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
            }
            .padding(.leading, 25)
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .foregroundStyle(.black)
        .padding(.vertical, 8)
    }
    
    func likePost() {
        Task {
            do {
                guard let postID = post.id else { return }
                if post.likedIDs.contains(userUID) {
                    let dic = ["likedIDs": FieldValue.arrayRemove([userUID])]
                    try await Firestore.firestore().collection("Posts")
                        .document(postID).updateData(dic)
                } else {
                    let dic = ["likedIDs": FieldValue.arrayUnion([userUID]),
                               "dislikedIDs": FieldValue.arrayRemove([userUID])]
                    try await Firestore.firestore().collection("Posts")
                        .document(postID).updateData(dic)
                }
            } catch {
                print("akb::like Post Error:" + error.localizedDescription)
            }
        }
    }
    
    func dislikePost() {
        Task {
            do {
                guard let postID = post.id else { return }
                if post.dislikedIDs.contains(userUID) {
                    let dic = ["dislikedIDs": FieldValue.arrayRemove([userUID])]
                    try await Firestore.firestore().collection("Posts")
                        .document(postID).updateData(dic)
                } else {
                    let dic = ["likedIDs": FieldValue.arrayRemove([userUID]),
                               "dislikedIDs": FieldValue.arrayUnion([userUID])]
                    try await Firestore.firestore().collection("Posts")
                        .document(postID).updateData(dic)
                }
            } catch {
                print("akb::dislike Post Error:" + error.localizedDescription)
            }
        }
    }
    
    func deletePost() {
        Task {
            do {
                if post.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                }
                guard let postID = post.id else { return }
                try await Firestore.firestore().collection("Posts").document(postID).delete()
            } catch {
                print("akb::delete Post Error:" + error.localizedDescription)
            }
        }
    }
}

#Preview {
    PostCardView(post: Post.mock_post) { _ in } onDelete: { }
}
