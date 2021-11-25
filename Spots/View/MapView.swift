//
//  Created on 2021/11/15
//

import SwiftUI
import MapKit

final class CustomAnnotationView: MKAnnotationView {
    
    var subview: UIView? = nil
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "cluster"
        
        frame = CGRect(x: 0, y: 0, width: 100, height: 114)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let sub = subview {
            sub.removeFromSuperview()
        }
        
        var vc: UIHostingController = UIHostingController(rootView: CustomAnnotation(count: 0, imageUrl: "Sample", spots: []))
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            let annotations = clusterAnnotation.memberAnnotations
            let spots = annotations.map({ annotation -> Spot? in
                if let customAnnotation = annotation as? CustomPointAnnotation {
                    return customAnnotation.spot
                }
                return nil
            }).compactMap{$0}
            vc = UIHostingController(rootView: CustomAnnotation(count: clusterAnnotation.memberAnnotations.count, imageUrl: spots[0].imageUrl, spots: spots))
        } else {
            if let customAnnotation = annotation as? CustomPointAnnotation {
                vc = UIHostingController(rootView: CustomAnnotation(count: 0, imageUrl: customAnnotation.spot.imageUrl, spots: [customAnnotation.spot]))
            } else {
                return
            }
        }
        vc.view.bounds = CGRect(x: -50, y: -50, width: 100, height: 114)
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        subview = vc.view
        addSubview(vc.view)
    }
}

struct MapView: UIViewRepresentable {
//    @Binding var category: [String]
    @State var centerCoordinate: CLLocationCoordinate2D
    @Binding var selectedSpots: [Spot]
    @Binding var showModal: Bool
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    let spotList = [
        Spot(id: "1", title: "日比谷公園", address: "東京都日比谷", imageUrl: "Sample", favorite: false, star:false,  latitude: 35.68000, longitude: 139.752000),
        Spot(id: "2", title: "井の頭公園", address: "東京都世田谷区", imageUrl: "Sample", favorite: false, star:false,  latitude: 35.68900, longitude: 139.752900),
    ]
    var annotations = [MKAnnotation]()
    
    init(showModal: Binding<Bool>, selectedSpots: Binding<[Spot]>) {
        self.centerCoordinate = CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498)
        let newLocation = CustomPointAnnotation(spot: spotList[0])
        newLocation.coordinate = CLLocationCoordinate2D(latitude: 35.68154, longitude: 139.752498)
        annotations.append(newLocation)
        
        let newLocation2 = CustomPointAnnotation(spot: spotList[1])
        newLocation2.coordinate = CLLocationCoordinate2D(latitude: 35.68000, longitude: 139.752000)
        annotations.append(newLocation2)
        
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
        return view
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)
        view.removeAnnotations(view.annotations)
        view.addAnnotations(annotations.filter({ annotation in
            guard let annotation = annotation as? CustomPointAnnotation else {return false}
//            TODO: filtering
//            return category.contains(annotation.category)
            return true
        }))
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

struct CustomAnnotation: View {
    var count: Int
    var imageUrl: String
    var spots: [Spot]
    var body: some View {
        VStack {
            ZStack {
                if count > 1 {
                    Text(String(count)).foregroundColor(.white).frame(width: 30, height: 30).background(Color.main).clipShape(Circle()).zIndex(1).overlay {
                        Circle().stroke(.white, lineWidth: 1)
                    }.offset(x: countCoordinate, y: -countCoordinate)
                }
                Image(imageUrl).resizable().scaledToFill().frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.white, lineWidth: 3)
                    }
                    .shadow(radius: 7)
            }
            Triangle().fill(Color.white)
                .frame(width: 30, height: 14)
                .shadow(radius: 7)
        }
    }
    
    var countCoordinate: CGFloat {
        return 40 * sqrt(2) / 2 + 2
    }
}

class CustomPointAnnotation: MKPointAnnotation {
    var spot: Spot
    init(spot: Spot) {
        self.spot = spot
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY * 3/4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}
