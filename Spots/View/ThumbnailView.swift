//
//  Created on 2021/12/01
//

import SwiftUI

struct ThumbnailView: View {
    var photo: Asset
    var width: CGFloat
    var height: CGFloat
    var checked: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if checked {
                Image(systemName: "checkmark.square.fill")
                    .resizable()
                    .frame(width: 30 , height: 30)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.main)
                    .background(Color.white)
                    .cornerRadius(6)
                    .zIndex(1)
                    .padding(.top, 5)
                    .padding(.trailing, 5)
            }
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .cornerRadius(10)
        }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "checkmark.square.fill").resizable().frame(width: 30 , height: 30).aspectRatio(contentMode: .fill).foregroundColor(.main).background(Color.white).cornerRadius(6).zIndex(1).padding(.top, 5).padding(.trailing, 5)
            Image("Sample").resizable()
                .aspectRatio(contentMode: .fill).frame(width: 150, height: 150)
                .cornerRadius(10)
        }
    }
}
