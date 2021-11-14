//
//  Created on 2021/11/08
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct SpotsApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
