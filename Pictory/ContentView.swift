//
//  ContentView.swift
//  Pictory
//
//  Created by YOO on 2024/11/04.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    var body: some View {
        if logStatus {
            MainView()
        } else {
            LoginView() 
        }
    }
}

#Preview {
    ContentView()
}
