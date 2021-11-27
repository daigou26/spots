//
//  Created on 2021/11/15
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    //    @Binding var category: [String]
    @State var spots: [Spot]
    @State var centerCoordinate: CLLocationCoordinate2D
    @Binding var selectedSpots: [Spot]
    @Binding var showModal: Bool
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    
    var annotations = [MKAnnotation]()
    
    init(spots: [Spot], showModal: Binding<Bool>, selectedSpots: Binding<[Spot]>) {
        self.centerCoordinate = CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498)
        for spot in spots {
            let newLocation = CustomPointAnnotation(spot: spot)
            newLocation.coordinate = spot.coordinate
            annotations.append(newLocation)
        }
        
        self.spots = spots
        self._showModal = showModal
        self._selectedSpots = selectedSpots
        //        self._category = category
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView(frame: .zero)
        view.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
        view.delegate = context.coordinator
        view.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        view.mapType = .mutedStandard
        view.setRegion(region, animated: true)
        return view
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // exclude MKClusterAnnotation count
        let viewAnnotations = view.annotations.filter { annotation in
            return annotation is CustomPointAnnotation
        }

        if (viewAnnotations.count != annotations.count) {
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
                    let spots = annotations.map({ annotation -> Spot? in
                        if let customAnnotation = annotation as? CustomPointAnnotation {
                            return customAnnotation.spot
                        }
                        return nil
                    }).compactMap{$0}
                    self.parent.selectedSpots = spots
                } else {
                    if let customAnnotation = annotation as? CustomPointAnnotation {
                        self.parent.selectedSpots = [customAnnotation.spot]
                    } else {
                        return
                    }
                }
            }
            
            self.parent.showModal = true
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
