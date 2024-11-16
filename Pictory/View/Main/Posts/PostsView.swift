//
//  PostsView.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import SwiftUI

struct PostsView: View {
    @State private var createNewPost: Bool = false
    
    @StateObject var viewModel = PostsViewModel()
    
    var body: some View {
        NavigationStack {
            ReusablePostsView(vm: viewModel)
                .hAlign(.center)
                .vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(13)
                            .background(.black, in: Circle())
                    }
                    .padding(15)
                }
                .navigationTitle("Post's")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            SearchUserView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.black)
                                .scaleEffect(0.9)
                        }
                    }
                }
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreatePost { post in
                viewModel.posts.insert(post, at: 0)
            }
        }
    }
}

#Preview {
    PostsView()
}
