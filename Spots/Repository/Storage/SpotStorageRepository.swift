//
//  Created on 2021/12/09
//

import Foundation

protocol SpotStorageRepository {
    func uploadMainImage(spotId: String, image: Data) async throws -> String
    func uploadImages(spotId: String, images: [(data: Data, width: Float, height: Float)]) async -> [Photo]
}
