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
    
    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            if label == "_id" {return nil}
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
}
