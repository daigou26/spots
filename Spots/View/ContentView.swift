//
//  Created on 2021/11/08
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var selectedAnnotation: String? = "111"
    @State var selected: Bool = false
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .signedIn: TabView {
                SpotsView().tabItem {
                    Image("Map")
                }
                ProfileView().tabItem {
                    Image("Person")
                }
            }
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
