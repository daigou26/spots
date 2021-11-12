//
//  Created on 2021/11/08
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .signedIn: VStack {
                Text("Hello, world!")
                    .padding()
                Button("Sign out") {
                    viewModel.signOut()
                }
            }
            case .signedOut: LoginScreen()
            }
        }.onAppear {
            viewModel.restorePreviousSignIn()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
