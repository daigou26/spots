//
//  Created on 2021/11/10
//

import Foundation
import Firebase
import GoogleSignIn
import Combine

class AuthenticationViewModel: NSObject, ObservableObject {
    enum AuthState {
        case signedIn
        case signedOut
    }
    
    @Published var state: AuthState = .signedOut
    @Published var errorMessage: String = ""
    
    private var authUseCaseImpl = AuthUseCaseImpl()
    var cancellables = [AnyCancellable]()
    
    func signIn() {
        authUseCaseImpl.signIn().sink { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                self.state = .signedOut
                switch error {
                case let error as AuthError:
                    self.errorMessage = error.localizedDescription
                    print(error.localizedDescription)
                default: break
                }
            }
        } receiveValue: { signedIn in
            self.state = signedIn ? .signedIn : .signedOut
        }.store(in: &cancellables)
    }
    
    func restorePreviousSignIn() {
        authUseCaseImpl.restorePreviousSignIn().sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self.state = .signedOut
                switch error {
                case let error as AuthError:
                    self.errorMessage = error.localizedDescription
                    print(error.localizedDescription)
                default: break
                }
            }
        }, receiveValue: { signedIn in
            self.state = signedIn ? .signedIn : .signedOut
        }).store(in: &cancellables)
    }
    
    func signOut() {
        authUseCaseImpl.signOut().sink { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                self.state = .signedOut
                switch error {
                case let error as AuthError:
                    self.errorMessage = error.localizedDescription
                    print(error.localizedDescription)
                default: break
                }
            }
        } receiveValue: { signedIn in
            self.state = signedIn ? .signedIn : .signedOut
        }.store(in: &cancellables)
    }
}
