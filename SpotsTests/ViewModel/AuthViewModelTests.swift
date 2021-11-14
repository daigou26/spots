//
//  Created on 2021/11/14
//

import XCTest
import Combine
@testable import Spots

class AuthUseCaseMock: AuthUseCase {
    func signIn() async -> AnyPublisher<Bool, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
    
    func restorePreviousSignIn() async -> AnyPublisher<Bool, Error> {
        return Deferred {
            Future { promise in
                return promise(.failure(AuthError.invalid))
            }
        }.eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Bool, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(false))
            }
        }.eraseToAnyPublisher()
    }
}

class AuthViewModelTests: XCTestCase {
    enum AuthState {
        case signedIn
        case signedOut
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testSignIn() async throws {
        let authViewModel = AuthViewModel(AuthUseCaseMock())
        await authViewModel.signIn()
        XCTAssertEqual(authViewModel.state, .signedIn)
    }
    
    @MainActor func testRestorePreviousSignIn() async throws {
        let authViewModel = AuthViewModel(AuthUseCaseMock())
        await authViewModel.restorePreviousSignIn()
        XCTAssertEqual(authViewModel.errorMessage, AuthError.invalid.localizedDescription)
    }
    
    @MainActor func testSignOut() throws {
        let authViewModel = AuthViewModel(AuthUseCaseMock())
        authViewModel.signOut()
        XCTAssertEqual(authViewModel.state, .signedOut)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
