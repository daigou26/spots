//
//  Created on 2021/11/27
//

import XCTest
import Combine
@testable import Spots

class SpotUseCaseMock: SpotUseCase {
    func getSpots(uid: String) async -> AnyPublisher<[Spot]?, Error> {
        return Deferred {
            Future { promise in
                return promise(.success([]))
            }
        }.eraseToAnyPublisher()
    }
}

class SpotsViewModelTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetSpots() async throws {
        let expectation = self.expectation(description: #function)
        let spotsViewModel = SpotsViewModel(SpotUseCaseMock())
        await spotsViewModel.getSpots()
        expectation.fulfill()
        await waitForExpectations(timeout: 1)
        XCTAssertEqual(spotsViewModel.spots, [])
        XCTAssertEqual(spotsViewModel.isQueried, true)
    }
}
