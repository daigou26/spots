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
                return promise(.success([Photo(imageUrl: "", name: "", width: 0, height: 0, timestamp: Date(), deleted: false, createdAt: Date())]))
            }
        }.eraseToAnyPublisher()
    }
    
    func getSpot(spotId: String) -> AnyPublisher<Spot, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(Spot(title: "", address: "", latitude: 0, longitude: 0, favorite: true, star: true, deleted: false, createdAt: Date())))
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
    
    func postSpot(mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, categories: [String]?, memo: String) -> AnyPublisher<Spot, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(Spot(title: "", address: "", latitude: 0, longitude: 0, favorite: true, star: true, deleted: false, createdAt: Date())))
            }
        }.eraseToAnyPublisher()
    }
    
    func updateSpot(spotId: String, mainImage: Data?, images: [Asset]?, title: String?, address: String?, favorite: Bool?, star: Bool?, categories: [String]?, memo: String?, deleted: Bool?) -> AnyPublisher<(Spot, [Photo]), Error> {
        return Deferred {
            Future { promise in
                return promise(.success((Spot(title: "", address: "", latitude: 0, longitude: 0, favorite: true, star: true, deleted: false, createdAt: Date()), [])))
            }
        }.eraseToAnyPublisher()
    }
    
    func updatePhoto(spotId: String, photoId: String, photo: Photo) -> AnyPublisher<Photo, Error> {
        return Deferred {
            Future { promise in
                return promise(.success(Photo(imageUrl: "", name: "", width: 0, height: 0, timestamp: Date(), deleted: false, createdAt: Date())))
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
        XCTAssertEqual(spotsViewModel.queried, true)
    }
    
    func testpostSpot() async throws {
        let expectation = self.expectation(description: #function)
        let spotsViewModel = SpotsViewModel(SpotUseCaseMock())
        XCTAssertEqual(spotsViewModel.spots.count, 0)
        spotsViewModel.postSpot(mainImage: nil, images: nil, title: "", address: "", favorite: false, star: false, categories: [], memo: "")
        expectation.fulfill()
        await waitForExpectations(timeout: 1)
        XCTAssertEqual(spotsViewModel.spots.count, 1)
    }
}
