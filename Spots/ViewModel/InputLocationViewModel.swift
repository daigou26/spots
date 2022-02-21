//
//  Created on 2021/12/18
//

import Foundation

//class InputLocationViewModel: ObservableObject {
//    @Published var errorMessage: String = ""
//    private var locationUseCase: LocationUseCase
//    
//    init(_ locationUseCase: LocationUseCase = LocationUseCaseImpl()) {
//        self.locationUseCase = locationUseCase
//    }
//   
//    @MainActor
//    func validate(address: String) {
//        do {
//            let coordinate = try await locationUseCase.geocode(address: address)
//            if coordinate != nil {
//                errorMessage = ""
//            } else {
//                errorMessage = "住所を入力してください"
//            }
//        } catch {
//            errorMessage = "住所を入力してください"
//        }
//    }
//}
