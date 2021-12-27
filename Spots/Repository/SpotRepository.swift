//
//  Created on 2021/11/25
//

import Foundation

protocol SpotRepository {
    func getSpots(uid: String) async throws -> [Spot]?
    func getNewDocumentId() -> String
    func postSpot(uid: String, spot: Spot, assets: [Data]?) async throws
}
