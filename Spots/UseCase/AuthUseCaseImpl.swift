//
//  Created on 2021/11/12
//

import Foundation
import Combine
import Firebase
import GoogleSignIn

// Now only implemented GoogleSignIn
class AuthUseCaseImpl: AuthUseCase {
    func signIn() -> AnyPublisher<Bool, Error> {
        return Deferred {
            Future { promise in
                let signInConfig = GIDConfiguration.init(clientID: FirebaseApp.app()?.options.clientID ?? "")
                guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                    return promise(.failure(AuthError.unknown))
                }
                GIDSignIn.sharedInstance.signIn(
                    with: signInConfig,
                    presenting: presentingViewController,
                    callback: { user, error in
                        if let user = user {
                            let authentication = user.authentication
                            guard let idToken = authentication.idToken else {
                                return promise(.failure(AuthError.invalid))
                            }
                            
                            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                           accessToken: authentication.accessToken)
                            Auth.auth().signIn(with: credential) { (_, error) in
                                if let error = error {
                                    promise(.failure(error))
                                } else {
                                    promise(.success(true))
                                }
                            }
                        }
                        else{
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                promise(.failure(AuthError.notFoundUser))
                            }
                        }
                    })
            }
        }.eraseToAnyPublisher()
    }
    
    func restorePreviousSignIn() -> AnyPublisher<Bool, Error> {
        return Future { promise in
            GIDSignIn.sharedInstance.restorePreviousSignIn(callback: { user, error in
                if error != nil || user == nil {
                    promise(.success(false))
                } else {
                    promise(.success(true))
                }
            })
        }.eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Bool, Error> {
        return Deferred {
            Future { promise in
                GIDSignIn.sharedInstance.signOut()
                promise(.success(false))
            }
        }.eraseToAnyPublisher()
    }
}
