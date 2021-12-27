//
//  Created on 2021/11/25
//

import SwiftUI
import MapKit

final class CustomAnnotationView: MKAnnotationView {
    let width = 70
    let height = 80
    
    var subview: UIView? = nil
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "cluster"
        
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        centerOffset = CGPoint(x: 0, y: -height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let sub = subview {
            sub.removeFromSuperview()
        }
        
        var vc: UIHostingController = UIHostingController(rootView: CustomAnnotation(count: 0, imageUrl: "Sample"))
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            let annotations = clusterAnnotation.memberAnnotations
            let spots = annotations.map({ annotation -> Spot? in
                if let customAnnotation = annotation as? CustomPointAnnotation {
                    return customAnnotation.spot
                }
                return nil
            }).compactMap{$0}
            vc = UIHostingController(rootView: CustomAnnotation(count: clusterAnnotation.memberAnnotations.count, imageUrl: spots[0].imageUrl ?? ""))
        } else {
            if let customAnnotation = annotation as? CustomPointAnnotation {
                vc = UIHostingController(rootView: CustomAnnotation(count: 0, imageUrl: customAnnotation.spot.imageUrl ?? ""))
            } else {
                return
            }
        }
        vc.view.bounds = CGRect(x: -width/2, y: -height/2, width: width, height: height)
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        subview = vc.view
        addSubview(vc.view)
    }
}
