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
    @Published var photos: [Photo] = []
    @Published var imageUploadingStatus: String = ""
    @Published var updatingFavorite: Bool = false
    @Published var updatingStar: Bool = false
    
    private var spotUseCase: SpotUseCase
    var cancellables = [AnyCancellable]()
    
    init(_ spotUseCase: SpotUseCase = SpotUseCaseImpl()) {
        self.spotUseCase = spotUseCase
    }
    
    func getSpot(spotId: String) {
        self.loading = true
        spotUseCase.getSpot(spotId: spotId).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.loading = false
            }
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
        }).store(in: &cancellables)
    }
    
    func getPhotos(spotId: String) {
        spotUseCase.getPhotos(spotId: spotId).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: break
            case .failure: break
            }
        }, receiveValue: { photos in
            self.photos = photos
        }).store(in: &cancellables)
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
            memo: nil,
            deleted: nil
        ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.updatingFavorite = false
                self.spot?.favorite = favorite
            }
            case .failure: break
            }
        }, receiveValue: {}).store(in: &cancellables)
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
            memo: nil,
            deleted: nil
        ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.updatingStar = false
                self.spot?.star = star
            }
            case .failure: break
            }
        }, receiveValue: {}).store(in: &cancellables)
    }
}
