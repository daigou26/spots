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
        }).store(in: &cancellables)
    }
}
