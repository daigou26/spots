//
//  Created on 2021/12/27
//

import XCTest
import MapKit
@testable import Spots

class LocationUseCaseMock: LocationUseCase {
    func geocode(address: String) async throws -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 100, longitude: 100)
    }
}

class AddSpotViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidateAddress() async throws {
        let addSpotViewModel = AddSpotViewModel(LocationUseCaseMock())
        await addSpotViewModel.validateAddress(address: "TOKYO")
        XCTAssertEqual(addSpotViewModel.addressErrorMessage, "")
    }
}
