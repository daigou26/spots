//
//  Created on 2021/11/13
//

import Foundation
import FirebaseFirestore

class UserRepositoryImpl: UserRepository {
    let dbRef = Firestore.firestore().collection("users")
    func getUser(_ uid: String) async throws -> User? {
        let document = try await dbRef.document(uid).getDocument()
        if document.exists, let data = document.data(), let name: String = data["name"] as? String, let email: String = data["email"] as? String {
            let imageUrl = data["imageUrl"] as? String
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
            let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
            
            return User(name: name, email: email, imageUrl: imageUrl, createdAt: createdAt, updatedAt: updatedAt)
        } else {
            return nil
        }
    }
    func createUser(_ user: User, uid: String) async throws {
        var data = user.asDictionary
        data["createdAt"] = Timestamp(date: Date())
        try await dbRef.document(uid).setData(data)
    }
    
    func updateUser(_ user: User, uid: String) async throws {
        var data = user.asDictionary
        data["updatedAt"] = Timestamp(date: Date())
        try await dbRef.document(uid).updateData(data)
    }
}
