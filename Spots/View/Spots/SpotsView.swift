//
//  Created on 2021/11/25
//

import SwiftUI

struct SpotsView: View {
    @EnvironmentObject var viewModel: SpotsViewModel
    @State var showSpotListSheet: Bool = false
    @State var goDetailView: Bool = false
    @State var spotId: String = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack {
                    Button("Refresh") {
                        viewModel.refreshSpots()
                    }.buttonStyle(RefreshButtonStyle())
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.showAddSpotSheet = true
                        }) {
                            Image(systemName: "mappin.and.ellipse")
                        }.buttonStyle(AddButtonStyle()).sheet(isPresented: $viewModel.showAddSpotSheet) {
                            SelectMainImageView().environmentObject(AddSpotViewModel()).environmentObject(ImagePickerViewModel())
                        }
                    }
                }.zIndex(1)
                
                NavigationLink(destination: SpotDetailView(id: spotId).environmentObject(SpotDetailViewModel()), isActive: $viewModel.goSpotDetailView) {
                    EmptyView()
                }
                
                MapView(spots: viewModel.spots, showSpotListSheet: $showSpotListSheet).edgesIgnoringSafeArea(.top)
            }.navigationBarHidden(true).partialSheet(isPresented: $showSpotListSheet, sheet: {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        Text("スポット\(viewModel.selectedAnnotations.count)件").font(.system(size: 20, weight: .bold)).padding(.bottom, 30)
                        ForEach(viewModel.getSelectedSpots(), id: \.self) { spot in
                            if let spotId = spot.id {
                                SpotCard(spot: spot).padding(.bottom, 28).onTapGesture {
                                    self.showSpotListSheet = false
                                    self.spotId = spotId
                                    self.viewModel.goSpotDetailView = true
                                }
                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.frame(maxWidth: .infinity).padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
            }, onEnd: {}).onAppear {
                // To query only one time
                if !viewModel.queried {
                    viewModel.getSpots()
                }
            }
        }.accentColor(.black) 
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

struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: 50, maxHeight: 50)
            .background(Color.main)
            .cornerRadius(25)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
            .shadow(radius: 7)
    }
}

struct SpotsView_Previews: PreviewProvider {
    static var previews: some View {
        SpotsView().environmentObject(SpotsViewModel())
    }
}
