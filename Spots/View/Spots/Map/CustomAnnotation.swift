//
//  Created on 2021/11/25
//

import SwiftUI

struct CustomAnnotation: View {
    var count: Int
    var imageUrl: String
    
    let imageSize = 70.0
    
    var body: some View {
        VStack {
            ZStack {
                if count > 1 {
                    Text(String(count)).foregroundColor(.white).frame(width: 30, height: 30).background(Color.main).clipShape(Circle()).zIndex(1).overlay {
                        Circle().stroke(.white, lineWidth: 1)
                    }.offset(x: countCoordinate, y: -countCoordinate)
                }
                AsyncImage(url: URL(string: imageUrl)){ image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color.background)
                }.frame(width: imageSize, height: imageSize)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.white, lineWidth: 3)
                    }
                    .shadow(radius: 7)
            }
            Triangle().fill(Color.white)
                .frame(width: 30, height: 8)
                .shadow(radius: 7)
        }
    }
    
    var countCoordinate: CGFloat {
        return imageSize * sqrt(2) / 4 + 2
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

struct CustomAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        CustomAnnotation(count: 2, imageUrl: "Sample")
    }
}
