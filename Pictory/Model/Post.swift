//
//  Post.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import SwiftUI
import FirebaseFirestore

struct Post: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
    var dislikedIDs: [String] = []
    var userName: String
    var userUID: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id, text, imageURL, imageReferenceID, publishedDate, likedIDs, dislikedIDs, userName, userUID, userProfileURL
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
        
    static var mock_post: Post = Post(text: "post-text",
                                      userName: "post-user-name",
                                      userUID: "user-uid",
                                      userProfileURL: URL(string: "https://picsum.photos/id/237/200/300")!)
}
