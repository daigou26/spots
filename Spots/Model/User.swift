//
//  Created on 2021/11/13
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var imageUrl: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    init(name: String, email: String, imageUrl: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.name = name
        self.email = email
        self.imageUrl = imageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
extension User: Codable {
    // TODO: Fix decord func(Because of the Date type, this occurred a error)
//    init(_ dictionary: [String: Any]) throws {
//        self = try JSONDecoder().decode(User.self, from: JSONSerialization.data(withJSONObject: dictionary))
//    }
    
    func toDict() -> [String: Any] {
        var data: [String: Any] = ["name": self.name, "email": self.email]
        if let imageUrl = self.imageUrl {
            data["imageUrl"] = imageUrl
        }
        return data
    }
}
