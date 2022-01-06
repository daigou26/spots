//
//  Created on 2021/11/25
//

import Foundation
import Combine
import UIKit

class SpotUseCaseImpl: SpotUseCase {
    let spotRepository: SpotRepository
    let spotStorageRepository: SpotStorageRepository
    let locationUseCase: LocationUseCase
    let imageUseCase: ImageUseCase
    
    init(spotRepository: SpotRepository = SpotRepositoryImpl(), spotStorageRepository: SpotStorageRepository = SpotStorageRepositoryImpl(), locationUseCase: LocationUseCase = LocationUseCaseImpl(), imageUseCase: ImageUseCase = ImageUseCaseImpl()) {
        self.spotRepository = spotRepository
        self.spotStorageRepository = spotStorageRepository
        self.locationUseCase = locationUseCase
        self.imageUseCase = imageUseCase
    }
    
    func getSpot(spotId: String) -> AnyPublisher<Spot, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let res: Spot = try await self.spotRepository.getSpot(spotId: spotId)
                        promise(.success(res))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func checkSpotDuplication(uid: String, title: String, address: String) -> AnyPublisher<CheckSpotDuplicationResponse, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let spots = try await self.spotRepository.getSpotByAddress(uid: uid, address: address)
                        if !spots.isEmpty {
                            for spot in spots {
                                if title == spot.title {
                                    promise(.success(.TitleAndAddress))
                                }
                            }
                            promise(.success(.Address))
                        }
                        promise(.success(.NotDuplicated))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getSpots(uid: String) -> AnyPublisher<[Spot]?, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let res: [Spot]? = try await self.spotRepository.getSpots(uid: uid)
                        promise(.success(res))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func postSpot(uid: String, mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, memo: String) -> AnyPublisher<Spot, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let spotId = self.spotRepository.getNewDocumentId()
                        var imageUrl: String? = nil
                        if let mainImage = mainImage {
                            imageUrl = try await self.spotStorageRepository.uploadMainImage(spotId: spotId, image: mainImage)
                        }
                        let coordinate = try await self.locationUseCase.geocode(address: address)
                        let spot: Spot = Spot(id: spotId, title: title, imageUrl: imageUrl, address: address, latitude: coordinate.latitude, longitude: coordinate.longitude, favorite: favorite, star: star, memo: memo)
                        try await self.spotRepository.postSpot(uid: uid, spot: spot, assets: nil)
//                        if let images = images {
//                            let imagesData = await self.imageUseCase.extractImagesData(assets: images.map({ image in
//                                return image.asset
//                            }))
//                            let photos = await self.spotStorageRepository.uploadImages(spotId: spotId, images: imagesData)
//                        }
                        
                        
                        promise(.success((spot)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
