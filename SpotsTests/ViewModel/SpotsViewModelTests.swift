//
//  Created on 2021/11/27
//

import XCTest
import Combine
@testable import Spots

class SpotUseCaseMock: SpotUseCase {
    func getPhotos(spotId: String) -> AnyPublisher<[Photo], Error> {
        return Deferred {
            Future { promise in
                return promise(.success([Photo(imageUrl: "", name: "", timestamp: Date())]))
            }
        }.eraseToAnyPublisher()
    }
    
    func getSpot(spotId: String) -> AnyPublisher<Spot, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(Spot(title: "", address: "", latitude: 0, longitude: 0, favorite: true, star: true)))
            }
        }.eraseToAnyPublisher()
    }
    
    func checkSpotDuplication(title: String, address: String) -> AnyPublisher<CheckSpotDuplicationResponse, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(.TitleAndAddress))
            }
        }.eraseToAnyPublisher()
    }
    
    func getSpots() -> AnyPublisher<[Spot]?, Error> {
        return Deferred {
            Future { promise in
                return promise(.success([]))
            }
        }.eraseToAnyPublisher()
    }
    
    func postSpot(mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, memo: String) -> AnyPublisher<Spot, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(Spot(title: "", address: "", latitude: 0, longitude: 0, favorite: true, star: true)))
            }
        }.eraseToAnyPublisher()
    }
    
    func updateSpot(spotId: String, mainImage: Data?, images: [Asset]?, title: String?, address: String?, favorite: Bool?, star: Bool?, memo: String?) -> AnyPublisher<Void, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(()))
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
    
    func testpostSpot() async throws {
        let expectation = self.expectation(description: #function)
        let spotsViewModel = SpotsViewModel(SpotUseCaseMock())
        XCTAssertEqual(spotsViewModel.spots.count, 0)
        spotsViewModel.postSpot(mainImage: nil, images: nil, title: "", address: "", favorite: false, star: false, memo: "")
        expectation.fulfill()
        await waitForExpectations(timeout: 1)
        XCTAssertEqual(spotsViewModel.spots.count, 1)
    }
}
