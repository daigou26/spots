//
//  Created on 2021/11/25
//

import SwiftUI

struct SpotsView: View {
    @ObservedObject var viewModel: SpotsViewModel
    @State var selectedSpots: [Spot] = [Spot]()
    @State var showModal: Bool = false
    
    init() {
        viewModel = SpotsViewModel()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Button("Refresh") {
                Task {
                    await self.viewModel.refreshSpots()
                }
            }.buttonStyle(RefreshButtonStyle()).zIndex(1)
            MapView(spots: viewModel.spots, showModal: $showModal, selectedSpots: $selectedSpots).edgesIgnoringSafeArea(.top)
        }.halfModal(isPresented: $showModal, sheet: {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("スポット\(selectedSpots.count)件").font(.system(size: 20, weight: .bold)).padding(.bottom, 30)
                    ForEach(selectedSpots, id: \.self) { spot in
                        SpotCard(spot: spot).padding(.bottom, 28)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity).padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
        }, onEnd: {
            showModal = false
        }).onAppear {
            // Can query only one time
            if !viewModel.isQueried {
                Task {
                    await self.viewModel.getSpots()
                }
            }
        }
    }
}

struct RefreshButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: 110, maxHeight: 45)
            .background(Color.main)
            .cornerRadius(20)
            .padding(.top, 20)
            .shadow(radius: 7)
    }
}

struct SpotsView_Previews: PreviewProvider {
    static var previews: some View {
        SpotsView()
    }
}
