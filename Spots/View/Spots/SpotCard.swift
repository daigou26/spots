//
//  Created on 2021/11/25
//

import SwiftUI

struct SpotCard: View {
    @State var spot: Spot
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(spot.title).font(.system(size: 20, weight: .bold)).padding(.bottom, 1)
            Text(spot.address).padding(.bottom, 1)
            if let imageUrl = spot.imageUrl, imageUrl != "" {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable().scaledToFill().frame(height: width / 1.8).clipped().cornerRadius(6)
                } placeholder: {
                    ZStack {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            Spacer()
                        }.zIndex(1)
                        Rectangle().fill(Color.white).scaledToFill().frame(height: width / 1.8).clipped().cornerRadius(6)
                    }
                }
            } else {
                Rectangle().fill(Color.background).scaledToFill().frame(height: width / 1.8).clipped().cornerRadius(6)
            }
        }
    }
}

struct SpotCard_Previews: PreviewProvider {
    static var previews: some View {
        SpotCard(spot: Spot(id: "1", title: "日比谷公園", imageUrl: "Sample", address: "東京都", latitude: 35.68000, longitude: 139.752000, favorite: false, star:false, deleted: false))
    }
}
