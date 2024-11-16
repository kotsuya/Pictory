//
//  User.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let username: String
    let userBio: String
    let userBioLink: String
    let userUID: String
    let userEmail: String
    let userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case username
        case userBio
        case userBioLink
        case userUID
        case userEmail
        case userProfileURL
    }
    
    static var mock_user: User = User(username: "fake-user-name",
                                      userBio: "fake-user-biofake-user-biofake-user-biofake-user-biofake-user-biofake-user-biofake-user-biofake-user-biofake-user-biofake-user-biofake-user-biofake-user-biofake-user-biofake-user-bio",
                                      userBioLink: "fake-user-bio-link",
                                      userUID: "fake-user-uid",
                                      userEmail: "fake-user-email@test.com",
                                      userProfileURL: URL(string: "https://picsum.photos/id/237/200/300")!)
    
}
