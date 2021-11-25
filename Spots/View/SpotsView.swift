//
//  Created on 2021/11/25
//

import SwiftUI

struct SpotsView: View {
    @State var spots: [Spot] = [Spot]()
    @State var showModal: Bool = false
    
    var body: some View {
        ZStack {
            MapView(showModal: $showModal, selectedSpots: $spots).edgesIgnoringSafeArea(.top)
        }.halfModal(isPresented: $showModal, sheet: {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("スポット\(spots.count)件").font(.system(size: 20, weight: .bold)).padding(.bottom, 30)
                    ForEach(spots, id: \.self) { spot in
                        SpotCard(spot: spot).padding(.bottom, 28)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity).padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
        }, onEnd: {
            showModal = false
        })
    }
}

struct SpotsView_Previews: PreviewProvider {
    static var previews: some View {
        SpotsView()
    }
}
