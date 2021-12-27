//
//  Created on 2021/12/27
//

import XCTest
@testable import Spots

class LocationUseCaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testGeocode() async throws {
        let locationUseCase = LocationUseCaseImpl()
        let coordinate = try await locationUseCase.geocode(address: "TOKYO")
        XCTAssertNotNil(coordinate)
    }

}
