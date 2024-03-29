//
//  Created on 2021/12/28
//

import Foundation
import Combine
import SwiftUI
import UIKit

class SpotDetailViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var spot: Spot? = nil
    @Published var categories = Account.shared.categories
    @Published var photos: [Photo] = []
    @Published var imageUploadingStatus: String = ""
    @Published var updatingFavorite: Bool = false
    @Published var updatingStar: Bool = false
    @Published var updating: Bool = false
    @Published var updatingTitle: Bool = false
    @Published var updatingMemo: Bool = false
    @Published var errorMessage: String = ""
    @Published var showAddPhotosSheet = false
    @Published var goAddCategoryView = false
    
    private var spotUseCase: SpotUseCase
    private var locationUseCase: LocationUseCase
    var cancellables = [AnyCancellable]()
    
    init(_ spotUseCase: SpotUseCase = SpotUseCaseImpl(), locationUseCase: LocationUseCase = LocationUseCaseImpl()) {
        self.spotUseCase = spotUseCase
        self.locationUseCase = locationUseCase
    }
    
    func getCategoryColor(idx: Int) -> String {
        if let spot = spot, let spotCategories = spot.categories {
            return categories.filter { c in
                return c.id == spotCategories[idx]
            }.first?.color ?? ""
        }
        return ""
    }
    
    func getCategoryName(idx: Int) -> String {
        if let spot = spot, let spotCategories = spot.categories {
            return categories.filter { c in
                return c.id == spotCategories[idx]
            }.first?.name ?? ""
        }
        return ""
    }
    
    func isSetCategory(id: String) -> Bool {
        if let spot = spot, let spotCategories = spot.categories {
            return spotCategories.contains(id)
        }
        return false
    }
    
    func getSpot(spotId: String) async {
        self.loading = true
        
        let _: Void = await withCheckedContinuation { continuation in
            spotUseCase.getSpot(spotId: spotId).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure: break
                }
            }, receiveValue: { spot in
                self.spot = spot
                if let uploadingStatus = spot.imageUploadingStatus, uploadingStatus.count > 0 {
                    var uploadingCount = 0
                    for s in uploadingStatus {
                        uploadingCount += s.count
                    }
                    self.imageUploadingStatus = String(uploadingCount) + "枚の写真をアップロード中"
                }
                self.loading = false
                continuation.resume()
            }).store(in: &cancellables)
        }
    }
    
    func getPhotos(spotId: String) async {
        let _: Void = await withCheckedContinuation { continuation in
            spotUseCase.getPhotos(spotId: spotId).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure: break
                }
            }, receiveValue: { photos in
                var photos = photos
                photos.sort {
                    return  $0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970
                }
                self.photos = photos
                continuation.resume()
            }).store(in: &cancellables)
        }
    }
    
    func updateFavorite(spotId: String, favorite: Bool) {
        updatingFavorite = true
        spotUseCase.updateSpot(
            spotId: spotId,
            mainImage: nil,
            images: nil,
            title: nil,
            address: nil,
            favorite: favorite,
            star: nil,
            categories: nil,
            memo: nil,
            deleted: nil
        ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.updatingFavorite = false
                self.spot?.favorite = favorite
            }
            case .failure: do {
                self.updatingFavorite = false
            }
            }
        }, receiveValue: {_ in}).store(in: &cancellables)
    }
    
    func updateStar(spotId: String, star: Bool) {
        updatingStar = true
        spotUseCase.updateSpot(
            spotId: spotId,
            mainImage: nil,
            images: nil,
            title: nil,
            address: nil,
            favorite: nil,
            star: star,
            categories: nil,
            memo: nil,
            deleted: nil
        ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.updatingStar = false
                self.spot?.star = star
            }
            case .failure: do {
                self.updatingStar = false
            }
            }
        }, receiveValue: {_ in}).store(in: &cancellables)
    }
    
    func updateTitle(spotId: String, title: String) async -> Bool {
        updating = true
        
        let result: Bool = await withCheckedContinuation { continuation in
            spotUseCase.updateSpot(
                spotId: spotId,
                mainImage: nil,
                images: nil,
                title: title,
                address: nil,
                favorite: nil,
                star: nil,
                categories: nil,
                memo: nil,
                deleted: nil
            ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case .finished: do {
                    self.updating = false
                    self.updatingTitle = false
                    self.spot?.title = title
                    continuation.resume(returning: true)
                }
                case .failure: do {
                    self.updating = false
                    continuation.resume(returning: false)
                }
                }
            }, receiveValue: {_ in}).store(in: &cancellables)
        }
        return result
    }
    
    func updateMemo(spotId: String, memo: String) async -> Bool {
        updating = true
        
        let result: Bool = await withCheckedContinuation { continuation in
            spotUseCase.updateSpot(
                spotId: spotId,
                mainImage: nil,
                images: nil,
                title: nil,
                address: nil,
                favorite: nil,
                star: nil,
                categories: nil,
                memo: memo,
                deleted: nil
            ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case .finished: do {
                    self.updating = false
                    self.updatingMemo = false
                    self.spot?.memo = memo
                    continuation.resume(returning: true)
                }
                case .failure: do {
                    self.updating = false
                    continuation.resume(returning: false)
                }
                }
            }, receiveValue: {_ in}).store(in: &cancellables)
        }
        return result
    }
    
    @MainActor
    func updateAddress(spotId: String, address: String) async -> Bool {
        updating = true
        
        do {
            let _ = try await locationUseCase.geocode(address: address)
            errorMessage = ""
        } catch {
            updating = false
            errorMessage = "住所を入力してください"
            return false
        }
        
        let res: Bool = await withCheckedContinuation { continuation in
            spotUseCase.updateSpot(
                spotId: spotId,
                mainImage: nil,
                images: nil,
                title: nil,
                address: address,
                favorite: nil,
                star: nil,
                categories: nil,
                memo: nil,
                deleted: nil
            ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case .finished: do {
                    self.updating = false
                    self.updatingMemo = false
                    continuation.resume(returning: true)
                }
                case .failure: do {
                    self.updating = false
                    continuation.resume(returning: false)
                }
                }
            }, receiveValue: {(spot, _) in
                self.spot?.address = address
                self.spot?.longitude = spot.longitude
                self.spot?.latitude = spot.latitude
            }).store(in: &cancellables)
        }
        return res
    }
    
    func updateMainImage(spotId: String, image: Data) async -> Bool {
        let res: Bool = await withCheckedContinuation { continuation in
            spotUseCase.updateSpot(
                spotId: spotId,
                mainImage: image,
                images: nil,
                title: nil,
                address: nil,
                favorite: nil,
                star: nil,
                categories: nil,
                memo: nil,
                deleted: nil
            ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case .finished: do {
                    continuation.resume(returning: true)
                }
                case .failure: do {
                    continuation.resume(returning: false)
                }
                }
            }, receiveValue: {(spot, _) in
                self.spot?.imageUrl = spot.imageUrl
            }).store(in: &cancellables)
        }
        return res
    }
    
    func updateCategories(spotId: String, categories: [String]) async -> Bool {
        let res: Bool = await withCheckedContinuation { continuation in
            spotUseCase.updateSpot(
                spotId: spotId,
                mainImage: nil,
                images: nil,
                title: nil,
                address: nil,
                favorite: nil,
                star: nil,
                categories: categories,
                memo: nil,
                deleted: nil
            ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case .finished: do {
                    continuation.resume(returning: true)
                }
                case .failure: do {
                    continuation.resume(returning: false)
                }
                }
            }, receiveValue: {(spot, _) in
                self.spot?.categories = spot.categories
            }).store(in: &cancellables)
        }
        return res
    }
    
    func addPhotos(spotId: String, images: [Asset]) async -> Bool {
        let res: Bool = await withCheckedContinuation { continuation in
            spotUseCase.updateSpot(
                spotId: spotId,
                mainImage: nil,
                images: images,
                title: nil,
                address: nil,
                favorite: nil,
                star: nil,
                categories: nil,
                memo: nil,
                deleted: nil
            ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case .finished: do {
                    continuation.resume(returning: true)
                }
                case .failure: do {
                    continuation.resume(returning: false)
                }
                }
            }, receiveValue: { (spot, photos) in
                var photos = photos
                photos.sort {
                    return  $0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970
                }
                self.photos.insert(contentsOf: photos, at: 0)
            }).store(in: &cancellables)
        }
        return res
    }
    
    func removePhoto(spotId: String, photoId: String, photo: Photo) async -> Bool {
        var photo = photo
        photo.deleted = true
        let res: Bool = await withCheckedContinuation { continuation in
            spotUseCase.updatePhoto(spotId: spotId, photoId: photoId, photo: photo)
                .receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: do {
                        continuation.resume(returning: true)
                    }
                    case .failure: do {
                        continuation.resume(returning: false)
                    }
                    }
                }, receiveValue: {_ in
                    self.photos = self.photos.filter { p in
                        return p.id != photoId
                    }
                }).store(in: &cancellables)
        }
        return res
    }
}
