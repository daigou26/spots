//
//  Created on 2021/11/25
//

import Foundation
import Combine
import SwiftUI
import UIKit

class SpotsViewModel: ObservableObject {
    @Published var spots: [Spot] = []
    @Published var selectedSpots: [Spot] = []
    @Published var showAddSpotSheet: Bool = false
    @Published var isQueried: Bool = false
    @Published var goSpotsView: Bool = false
    
    private var spotUseCase: SpotUseCase
    var cancellables = [AnyCancellable]()
    
    init(_ spotUseCase: SpotUseCase = SpotUseCaseImpl()) {
        self.spotUseCase = spotUseCase
    }
    
    func setShowAddSpotSheet(_ value: Bool) {
        self.showAddSpotSheet = value
    }
    
    func getSpots() {
        spotUseCase.getSpots().receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.isQueried = true
            }
            case .failure: break
            }
        }, receiveValue: { spots in
            self.spots = spots ?? []
        }).store(in: &cancellables)
    }
    
    func refreshSpots() {
        self.spots = []
        getSpots()
    }
    
    func postSpot(mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, memo: String) {
        spotUseCase.postSpot(mainImage: mainImage, images: images, title: title, address: address, favorite: favorite, star: star, memo: memo).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.showAddSpotSheet = false
            }
            case .failure: break
            }
        }, receiveValue: { spot in
            self.spots.append(spot)
        }).store(in: &cancellables)
    }
}
