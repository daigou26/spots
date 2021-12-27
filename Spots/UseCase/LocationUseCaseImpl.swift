//
//  Created on 2021/12/08
//

import Foundation
import MapKit

class LocationUseCaseImpl: LocationUseCase {
    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        let placemarks = try await CLGeocoder().geocodeAddressString(address)
        
        guard let location = placemarks.first?.location else {
            throw LocationError.NotFound
        }
        return location.coordinate
    }
}

enum LocationError: Error {
    case NotFound
}
