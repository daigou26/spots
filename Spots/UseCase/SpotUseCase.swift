//
//  Created on 2021/11/25
//

import Foundation
import Combine

protocol SpotUseCase {
    func getSpots(uid: String) async -> AnyPublisher<[Spot]?, Error>
}
