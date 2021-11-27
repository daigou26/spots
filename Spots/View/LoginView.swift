//
//  Created on 2021/11/08
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        VStack {
            Spacer()
            
            Image("Login")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            
            Text("Welcome to Spots!")
                .fontWeight(.black)
                .foregroundColor(Color.main)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            Text("Let's spot your place and \n share with your friends!")
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Text(viewModel.errorMessage).foregroundColor(Color.red).frame(height: 50)
            Button("Sign in with Google") {
                Task {
                    await viewModel.signIn()
                }
            }
            .buttonStyle(AuthenticationButtonStyle())
        }.background(Color.base)
    }
}

struct AuthenticationButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.main)
            .cornerRadius(12)
            .padding()
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
