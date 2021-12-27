//
//  Created on 2021/12/01
//

import Foundation
import UIKit

class AddSpotViewModel: ObservableObject {
    @Published var mainImage: UIImage? = nil
    @Published var images: [Asset] = []
    @Published var address: String = ""
    @Published var addressErrorMessage: String = ""
    @Published var loading: Bool = false
    
    private var locationUseCase: LocationUseCase
    
    init(_ locationUseCase: LocationUseCase = LocationUseCaseImpl()) {
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
    
    func setLoading(value: Bool) {
        self.loading = value
    }
}
