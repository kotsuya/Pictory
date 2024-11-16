//
//  MainView.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            PostsView()
                .tabItem {
                    Image(systemName: "document.circle")
                    Text("Post's")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .tint(.black)
    }
}

#Preview {
    MainView()
}
