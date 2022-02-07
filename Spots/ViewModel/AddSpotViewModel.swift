//
//  Created on 2021/12/01
//

import Foundation
import Combine
import UIKit

class AddSpotViewModel: ObservableObject {
    @Published var mainImage: UIImage? = nil
    @Published var images: [Asset] = []
    @Published var title: String = ""
    @Published var address: String = ""
    @Published var addressErrorMessage: String = ""
    @Published var favorite = false
    @Published var star = false
    @Published var memo: String = ""
    @Published var loading: Bool = false
    @Published var duplicatedTitleAndAddress: Bool = false  // Whether same title and address spot exists
    @Published var duplicatedAddress: Bool = false  // Whether same address spot exists
    
    private var spotUseCase: SpotUseCase
    private var locationUseCase: LocationUseCase
    var cancellables = [AnyCancellable]()
    
    init(spotUseCase: SpotUseCase = SpotUseCaseImpl(), locationUseCase: LocationUseCase = LocationUseCaseImpl()) {
        self.spotUseCase = spotUseCase
        self.locationUseCase = locationUseCase
    }
    
    func addImages(_ newImages: [Asset]) {
        for image in newImages {
            self.images.append(image)
        }
    }
    
    @MainActor
    func validateAddress(address: String) async {
        do {
            let _ = try await locationUseCase.geocode(address: address)
            addressErrorMessage = ""
        } catch {
            addressErrorMessage = "住所を入力してください"
        }
    }
    
    func checkToExistsSameAddressSpot(postSpot: @escaping () -> Void) {
        spotUseCase.checkSpotDuplication(title: title, address: address).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: break
            case .failure: break
            }
        }, receiveValue: { res in
            switch res {
            case .TitleAndAddress:
                self.duplicatedTitleAndAddress = true
            case .Address:
                self.duplicatedAddress = true
            case .NotDuplicated:
                postSpot()
            }
            
        }).store(in: &cancellables)
    }
}
