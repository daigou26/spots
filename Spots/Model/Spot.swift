//
//  Created on 2021/11/15
//

import Foundation
import FirebaseFirestoreSwift
import CoreLocation

struct Spot: Hashable {
    @DocumentID var id: String?
    var title: String
    var address: String
    var category: [String]?
    var memo: String?
    var imageUrl: String
    var favorite: Bool
    var star: Bool
    var createdAt: Date?
    var updatedAt: Date?
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
