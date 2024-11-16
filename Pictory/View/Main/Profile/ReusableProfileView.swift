//
//  ReusableProfileView.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileView: View {
    var user: User
    @State private var fetchedPosts: [Post] = []
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                HStack(spacing: 12) {
                    WebImage(url: user.userProfileURL) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .resizable()
                    }
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .lineLimit(3)
                        
                        if let bioLink = URL(string: user.userBioLink) {
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                        
                    }
                    .hAlign(.leading)
                }
                
                Text("Post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
                
                
                ReusablePostsView(
                    vm: PostsViewModel(
                        basedOnUID: true,
                        uid: user.userUID
                    )
                )
            }
            .padding(15)
        }
    }
}

#Preview {
    ReusableProfileView(user: User.mock_user)
}
