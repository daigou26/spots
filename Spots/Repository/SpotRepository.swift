//
//  Created on 2021/11/25
//

import Foundation

protocol SpotRepository {
    func getSpot(spotId: String) async throws -> Spot
    func getSpotByAddress(uid: String, address: String) async throws -> [Spot]
    func getPhotos(spotId: String) async throws -> [Photo]
    func getSpots(uid: String) async throws -> [Spot]?
    func getNewDocumentId() -> String
    func postSpot(uid: String, spot: Spot, assets: [Data]?) async throws
}
