//
//  ReusablePostsView.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import SwiftUI

struct ReusablePostsView: View {
    @ObservedObject var vm: PostsViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if vm.isFetching {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if vm.posts.isEmpty {
                        Text("No Post's Found")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .padding(.top, 30)
                    } else {
                        PostcardViews()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            await vm.refresh()
        }
        .task {
            guard vm.posts.isEmpty else { return }
            await vm.fetchPosts()
        }
    }
    
    @ViewBuilder
    func PostcardViews() -> some View {
        ForEach(vm.posts) { post in
            PostCardView(post: post) { updatedPost in
                withAnimation(.easeInOut(duration: 0.25)) {
                    vm.update(updatedPost)
                }
            } onDelete: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    vm.delete(post)
                }
            }
            .onAppear {
                vm.onAppear(post)
            }

            Divider()
                .padding(.horizontal, -15)
        }
    }
}

#Preview {
//    ReusablePostsView(posts: .constant([Post(text: "Post Text", userName: "User Name", userUID: "User UID", userProfileURL: URL(string: "https://example.com")!)]))    
    ReusablePostsView(vm: PostsViewModel())
}
