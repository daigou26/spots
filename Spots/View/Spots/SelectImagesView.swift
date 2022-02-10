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
            
            GridLocalImages(onTap: {
                asset in imagePickerViewModel.setSelectedImages(asset)
            }, checkEnabled: true).environmentObject(imagePickerViewModel)
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
