//
//  Created on 2021/11/27
//

import XCTest
import Combine
@testable import Spots

class SpotUseCaseMock: SpotUseCase {
    func getSpots(uid: String) -> AnyPublisher<[Spot]?, Error> {
        return Deferred {
            Future { promise in
                return promise(.success([]))
            }
        }.eraseToAnyPublisher()
    }
    
    func postSpot(uid: String, mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, memo: String) -> AnyPublisher<Spot, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(Spot(title: "", address: "", latitude: 0, longitude: 0, favorite: true, star: true)))
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
        spotsViewModel.getSpots()
        expectation.fulfill()
        await waitForExpectations(timeout: 1)
        XCTAssertEqual(spotsViewModel.spots, [])
        XCTAssertEqual(spotsViewModel.isQueried, true)
    }
}
