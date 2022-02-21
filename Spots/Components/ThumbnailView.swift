//
//  Created on 2021/12/01
//

import SwiftUI

struct ThumbnailView: View {
    var asset: Asset
    var checked: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if checked {
                Image(systemName: "checkmark.square.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30 , height: 30)
                    .foregroundColor(.main)
                    .background(Color.white)
                    .cornerRadius(6)
                    .zIndex(1)
                    .padding(.top, 5)
                    .padding(.trailing, 5)
            }
            Image(uiImage: asset.image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(10)
        }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "checkmark.square.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 30 , height: 30)
                .foregroundColor(.main)
                .background(Color.white)
                .cornerRadius(6)
                .zIndex(1)
                .padding(.top, 5)
                .padding(.trailing, 5)
            Image("Sample").resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .cornerRadius(10)
        }
    }
}
