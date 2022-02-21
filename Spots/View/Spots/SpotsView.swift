//
//  Created on 2021/11/25
//

import SwiftUI

struct SpotsView: View {
    @EnvironmentObject var viewModel: SpotsViewModel
    @State var showSpotListSheet: Bool = false
    @State var goDetailView: Bool = false
    @State var showCategoriesFilter = false
    @State var spotId: String = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack {
                    ScrollView(.horizontal) {
                        HStack {
                            Button {
                                viewModel.refreshSpots()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.textGray2)
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.all, 10)
                            }.buttonStyle(RefreshButtonStyle())
                            
                            Button {
                                if viewModel.favoriteFilter {
                                    viewModel.favoriteFilter = false
                                    viewModel.updateSpots()
                                } else {
                                    viewModel.favoriteFilter = true
                                    viewModel.updateSpots()
                                }
                            } label: {
                                Text("お気に入り").padding(.all, 10)
                            }
                            .foregroundColor(viewModel.favoriteFilter ? .white : .textGray2)
                            .background(viewModel.favoriteFilter ? Color.main : Color.white)
                            .cornerRadius(20)
                            .padding(.top, 20)
                            
                            Button {
                                if viewModel.starFilter {
                                    viewModel.starFilter = false
                                    viewModel.updateSpots()
                                } else {
                                    viewModel.starFilter = true
                                    viewModel.updateSpots()
                                }
                            } label: {
                                Text("行きたい").padding(.all, 10)
                            }
                            .foregroundColor(viewModel.starFilter ? .white : .textGray2)
                            .background(viewModel.starFilter ? Color.main : Color.white)
                            .cornerRadius(20)
                            .padding(.top, 20)
                            
                            if viewModel.categories.count > 0 {
                                Button {
                                    showCategoriesFilter = true
                                } label: {
                                    if viewModel.categoriesFilter.count > 0 {
                                        Text(viewModel.categoriesFilter.count == 1 ? viewModel.categoriesFilter[0].name : "カテゴリー： \(viewModel.categoriesFilter.count)").padding(.all, 10)
                                    } else {
                                        Text("カテゴリー").padding(.all, 10)
                                    }
                                }
                                .foregroundColor(viewModel.categoriesFilter.count > 0 ? .white : .textGray2)
                                .background(viewModel.categoriesFilter.count > 0 ? Color.main : Color.white)
                                .cornerRadius(20)
                                .padding(.top, 20)
                            }
                        }
                    }.padding(.horizontal, 20)
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
                
                MapView(spots: viewModel.isFiltered() ? viewModel.filteredSpots : viewModel.spots, showSpotListSheet: $showSpotListSheet).edgesIgnoringSafeArea(.top)
            }
            .navigationBarHidden(true)
            .partialSheet(isPresented: $showSpotListSheet, sheet: {
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
            .partialSheet(isPresented: $showCategoriesFilter, sheet: {
                CategoriesFilterView(showCategoriesFilter: $showCategoriesFilter).environmentObject(viewModel)
            }, onEnd: {})
        }
    }
}

struct RefreshButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(Color.white)
            .cornerRadius(20)
            .padding(.top, 20)
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
