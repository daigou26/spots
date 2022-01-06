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

    func setMainImage(_ image: UIImage) {
        self.mainImage = image
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
    
    func setAddress(_ address: String) {
        self.address = address
    }
    
    func setTitle(_ title: String) {
        self.title = title
    }
    
    func setLoading(value: Bool) {
        self.loading = value
    }
    
    func setDuplicatedTitleAndAddress(value: Bool) {
        self.duplicatedTitleAndAddress = value
    }
    
    func setDuplicatedAddress(value: Bool) {
        self.duplicatedAddress = value
    }
    
    func checkToExistsSameAddressSpot(postSpot: @escaping () -> Void) {
        spotUseCase.checkSpotDuplication(uid: Account.shared.uid, title: title, address: address).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
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
