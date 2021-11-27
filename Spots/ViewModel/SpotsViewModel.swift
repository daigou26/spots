//
//  Created on 2021/11/25
//

import Foundation
import Combine

class SpotsViewModel: NSObject, ObservableObject {
    @Published var spots: [Spot] = []
    @Published var isQueried: Bool = false
    
    
    private var spotUseCase: SpotUseCase
    var cancellables = [AnyCancellable]()
    
    init(_ spotUseCase: SpotUseCase = SpotUseCaseImpl()) {
        self.spotUseCase = spotUseCase
    }
    
    func getSpots() async {
        await spotUseCase.getSpots(uid: Account.shared.uid).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
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
    
    func refreshSpots() async {
        self.spots = []
        await getSpots()
    }
}
