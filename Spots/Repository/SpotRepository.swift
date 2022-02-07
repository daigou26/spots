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
    func postSpot(uid: String, spot: Spot) async throws
    func updateSpot(
        spotId: String,
        title: String?,
        imageUrl: String?,
        address: String?,
        latitude: Double?,
        longitude: Double?,
        favorite: Bool?,
        star: Bool?,
        imageUploadingStatus: [ImageUploadingStatus]?,
        category: [String]?,
        memo: String?,
        deleted: Bool?,
        updatedAt: Date
    ) async throws
    func postPhotos(uid: String, spotId: String, photos: [Photo]) async
    func updateImageUploadingStatus(uid: String, spotId: String, imageUploadingStatus: ImageUploadingStatus) async
}
