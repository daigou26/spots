//
//  Created on 2022/02/10
//

import SwiftUI

struct AddImagesView: View {
    @EnvironmentObject var spotDetailViewModel: SpotDetailViewModel
    @EnvironmentObject var imagePickerViewModel: ImagePickerViewModel
    @State var updating = false
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView {
            ZStack() {
                if updating {
                    ProgressView().scaleEffect(x: 1.5, y: 1.5, anchor: .center).progressViewStyle(CircularProgressViewStyle(tint: Color.white)).zIndex(2)
                    Rectangle().fill(Color.black).opacity(0.4).edgesIgnoringSafeArea(.all).zIndex(1)
                }
                VStack {
                    HStack {
                        if let count = imagePickerViewModel.selectedImages.count, count > 0 {
                            Text("\(count)枚の写真を選択中").foregroundColor(.textGray).padding()
                        } else {
                            Text("写真が選択されていません").foregroundColor(.textGray).padding()
                        }
                        Spacer()
                    }
                    
                    GridLocalImages(onTap: { asset in
                        imagePickerViewModel.setSelectedImages(asset)
                    }, checkEnabled: true).environmentObject(imagePickerViewModel)
                }
            }
            .onAppear(perform: {
                if imagePickerViewModel.libraryStatus == .Denied {
                    imagePickerViewModel.setUp(Int(width))
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(updating)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        spotDetailViewModel.showAddPhotosSheet = false
                    }) {
                        Image(systemName: "xmark").font(.system(size: 16).bold()).foregroundColor(.black)
                    }.disabled(updating)
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("保存") {
                        if let spotId = spotDetailViewModel.spot?.id {
                            Task {
                                updating = true
                                var success = false
                                success = await spotDetailViewModel.addPhotos(spotId: spotId, images: imagePickerViewModel.selectedImages)
                                updating = false
                                if success {
                                    spotDetailViewModel.showAddPhotosSheet = false
                                }
                            }
                        }
                    }.disabled(updating || imagePickerViewModel.selectedImages.count == 0)
                }
            }
        }
    }
}

struct AddImagesView_Previews: PreviewProvider {
    static var previews: some View {
        AddImagesView().environmentObject(SpotDetailViewModel()).environmentObject(ImagePickerViewModel())
    }
}
