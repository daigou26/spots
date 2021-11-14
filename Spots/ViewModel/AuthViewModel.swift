//
//  Created on 2021/11/10
//

import Foundation
import Firebase
import GoogleSignIn
import Combine

@MainActor
class AuthViewModel: NSObject, ObservableObject {
    enum AuthState {
        case signedIn
        case signedOut
    }
    
    @Published var state: AuthState = .signedOut
    @Published var errorMessage: String = ""
    
    private var authUseCase: AuthUseCase
    var cancellables = [AnyCancellable]()
    
    init(_ authUseCase: AuthUseCase = AuthUseCaseImpl()) {
        self.authUseCase = authUseCase
    }
    
    func signIn() async {
        await authUseCase.signIn().sink { completion in
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
    
    func restorePreviousSignIn() async {
        await authUseCase.restorePreviousSignIn().sink(receiveCompletion: { completion in
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
        authUseCase.signOut().sink { completion in
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
