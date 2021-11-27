//
//  Created on 2021/11/25
//

import Foundation
import Combine

class SpotUseCaseImpl: SpotUseCase {
    let spotRepository: SpotRepository
    
    init(_ spotRepository: SpotRepository = SpotRepositoryImpl()) {
        self.spotRepository = spotRepository
    }
    
    func getSpots(uid: String) async -> AnyPublisher<[Spot]?, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let res: [Spot]? = try await self.spotRepository.getSpots(uid: uid)
                        promise(.success(res))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
