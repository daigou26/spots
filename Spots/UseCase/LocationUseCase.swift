//
//  Created on 2021/12/08
//

import Foundation
import MapKit

protocol LocationUseCase {
    func geocode(address: String) async throws -> CLLocationCoordinate2D
}
