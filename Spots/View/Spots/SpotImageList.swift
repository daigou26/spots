//
//  Created on 2022/01/28
//

import SwiftUI

struct SpotImageList: View {
    @State var i = 0
    @State var photos: [Photo] = []
    @State var updating = false
    @EnvironmentObject var spotDetailViewModel: SpotDetailViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        ScrollViewReader { scrollView in
            List {
                ForEach(photos.indices, id: \.self) { index in
                    VStack(spacing: 1) {
                        AsyncImage(url: URL(string: photos[index].imageUrl)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle().fill(.white).frame(height: width / CGFloat(photos[index].width) * CGFloat(photos[index].height))
                        }
                    }
                    .id(index)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                }
                .onDelete { index in
                    if let index = index.map({$0}).first {
                        let photo = photos[index]
                        if let spotId = spotDetailViewModel.spot?.id, let photoId = photo.id {
                            Task {
                                updating = true
                                let success = await spotDetailViewModel.removePhoto(spotId: spotId, photoId: photoId, photo: photo)
                                if success {
                                    photos.remove(at: index)
                                    if photos.count == 0 {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                updating = false
                            }
                        }
                    }
                }
                .onAppear {
                    scrollView.scrollTo(i, anchor: .top)
                }
            }
            .listStyle(.plain)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left").font(.system(size: 16).bold()).foregroundColor(.textGray)
                }
            }
        }
    }
}

struct SpotImageList_Previews: PreviewProvider {
    static var previews: some View {
        SpotImageList(i: 0, photos: [])
    }
}
