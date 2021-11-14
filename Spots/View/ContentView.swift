//
//  Created on 2021/11/08
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .signedIn: ProfileView()
            case .signedOut: LoginView()
            }
        }.onAppear {
            Task.init {
                await viewModel.restorePreviousSignIn()
            }   
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
