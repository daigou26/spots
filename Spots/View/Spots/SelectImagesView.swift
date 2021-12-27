//
//  Created on 2021/12/01
//

import SwiftUI

struct SelectImagesView: View {
    @EnvironmentObject var addSpotViewModel: AddSpotViewModel
    @EnvironmentObject var imagePickerViewModel: ImagePickerViewModel
    @State var goNext = false
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        Group {
            HStack {
                if let count = imagePickerViewModel.selectedImages.count, count > 0 {
                    Text("\(count)枚の写真を選択中").padding()
                } else {
                    Text("写真が選択されていません").padding()
                }
                Spacer()
            }
            
            ScrollView {
                VStack {
                    LazyVGrid(columns: Array(repeating: .init(.fixed((width - 25) / 3)), count: 3), alignment: .center, spacing: 5) {
                        ForEach(imagePickerViewModel.photos, id: \.self) { photo in
                            ThumbnailView(photo: photo, width: (width - 25) / 3, height: (width - 25) / 3, checked: imagePickerViewModel.selectedImages.contains(photo) ).onTapGesture {
                                imagePickerViewModel.setSelectedImages(photo)
                            }
                        }
                    }
                    
                    if imagePickerViewModel.libraryStatus == .limited {
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
            NavigationLink(destination: InputSpotInfoView(), isActive: $goNext) {
                EmptyView()
            }
        }.navigationTitle("スポットの写真").navigationBarItems(trailing: Button(action: {
            addSpotViewModel.images = imagePickerViewModel.selectedImages
            goNext = true
        }) {
            Text("次へ")
        })
    }
}

struct SelectImagesView_Previews: PreviewProvider {
    static var previews: some View {
        SelectImagesView().environmentObject(AddSpotViewModel()).environmentObject(ImagePickerViewModel())
    }
}
