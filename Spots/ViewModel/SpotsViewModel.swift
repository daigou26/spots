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
    @Published var queried: Bool = false
    @Published var updated: Bool = false
    @Published var goSpotsView: Bool = false
    @Published var goSpotDetailView: Bool = false
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    @Published var selectedAnnotations: [MKAnnotation] = []
    @Published var updating: Bool = false
    
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
                return  $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970
            }
            return spots
        }
    }

    func getSpots() {
        spotUseCase.getSpots().receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.queried = true
            }
            case .failure: break
            }
        }, receiveValue: { spots in
            self.spots = spots ?? []
        }).store(in: &cancellables)
    }
    
    func refreshSpots() {
        spots = []
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
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
    
    func deleteSpot(spotId: String) {
        updating = true
        spotUseCase.updateSpot(
            spotId: spotId,
            mainImage: nil,
            images: nil,
            title: nil,
            address: nil,
            favorite: nil,
            star: nil,
            memo: nil,
            deleted: true
        ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.spots = self.spots.filter { spot in
                    return spot.id != spotId
                }
                self.updating = false
                self.goSpotDetailView = false
            }
            case .failure: do {
                self.updating = false
            }
            }
        }, receiveValue: {_ in}).store(in: &cancellables)
    }
    
    // Update UI
    func updateSpot(spotId: String, spot: Spot) {
        spots = spots.map { s in
            if s.id == spot.id {
                return spot
            }
            return s
        }
        updated = true
    }
}
