//
//  Created on 2021/11/25
//

import Foundation
import Combine
import SwiftUI
import UIKit
import MapKit

class SpotsViewModel: ObservableObject {
    let generator = UINotificationFeedbackGenerator()
    @Published var spots: [Spot] = []
    @Published var showAddSpotSheet: Bool = false
    @Published var showSpotListSheet: Bool = false
    @Published var isQueried: Bool = false
    @Published var goSpotsView: Bool = false
    @Published var goSpotDetailView: Bool = false
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    @Published var selectedAnnotations: [MKAnnotation] = []
    
    private var spotUseCase: SpotUseCase
    var cancellables = [AnyCancellable]()
    
    init(_ spotUseCase: SpotUseCase = SpotUseCaseImpl()) {
        self.spotUseCase = spotUseCase
    }
    
    func getSelectedSpots() -> [Spot] {
        if selectedAnnotations.count == 0 {
            return []
        } else {
            var spots = selectedAnnotations.map({ annotation -> Spot? in
                if let customAnnotation = annotation as? CustomPointAnnotation {
                    return customAnnotation.spot
                }
                return nil
            }).compactMap{$0}
            spots.sort {
                if let c0 = $0.createdAt, let c1 = $1.createdAt {
                  return  c0.timeIntervalSince1970 > c1.timeIntervalSince1970
                }
                return false
            }
            return spots
        }
    }

    func getSpots() {
        spotUseCase.getSpots().receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.isQueried = true
            }
            case .failure: break
            }
        }, receiveValue: { spots in
            self.spots = spots ?? []
        }).store(in: &cancellables)
    }
    
    func refreshSpots() {
        self.spots = []
        getSpots()
    }
    
    func postSpot(mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, memo: String) {
        spotUseCase.postSpot(mainImage: mainImage, images: images, title: title, address: address, favorite: favorite, star: star, memo: memo).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.showAddSpotSheet = false
            }
            case .failure: break
            }
        }, receiveValue: { spot in
            self.spots.insert(spot, at: 0)
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
            self.generator.notificationOccurred(.success)
        }).store(in: &cancellables)
    }
}
