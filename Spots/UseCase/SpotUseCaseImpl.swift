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
    let uid = Account.shared.uid
    
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
    
    func getPhotos(spotId: String) -> AnyPublisher<[Photo], Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let res: [Photo] = try await self.spotRepository.getPhotos(spotId: spotId)
                        promise(.success(res))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func checkSpotDuplication(title: String, address: String) -> AnyPublisher<CheckSpotDuplicationResponse, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let spots = try await self.spotRepository.getSpotByAddress(uid: self.uid, address: address)
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
    
    func getSpots() -> AnyPublisher<[Spot]?, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let res: [Spot]? = try await self.spotRepository.getSpots(uid: self.uid)
                        promise(.success(res))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func postSpot(mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, memo: String) -> AnyPublisher<Spot, Error> {
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
                        let imageUploadingStatus = ImageUploadingStatus(count: images?.count ?? 0, userName: Account.shared.name, startedAt: Date())
                        let spot: Spot = Spot(id: spotId, title: title, imageUrl: imageUrl, address: address, latitude: coordinate.latitude, longitude: coordinate.longitude, favorite: favorite, star: star, imageUploadingStatus: [imageUploadingStatus], memo: memo, deleted: false, createdAt: Date())
                        
                        try await self.spotRepository.postSpot(uid: self.uid, spot: spot)
                        
                        if let images = images, images.count > 0 {
                            let imagesData = await self.imageUseCase.extractImagesData(assets: images.map({ image in
                                return image.asset
                            }))
                            let photos = await self.spotStorageRepository.uploadImages(spotId: spotId, images: imagesData)
                            await self.spotRepository.postPhotos(uid: self.uid, spotId: spotId, photos: photos)
                            await self.spotRepository.updateImageUploadingStatus(uid: self.uid, spotId: spotId, imageUploadingStatus: imageUploadingStatus)
                        }
                        promise(.success((spot)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateSpot(spotId: String,
                    mainImage: Data?,
                    images: [Asset]?,
                    title: String?,
                    address: String?,
                    favorite: Bool?,
                    star: Bool?,
                    memo: String?,
                    deleted: Bool?
    ) -> AnyPublisher<Spot, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        var imageUrl: String?
                        if let mainImage = mainImage {
                            imageUrl = try await self.spotStorageRepository.uploadMainImage(spotId: spotId, image: mainImage)
                        }
                        
                        var latitude: Double?
                        var longitude: Double?
                        if let address = address {
                            let coordinate = try await self.locationUseCase.geocode(address: address)
                            latitude = coordinate.latitude
                            longitude = coordinate.longitude
                        }
                        
                        let imageUploadingStatus = ImageUploadingStatus(count: images?.count ?? 0, userName: Account.shared.name, startedAt: Date())
                        let spot: Spot = Spot(id: spotId, title: title ?? "", imageUrl: imageUrl ?? "", address: address ?? "", latitude: latitude ?? 0, longitude: longitude ?? 0, favorite: favorite ?? false, star: star ?? false, imageUploadingStatus: nil, memo: memo ?? memo, deleted: false, createdAt: Date())
                        
                        try await self.spotRepository.updateSpot(spotId: spotId,
                                                                 title: title,
                                                                 imageUrl: imageUrl,
                                                                 address: address,
                                                                 latitude: latitude,
                                                                 longitude: longitude,
                                                                 favorite: favorite,
                                                                 star: star,
                                                                 imageUploadingStatus: [imageUploadingStatus],
                                                                 category: nil,
                                                                 memo: memo,
                                                                 deleted: deleted,
                                                                 updatedAt: Date())
                        
                        if let images = images, images.count > 0 {
                            Task {
                                let imagesData = await self.imageUseCase.extractImagesData(assets: images.map({ image in
                                    return image.asset
                                }))
                                let photos = await self.spotStorageRepository.uploadImages(spotId: spotId, images: imagesData)
                                await self.spotRepository.postPhotos(uid: self.uid, spotId: spotId, photos: photos)
                                await self.spotRepository.updateImageUploadingStatus(uid: self.uid, spotId: spotId, imageUploadingStatus: imageUploadingStatus)
                            }
                        }
                        promise(.success((spot)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updatePhoto(spotId: String,
                     photoId: String,
                     photo: Photo
    ) -> AnyPublisher<Photo, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        try await self.spotRepository.updatePhoto(spotId: spotId, photoId: photoId, photo: photo)
                        promise(.success((photo)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
