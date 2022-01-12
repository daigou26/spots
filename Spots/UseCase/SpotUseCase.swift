//
//  Created on 2021/11/25
//

import Foundation
import Combine

protocol SpotUseCase {
    func getSpot(spotId: String) -> AnyPublisher<Spot, Error>
    func checkSpotDuplication(title: String, address: String) -> AnyPublisher<CheckSpotDuplicationResponse, Error>
    func getSpots() -> AnyPublisher<[Spot]?, Error>
    func postSpot(mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, memo: String) -> AnyPublisher<Spot, Error>
}
