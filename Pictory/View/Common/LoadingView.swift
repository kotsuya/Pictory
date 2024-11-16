//
//  LoadingView.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import SwiftUI

struct LoadingView: View {
    @Binding var show: Bool
    var body: some View {
        ZStack {
            if show {
                Group {
                    Rectangle()
                        .fill(.black.opacity(0.25))
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .padding(15)
                        .background(.white, in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .animation(.easeIn(duration: 0.25), value: show)
    }
}

#Preview {
    LoadingView(show: .constant(true))
}
