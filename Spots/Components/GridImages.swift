//
//  Created on 2022/02/08
//

import SwiftUI

struct GridLocalImages: View {
    @EnvironmentObject var imagePickerViewModel: ImagePickerViewModel
    @State var onTap: (_ asset: Asset) -> Void
    @State var checkEnabled = false
    
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 5) {
                    ForEach(imagePickerViewModel.assets, id: \.self) { asset in
                        ThumbnailView(asset: asset, checked: checkEnabled ? imagePickerViewModel.selectedImages.contains(asset) : false).onTapGesture {
                            onTap(asset)
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
}

struct GridLocalImages_Previews: PreviewProvider {
    static var previews: some View {
        GridLocalImages(onTap: {_ in}).environmentObject(ImagePickerViewModel())
    }
}
