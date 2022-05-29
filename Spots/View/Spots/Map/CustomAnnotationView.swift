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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let sub = subview {
            sub.removeFromSuperview()
        }
        
        var vc: UIHostingController = UIHostingController(rootView: CustomAnnotation(count: 0, imageUrl: ""))
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            
            let annotations = clusterAnnotation.memberAnnotations
            var spots = annotations.map({ annotation -> Spot? in
                if let customAnnotation = annotation as? CustomPointAnnotation {
                    return customAnnotation.spot
                }
                return nil
            }).compactMap{$0}
            spots.sort {
                return  $0.createdAt.timeIntervalSince1970 > $1.createdAt.timeIntervalSince1970
            }
            
            var categoryColor = ""
            if let category = spots[0].categories?.first {
                categoryColor = getCategoryColor(categoryId: category)
            }

            vc = UIHostingController(rootView: CustomAnnotation(count: clusterAnnotation.memberAnnotations.count, imageUrl: spots[0].imageUrl ?? "", categoryColor: categoryColor))
        } else {
            if let customAnnotation = annotation as? CustomPointAnnotation {
                var categoryColor = ""
                if let category = customAnnotation.spot.categories?.first {
                    categoryColor = getCategoryColor(categoryId: category)
                }
                vc = UIHostingController(rootView: CustomAnnotation(count: 0, imageUrl: customAnnotation.spot.imageUrl ?? "", categoryColor: categoryColor))
            } else {
                return
            }
        }

        vc.view.frame = bounds
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        subview = vc.view
        addSubview(vc.view)
    }
    
    func getCategoryColor(categoryId: String) -> String {
        var categoryColor = ""
        let filteredCategories = Account.shared.categories.filter { c in
            return c.id == categoryId
        }
        
        if !filteredCategories.isEmpty {
            categoryColor = filteredCategories[0].color
        }
        return categoryColor
    }
}
