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
                .aspectRatio(contentMode: .fill)
                .frame(height: 400)
            Spacer()
            
            Text(viewModel.errorMessage).foregroundColor(Color.red).frame(height: 50)
            Button(action: {
                Task {
                    await viewModel.signIn()
                }
            }, label: {
                Text("Googleアカウントでログイン").font(.system(size: 18, weight: .bold))
            }).buttonStyle(AuthenticationButtonStyle())
        }.background(Color.base)
    }
}

struct AuthenticationButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.textGray2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.textGray2, lineWidth: 1)
            )
            .padding()
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
