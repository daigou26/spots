//
//  Created on 2022/02/11
//

import Foundation
import FirebaseFirestoreSwift

struct Category: Hashable {
    @DocumentID var id: String?
    var name: String
    var color: String
    var idx: Int
    var createdAt: Date
    var deleted: Bool

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
