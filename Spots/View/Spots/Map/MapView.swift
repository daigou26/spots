//
//  Created on 2021/11/15
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @EnvironmentObject var spotsViewModel: SpotsViewModel
    //    @Binding var category: [String]
    @State var spots: [Spot]
    @State var centerCoordinate: CLLocationCoordinate2D
    @Binding var selectedSpots: [Spot]
    @Binding var showSpotListSheet: Bool
    
    
    var annotations = [MKAnnotation]()
    
    init(spots: [Spot], showSpotListSheet: Binding<Bool>, selectedSpots: Binding<[Spot]>) {
        self.centerCoordinate = CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498)
        for spot in spots {
            let newLocation = CustomPointAnnotation(spot: spot)
            newLocation.coordinate = spot.coordinate
            annotations.append(newLocation)
        }
        
        self.spots = spots
        self._showSpotListSheet = showSpotListSheet
        self._selectedSpots = selectedSpots
        //        self._category = category
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView(frame: .zero)
        view.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
        view.delegate = context.coordinator
        view.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        view.mapType = .mutedStandard
        view.setRegion(spotsViewModel.region, animated: true)
        return view
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // exclude MKClusterAnnotation count
        let viewAnnotations = view.annotations.filter { annotation in
            return annotation is CustomPointAnnotation
        }

        if (viewAnnotations.count != annotations.count) {
            if (viewAnnotations.count < annotations.count) {
                view.setRegion(spotsViewModel.region, animated: true)
            }
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations.filter({ annotation in
                guard let annotation = annotation as? CustomPointAnnotation else {return false}
                //            TODO: filtering
                //            return category.contains(annotation.category)
                return true
            }))
        }
    }
    
    func makeCoordinator() -> (Coordinator) {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster", for: annotation)
            view.clusteringIdentifier = "cluster"
            return view
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            for annotation in mapView.selectedAnnotations {
                // Deselect annotation because sometimes select annotation is not working
                mapView.deselectAnnotation(annotation, animated: false)
                
                if let clusterAnnotation = annotation as? MKClusterAnnotation {
                    let annotations = clusterAnnotation.memberAnnotations
                    var spots = annotations.map({ annotation -> Spot? in
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
                    self.parent.selectedSpots = spots
                } else {
                    if let customAnnotation = annotation as? CustomPointAnnotation {
                        self.parent.selectedSpots = [customAnnotation.spot]
                    } else {
                        return
                    }
                }
            }
            
            self.parent.showSpotListSheet = true
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
    }
}

class CustomPointAnnotation: MKPointAnnotation {
    var spot: Spot
    init(spot: Spot) {
        self.spot = spot
    }
}
