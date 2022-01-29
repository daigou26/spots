//
//  Created on 2021/12/28
//

import SwiftUI

struct SpotDetailView: View {
    @State var id: String
    @Binding var goSpotDetailView: Bool
    @ObservedObject var viewModel = SpotDetailViewModel()
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    @State var imageIndex: Int = 0
    @State var goImageList = false
    
    var body: some View {
        VStack {
            if viewModel.loading {
                ProgressView()
                    .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                    .zIndex(1)
            } else {
                if let spot = viewModel.spot {
                    VStack {
                        if let imageUrl = spot.imageUrl {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: height / 4)
                                    .clipped()
                            } placeholder: {
                                Rectangle().fill(Color.background)
                            }
                        } else {
                            Rectangle().fill(Color.background).frame(height: height / 4)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(spot.title).font(.system(size: 20).bold()).padding(.bottom)
                            HStack {
                                Image(systemName: "mappin.and.ellipse").font(.system(size: 14))
                                Text(spot.address)
                                Spacer()
                            }
                            if let memo = spot.memo {
                                Text(memo).frame(height: 60).padding(.vertical).foregroundColor(.textGray)
                            } else {
                                Rectangle().frame(height: 60).foregroundColor(.white)
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
                                LazyVGrid(columns: Array(repeating: .init(.fixed((width - 25) / 3)), count: 3), alignment: .center, spacing: 3) {
                                    ForEach(viewModel.photos.indices, id: \.self) { i in
                                        AsyncImage(url: URL(string: viewModel.photos[i].imageUrl)) { image in
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill)
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
                        NavigationLink(destination: SpotImageList(i: imageIndex, photos: viewModel.photos), isActive: $goImageList) {
                            EmptyView()
                        }
                    }.navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true).toolbar {
                        ToolbarItem(placement: .navigationBarLeading){
                            Button(action: {
                                goSpotDetailView = false
                            }) {
                                Image(systemName: "chevron.left").font(.system(size: 14).bold()).foregroundColor(.black).frame(width: 35, height: 35).foregroundColor(.black).background(Color.white).clipShape(Circle())
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button(action: {
                                viewModel.updateStar(spotId: id, star: !spot.star)
                            }) {
                                Image(systemName: spot.star ? "star.fill" : "star").font(.system(size: 16).bold()).foregroundColor(.yellow).frame(width: 35, height: 35).foregroundColor(.black).background(Color.white).clipShape(Circle())
                            }.disabled(viewModel.updatingStar)
                        }
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button(action: {
                                viewModel.updateFavorite(spotId: id, favorite: !spot.favorite)
                            }) {
                                Image(systemName: spot.favorite ? "heart.fill" : "heart").font(.system(size: 16).bold()).foregroundColor(.pink).frame(width: 35, height: 35).foregroundColor(.black).background(Color.white).clipShape(Circle())
                            }.disabled(viewModel.updatingFavorite)
                        }
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button(action: {
                                
                            }) {
                                Image(systemName: "ellipsis").font(.system(size: 16).bold()).foregroundColor(.black).frame(width: 35, height: 35).foregroundColor(.black).background(Color.white).clipShape(Circle())
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                } else {
                    // If there is not a spot or something wrong
                }
            }
        }.onAppear {
            viewModel.getSpot(spotId: id)
            viewModel.getPhotos(spotId: id)
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
        SpotDetailView(id: "", goSpotDetailView: .constant(true))
    }
}
