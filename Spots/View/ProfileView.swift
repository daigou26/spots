//
//  Created on 2021/11/14
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    
    init() {
        profileViewModel = ProfileViewModel()
    }
    
    var body: some View {
        VStack {
            HStack() {
                if let imageUrl = profileViewModel.account.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)){ image in
                        image.resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay {
                                Circle().stroke(.white, lineWidth: 2)
                            }
                            .shadow(radius: 7)
                    } placeholder: {
                        RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)).fill(Color.background).frame(width: 60, height: 60)
                    }   
                } else {
                    Image(systemName: "Person").frame(width: 60, height: 60)
                        .overlay {
                            Circle().stroke(.white, lineWidth: 2)
                        }
                        .shadow(radius: 7)
                }
                
                Text(profileViewModel.account.name).font(.title2).padding()
                Spacer()
            }.padding()
            Spacer()
            Button("Sign out") {
                authViewModel.signOut()
            }.foregroundColor(.textGray).padding()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                Image(systemName: "person").frame(width: 80, height: 80)
                    .overlay {
                        Circle().stroke(.white, lineWidth: 4)
                    }
                    .shadow(radius: 7)
                Text("NAme").font(.title2).padding()
                Spacer()
            }.padding()
            Spacer()
            Button("Sign out"){}.padding()
            
        }
    }
}
