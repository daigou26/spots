//
//  Created on 2021/11/15
//

import Foundation
import FirebaseFirestoreSwift
import CoreLocation

struct Spot: Hashable {
    @DocumentID var id: String?
    var title: String
    var imageUrl: String?
    var address: String
    let latitude: Double
    let longitude: Double
    var favorite: Bool
    var star: Bool
    var category: [String]?
    var memo: String?
    var createdAt: Date?
    var updatedAt: Date?
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
