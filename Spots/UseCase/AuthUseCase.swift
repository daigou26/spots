//
//  Created on 2021/11/12
//

import Foundation
import Combine

protocol AuthUseCase {
    func signIn() async -> AnyPublisher<Bool, Error>
    func restorePreviousSignIn() -> AnyPublisher<Bool, Error>
    func signOut() -> AnyPublisher<Bool, Error>
}
