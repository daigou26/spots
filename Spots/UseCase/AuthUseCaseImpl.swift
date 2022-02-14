//
//  Created on 2021/11/12
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore
import GoogleSignIn

// Now only implemented GoogleSignIn
class AuthUseCaseImpl: AuthUseCase {
    let userRepository: UserRepository
    let categoryRepository: CategoryRepository
    
    init(userRepository: UserRepository = UserRepositoryImpl(), categoryRepository: CategoryRepository = CategoryRepositoryImpl()) {
        self.userRepository = userRepository
        self.categoryRepository = categoryRepository
    }
    
    @MainActor
    func signIn() async -> AnyPublisher<Bool, Error> {
        return Deferred {
            Future { promise in
                let signInConfig = GIDConfiguration.init(clientID: FirebaseApp.app()?.options.clientID ?? "")
                guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                    return promise(.failure(AuthError.Unknown))
                }
                GIDSignIn.sharedInstance.signIn(
                    with: signInConfig,
                    presenting: presentingViewController,
                    callback: { user, error in
                        if let user = user {
                            let authentication = user.authentication
                            guard let idToken = authentication.idToken else {
                                return promise(.failure(AuthError.Invalid))
                            }
                            
                            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                           accessToken: authentication.accessToken)
                            Auth.auth().signIn(with: credential) { (authRes, error) in
                                Task {
                                    if let error = error {
                                        promise(.failure(error))
                                    } else if let user = authRes?.user, let name = user.displayName, let email = user.email {
                                        do {
                                            // Get user document
                                            let userRes = try await self.userRepository.getUser(user.uid)
                                            // Get spot categories info
                                            let categoriesRes = try await self.categoryRepository.getCategories(user.uid)
                                            if let userRes = userRes {
                                                Account.shared.save(uid: user.uid, email: userRes.email, name: userRes.name, imageUrl: userRes.imageUrl, categories: categoriesRes)
                                            } else {
                                                // Create user data
                                                let userData: User = User(name: name, email: email, imageUrl: user.photoURL?.absoluteString)
                                                try await self.userRepository.createUser(userData, uid: user.uid)
                                                Account.shared.save(uid: user.uid, email: email, name: name, imageUrl: user.photoURL?.absoluteString, categories: categoriesRes)
                                            }
                                            
                                            promise(.success(true))
                                        } catch {
                                            promise(.failure(AuthError.Unknown))
                                        }
                                    } else {
                                        promise(.failure(AuthError.NotFoundUser))
                                    }
                                }
                            }
                        }
                        else {
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                promise(.failure(AuthError.NotFoundUser))
                            }
                        }
                    })
            }
        }.eraseToAnyPublisher()
    }
    
    func restorePreviousSignIn() async -> AnyPublisher<Bool, Error> {
        return Future { promise in
            GIDSignIn.sharedInstance.restorePreviousSignIn(callback: { user, error in
                if let user = user {
                    let authentication = user.authentication
                    guard let idToken = authentication.idToken else {
                        return promise(.failure(AuthError.Invalid))
                    }
                    
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: authentication.accessToken)
                    Auth.auth().signIn(with: credential) { (authRes, error) in
                        Task {
                            if error == nil, let user = authRes?.user {
                                do {
                                    let userRes = try await self.userRepository.getUser(user.uid)
                                    let categoriesRes = try await self.categoryRepository.getCategories(user.uid)
                                    if let userRes = userRes {
                                        Account.shared.save(uid: user.uid, email: userRes.email, name: userRes.name, imageUrl: userRes.imageUrl, categories: categoriesRes)
                                    } else {
                                        promise(.success(false))
                                    }
                                    
                                    promise(.success(true))
                                } catch {
                                    promise(.success(false))
                                }
                            } else {
                                promise(.success(false))
                            }
                        }
                    }
                }
                else {
                    promise(.success(false))
                }
            })
        }.eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Bool, Error> {
        return Deferred {
            Future { promise in
                GIDSignIn.sharedInstance.signOut()
                Account.shared.reset()
                promise(.success(false))
            }
        }.eraseToAnyPublisher()
    }
}
