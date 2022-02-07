//
//  Created on 2021/12/28
//

import SwiftUI

struct SpotDetailView: View {
    @EnvironmentObject var spotsViewModel: SpotsViewModel
    @EnvironmentObject var viewModel: SpotDetailViewModel
    @State var id: String
    @State var imageIndex: Int = 0
    @State var goImageList = false
    @State var refresh = true
    @State var actionDialogEnable = false
    @State var deleteConfirmationDialog = false
    @State var goUpdateMainImageView = false
    @State var goUpdateSpotView = false
    @State var goInputLocationView = false
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    var body: some View {
        VStack {
            if viewModel.loading {
                ProgressView()
                    .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                    .zIndex(1)
            } else {
                if let spot = viewModel.spot {
                    ZStack(alignment: .center) {
                        if spotsViewModel.updating {
                            ProgressView().scaleEffect(x: 1.5, y: 1.5, anchor: .center).progressViewStyle(CircularProgressViewStyle(tint: Color.white)).zIndex(1)
                            Rectangle().fill(Color.black).opacity(0.4).edgesIgnoringSafeArea(.all)
                        }
                        
                        VStack {
                            ZStack(alignment: .bottomTrailing) {
                                if let imageUrl = spot.imageUrl {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(height: height / 4)
                                            .clipped()
                                    } placeholder: {
                                        Rectangle().fill(Color.background)
                                    }
                                } else {
                                    Rectangle().fill(Color.background).frame(height: height / 4)
                                }
                                Button(action: {
                                    goUpdateMainImageView = true
                                }) {
                                    Image(systemName: "photo").font(.system(size: 18).bold()).foregroundColor(.black).frame(width: 35, height: 35).background(Color.white).clipShape(Circle())
                                }.padding()
                            }.frame(height: height / 4)
                            
                            VStack(alignment: .leading) {
                                Text(spot.title).font(.system(size: 20).bold()).padding(.bottom).onTapGesture {
                                    viewModel.updatingTitle = true
                                    goUpdateSpotView = true
                                }
                                HStack {
                                    Image(systemName: "mappin.and.ellipse").font(.system(size: 14))
                                    Text(spot.address).onTapGesture {
                                        goInputLocationView = true
                                    }
                                    Spacer()
                                }
                                
                                Group {
                                    if let memo = spot.memo, memo != "" {
                                        Text(memo).frame(height: 60, alignment: .top)
                                    } else {
                                        Text("メモ...").font(.system(size: 14)).frame(height: 60, alignment: .top).foregroundColor(.background).padding(.vertical)
                                    }
                                }.onTapGesture {
                                    viewModel.updatingMemo = true
                                    goUpdateSpotView = true
                                }
                                
                                if viewModel.imageUploadingStatus != "" {
                                    HStack {
                                        ProgressView().font(.system(size: 14)).padding(.trailing)
                                        Text(viewModel.imageUploadingStatus).foregroundColor(.textGray)
                                    }
                                }
                            }.padding()
                            
                            ScrollView {
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), alignment: .center, spacing: 3) {
                                        ForEach(viewModel.photos.indices, id: \.self) { i in
                                            AsyncImage(url: URL(string: viewModel.photos[i].imageUrl)) { image in
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(width: (width - 25) / 3, height: (width - 25) / 3)
                                                    .cornerRadius(10)
                                            } placeholder: {
                                                Rectangle().fill(.background).frame(width: (width - 25) / 3, height: (width - 25) / 3)
                                            }.onTapGesture {
                                                imageIndex = i
                                                goImageList = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        NavigationLink(destination: UpdateMainImageView().environmentObject(viewModel), isActive: $goUpdateMainImageView) {
                            EmptyView()
                        }
                        NavigationLink(destination: UpdateSpotView().environmentObject(viewModel), isActive: $goUpdateSpotView) {
                            EmptyView()
                        }
                        NavigationLink(destination: InputLocationView(editing: true).environmentObject(viewModel), isActive: $goInputLocationView) {
                            EmptyView()
                        }
                        NavigationLink(destination: SpotImageList(i: imageIndex, photos: viewModel.photos), isActive: $goImageList) {
                            EmptyView()
                        }
                    }
                    .alert(isPresented: $deleteConfirmationDialog) {
                        Alert(title: Text("スポットの削除"),
                              message: Text("データが削除されますがよろしいですか？"),
                              primaryButton: .cancel(Text("キャンセル")),
                              secondaryButton: .destructive(Text("削除"), action: {
                            spotsViewModel.deleteSpot(spotId: id)
                        }))
                    }
                    .confirmationDialog("", isPresented: $actionDialogEnable, titleVisibility: .hidden, actions: {
                        Button("削除", role: .destructive) {
                            deleteConfirmationDialog = true
                        }
                    })
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading){
                            Button(action: {
                                spotsViewModel.goSpotDetailView = false
                                if let spot = viewModel.spot {
                                    spotsViewModel.updateSpot(spotId: id, spot: spot)
                                }
                            }) {
                                Image(systemName: "chevron.left").font(.system(size: 14).bold()).foregroundColor(.black).frame(width: 35, height: 35).background(Color.white).clipShape(Circle())
                            }.disabled(spotsViewModel.updating)
                        }
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button(action: {
                                viewModel.updateStar(spotId: id, star: !spot.star)
                            }) {
                                Image(systemName: spot.star ? "star.fill" : "star").font(.system(size: 16).bold()).foregroundColor(.yellow).frame(width: 35, height: 35).background(Color.white).clipShape(Circle())
                            }.disabled(viewModel.updatingStar || spotsViewModel.updating)
                        }
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button(action: {
                                viewModel.updateFavorite(spotId: id, favorite: !spot.favorite)
                            }) {
                                Image(systemName: spot.favorite ? "heart.fill" : "heart").font(.system(size: 16).bold()).foregroundColor(.pink).frame(width: 35, height: 35).background(Color.white).clipShape(Circle())
                            }.disabled(viewModel.updatingFavorite || spotsViewModel.updating)
                        }
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button(action: {
                                actionDialogEnable = true
                            }) {
                                Image(systemName: "ellipsis").font(.system(size: 16).bold()).foregroundColor(.black).frame(width: 35, height: 35).background(Color.white).clipShape(Circle())
                            }.disabled(spotsViewModel.updating)
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                } else {
                    // If there is not a spot or something wrong
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                // Do not execute when back from ImageList
                if refresh {
                    await viewModel.getSpot(spotId: id)
                    await viewModel.getPhotos(spotId: id)
                    refresh = false
                }
            }
        }
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct SpotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SpotDetailView(id: "").environmentObject(SpotDetailViewModel()).environmentObject(SpotDetailViewModel())
    }
}
