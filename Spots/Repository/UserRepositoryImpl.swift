//
//  Created on 2021/11/13
//

import Foundation
import Firebase

class UserRepositoryImpl: UserRepository {
    let dbRef = Firestore.firestore().collection("users")
    func getUser(_ uid: String) async throws -> User? {
        let document = try await dbRef.document(uid).getDocument()
        if document.exists, let data = document.data() {
            return try User(data)
        } else {
            return nil
        }
    }
    func createUser(_ user: User, uid: String) async throws {
        var data = user.toDict()
        data["createdAt"] = Timestamp(date: Date())
        try await dbRef.document(uid).setData(data)
    }
    
    func updateUser(_ user: User, uid: String) async throws {
        var data = user.toDict()
        data["updatedAt"] = Timestamp(date: Date())
        try await dbRef.document(uid).updateData(data)
    }
}
