//
//  Created on 2021/11/30
//

import SwiftUI

struct SelectMainImageView: View {
    @EnvironmentObject var spotsViewModel: SpotsViewModel
    @EnvironmentObject var addSpotViewModel: AddSpotViewModel
    @EnvironmentObject var imagePickerViewModel: ImagePickerViewModel
    @State var goNext = false
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView {
            Group {
                VStack {
                    if let preview = imagePickerViewModel.selectedImagePreview {
                        Image(uiImage: preview).resizable().scaledToFill().frame(height: width / 1.6).clipped().padding(.bottom, 15)
                    } else {
                        Color.lightGray.frame(width: width, height: width * 0.625).padding(.bottom, 15)
                    }
                    
                    if imagePickerViewModel.libraryStatus == .Denied {
                        Spacer()
                        Text("写真へのアクセスを許可してください").foregroundColor(.gray)
                        Button(action: {
                            // Go to settings
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }, label: {
                            Text("許可する").foregroundColor(.white).fontWeight(.bold).padding(.vertical, 10).padding(.horizontal).background(Color.main).cornerRadius(10)
                        })
                        Spacer()
                    } else {
                        ScrollView {
                            VStack {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 5) {
                                    ForEach(imagePickerViewModel.photos, id: \.self) { photo in
                                        ThumbnailView(photo: photo).onTapGesture {
                                            imagePickerViewModel.extractPreviewData(asset: photo.asset)
                                        }
                                    }
                                }
                                
                                if imagePickerViewModel.libraryStatus == .Limited {
                                    Text("追加で写真を選択する").foregroundColor(.gray).padding(.top, 20)
                                    Button(action: {
                                        // Go to settings
                                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                                    }, label: {
                                        Text("写真を選択").foregroundColor(.white).fontWeight(.bold).padding(.vertical, 10).padding(.horizontal).background(Color.main).cornerRadius(10)
                                    }).padding(.bottom, 30)
                                }
                            }
                        }
                    }
                    NavigationLink(destination: SelectImagesView(), isActive: $goNext) {
                        EmptyView()
                    }
                }
            }.interactiveDismissDisabled(addSpotViewModel.loading).navigationTitle("メインの写真").navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        spotsViewModel.showAddSpotSheet = false
                    }) {
                        Image(systemName: "xmark").foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        if let selectedImage = imagePickerViewModel.selectedImagePreview {
                            addSpotViewModel.mainImage = selectedImage
                        }
                        goNext = true
                    }) {
                        Text("次へ")
                    }
                }
            }.onAppear {
                if imagePickerViewModel.libraryStatus == .Denied {
                    imagePickerViewModel.setUp(Int(width))
                }
            }
        }
    }
}

struct SelectMainImageView_Previews: PreviewProvider {
    static var previews: some View {
        SelectMainImageView().environmentObject(AddSpotViewModel()).environmentObject(ImagePickerViewModel())
    }
}
