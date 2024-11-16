//
//  PostsViewModel.swift
//  Pictory
//
//  Created by YOO on 2024/11/16.
//

import SwiftUI
import FirebaseFirestore

class PostsViewModel: ObservableObject {
    private let POST_LIMIT_COUNT: Int = 10
    
    @Published var posts: [Post] = []
    @Published var isFetching: Bool = true
    @Published var paginationDoc: QueryDocumentSnapshot?
    
    var basedOnUID: Bool
    var uid: String
    
    init(basedOnUID: Bool = false, uid: String = "") {
        self.basedOnUID = basedOnUID
        self.uid = uid
    }
    
    func fetchPosts() async {
        do {
            var query: Query
            
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: POST_LIMIT_COUNT)
            } else {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: POST_LIMIT_COUNT)
            }
            
            if basedOnUID {
                query = query
                    .whereField("userUID", isEqualTo: uid)
            }
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run {
                posts.append(contentsOf: fetchedPosts)
                paginationDoc = docs.documents.last
                isFetching = false
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func refresh() async {
        guard !basedOnUID else { return }
        await MainActor.run {
            isFetching = true
            posts = []
            paginationDoc = nil
        }
        await fetchPosts()
    }
    
    func update(_ updatedPost: Post) {
        if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
            posts[index].likedIDs = updatedPost.likedIDs
            posts[index].dislikedIDs = updatedPost.dislikedIDs
        }
    }
    
    func delete(_ deletePost: Post) {
        posts.removeAll { $0.id == deletePost.id }
    }
    
    func onAppear(_ post: Post) {
        if post.id == posts.last?.id && paginationDoc != nil {
            print("Fetch New Post's")
            Task {
                await fetchPosts()
            }
        }
    }
}
