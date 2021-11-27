//
//  Created on 2021/11/25
//

import Foundation

protocol SpotRepository {
    func getSpots(uid: String) async throws -> [Spot]?
}
