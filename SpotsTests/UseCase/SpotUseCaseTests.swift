//
//  Created on 2021/11/27
//

import XCTest
import Combine
@testable import Spots

class SpotRepositoryMock: SpotRepository {
    func getSpot(spotId: String) async throws -> Spot {
        return Spot(title: "", address: "", latitude: 0, longitude: 0, favorite: true, star: true)
    }
    
    func getSpotByAddress(uid: String, address: String) async throws -> [Spot] {
        return []
    }
    
    func getPhotos(spotId: String) async throws -> [Photo] {
        return []
    }
    
    func getNewDocumentId() -> String {
        return ""
    }
    
    func postSpot(uid: String, spot: Spot, assets: [Data]?) async throws {
        return
    }
    
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
        let spotUseCase = SpotUseCaseImpl(spotRepository: SpotRepositoryMock())
        let _ = spotUseCase.getSpots(uid: "").sink(receiveCompletion: { completion in
            switch completion {
            case .finished: break
            case .failure: break
            }
        }, receiveValue: { spots in
            XCTAssertEqual(spots, [])
        })
    }
}
