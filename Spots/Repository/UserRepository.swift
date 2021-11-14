//
//  Created on 2021/11/13
//

import Foundation

protocol UserRepository {
    func getUser(_ uid: String) async throws -> User?
    func createUser(_ user: User, uid: String) async throws -> Void
    func updateUser(_ user: User, uid: String) async throws -> Void
}
