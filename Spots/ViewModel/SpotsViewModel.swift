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
    @Published var filteredSpots: [Spot] = []
    @Published var showAddSpotSheet: Bool = false
    @Published var showSpotListSheet: Bool = false
    @Published var queried: Bool = false
    @Published var added: Bool = false // Use to set region
    @Published var updated: Bool = false // Use to update MapView
    @Published var goSpotsView: Bool = false
    @Published var goSpotDetailView: Bool = false
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    @Published var selectedAnnotations: [MKAnnotation] = []
    @Published var updating: Bool = false
    
    @Published var favoriteFilter = false
    @Published var starFilter = false
    @Published var categories = Account.shared.categories
    @Published var categoriesFilter: [Category] = []
    
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
    
    func isFiltered() -> Bool {
        return favoriteFilter || starFilter || categoriesFilter.count > 0
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
        getSpots()
    }
    
    func postSpot(mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, categories: [String], memo: String) {
        spotUseCase.postSpot(
            mainImage: mainImage,
            images: images,
            title: title,
            address: address,
            favorite: favorite,
            star: star,
            categories: categories,
            memo: memo
        ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.showAddSpotSheet = false
            }
            case .failure: break
            }
        }, receiveValue: { spot in
            self.spots.insert(spot, at: 0)
            self.updateSpots()
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
            self.added = true
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
            categories: nil,
            memo: nil,
            deleted: true
        ).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
            switch completion {
            case .finished: do {
                self.spots = self.spots.filter { spot in
                    return spot.id != spotId
                }
                self.updateSpots()
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
    
    func updateSpots() {
        filteredSpots = spots.map { s in
            if favoriteFilter, !s.favorite {
                return nil
            }
            if starFilter, !s.star {
                return nil
            }
            if categoriesFilter.count > 0 {
                if let spotCategories = s.categories, spotCategories.count > 0 {
                    if !spotCategories.contains(where: { c in
                        categoriesFilter.map{ $0.id }.contains(c)
                    }) {
                        return nil
                    }
                } else {
                    return nil
                }
            }
            
            return s
        }.compactMap {$0}
        updated = true
    }
}
