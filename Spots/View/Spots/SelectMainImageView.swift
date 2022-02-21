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
                        GridLocalImages(onTap: { asset in
                            imagePickerViewModel.extractPreviewData(asset: asset.asset)
                        }).environmentObject(imagePickerViewModel)
                    }
                    NavigationLink(destination: SelectImagesView(), isActive: $goNext) {
                        EmptyView()
                    }
                }
            }
            .interactiveDismissDisabled(addSpotViewModel.loading)
            .navigationTitle("メインの写真")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        spotsViewModel.showAddSpotSheet = false
                    }) {
                        Image(systemName: "xmark").foregroundColor(.textGray)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        if let selectedImage = imagePickerViewModel.selectedImagePreview {
                            addSpotViewModel.mainImage = selectedImage
                        }
                        goNext = true
                    }) {
                        Text("次へ").foregroundColor(.textGray)
                    }
                }
            }.onAppear {
                if imagePickerViewModel.libraryStatus == .Denied {
                    imagePickerViewModel.setUp(Int(width))
                }
            }
        }.accentColor(.textGray)
    }
}

struct SelectMainImageView_Previews: PreviewProvider {
    static var previews: some View {
        SelectMainImageView().environmentObject(AddSpotViewModel()).environmentObject(ImagePickerViewModel())
    }
}
