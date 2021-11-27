//
//  Created on 2021/11/15
//

import Foundation
import FirebaseFirestoreSwift
import CoreLocation

struct Spot: Hashable {
    @DocumentID var id: String?
    var title: String
    var imageUrl: String
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
}
