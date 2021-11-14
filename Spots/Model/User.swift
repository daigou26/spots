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
}
extension User: Codable {
    init(_ dictionary: [String: Any]) throws {
        self = try JSONDecoder().decode(User.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
    
    func toDict() -> [String: Any] {
        var data: [String: Any] = ["name": self.name, "email": self.email]
        if let imageUrl = self.imageUrl {
            data["imageUrl"] = imageUrl
        }
        return data
    }
}
