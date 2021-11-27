//
//  Created on 2021/11/25
//

import SwiftUI

struct SpotCard: View {
    @State var spot: Spot
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(spot.title).font(.system(size: 20, weight: .bold)).padding(.bottom, 1)
            Text(spot.address).padding(.bottom, 1)
            AsyncImage(url: URL(string: spot.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }.aspectRatio(1.8, contentMode: .fit).clipped().cornerRadius(6)
        }
    }
}

struct SpotCard_Previews: PreviewProvider {
    static var previews: some View {
        SpotCard(spot: Spot(id: "1", title: "日比谷公園", imageUrl: "Sample", address: "東京都", latitude: 35.68000, longitude: 139.752000, favorite: false, star:false))
    }
}
