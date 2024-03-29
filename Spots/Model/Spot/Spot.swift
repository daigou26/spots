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
    var latitude: Double
    var longitude: Double
    var favorite: Bool
    var star: Bool
    var imageUploadingStatus: [ImageUploadingStatus]?
    var categories: [String]?
    var memo: String?
    var deleted: Bool
    var createdAt: Date
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

struct ImageUploadingStatus: Hashable {
    var count: Int
    var userName: String
    var startedAt: Date
    
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
