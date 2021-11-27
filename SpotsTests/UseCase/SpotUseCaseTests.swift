//
//  Created on 2021/11/27
//

import XCTest
import Combine
@testable import Spots

class SpotRepositoryMock: SpotRepository {
    func getSpots(uid: String) async throws -> [Spot]? {
        return []
    }
}

class SpotsUseCaseTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetSpots() async throws {
        let spotUseCase = SpotUseCaseImpl(SpotRepositoryMock())
        let _ = await spotUseCase.getSpots(uid: "").sink(receiveCompletion: { completion in
            switch completion {
            case .finished: break
            case .failure: break
            }
        }, receiveValue: { spots in
            XCTAssertEqual(spots, [])
        })
    }
}
