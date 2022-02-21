//
//  Created on 2021/11/10
//

import Foundation
import Firebase
import GoogleSignIn
import Combine

class AuthViewModel: ObservableObject {
    @Published var state: AuthState = .SignedOut
    @Published var errorMessage: String = ""
    
    private var authUseCase: AuthUseCase
    var cancellables = [AnyCancellable]()
    
    init(_ authUseCase: AuthUseCase = AuthUseCaseImpl()) {
        self.authUseCase = authUseCase
    }
    
    func signIn() async {
        await authUseCase.signIn().receive(on: DispatchQueue.main).sink { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                self.state = .SignedOut
                switch error {
                case let error as AuthError:
                    self.errorMessage = error.localizedDescription
                default: break
                }
            }
        } receiveValue: { signedIn in
            self.state = signedIn ? .SignedIn : .SignedOut
        }.store(in: &cancellables)
    }
    
    func restorePreviousSignIn() async {
        await authUseCase.restorePreviousSignIn().receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self.state = .SignedOut
                switch error {
                case let error as AuthError:
                    self.errorMessage = error.localizedDescription
                default: break
                }
            }
        }, receiveValue: { signedIn in
            self.state = signedIn ? .SignedIn : .SignedOut
        }).store(in: &cancellables)
    }
    
    func signOut() {
        authUseCase.signOut().sink { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                self.state = .SignedOut
                switch error {
                case let error as AuthError:
                    self.errorMessage = error.localizedDescription
                default: break
                }
            }
        } receiveValue: { signedIn in
            self.state = signedIn ? .SignedIn : .SignedOut
        }.store(in: &cancellables)
    }
}
