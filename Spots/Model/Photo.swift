//
//  Created on 2021/12/28
//

import Foundation
import FirebaseFirestoreSwift

struct Photo: Hashable {
    @DocumentID var id: String?
    var imageUrl: String
    var name: String
    let timestamp: Date
    var createdAt: Date?
    
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
