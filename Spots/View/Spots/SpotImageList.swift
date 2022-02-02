//
//  Created on 2022/01/28
//

import SwiftUI

struct SpotImageList: View {
    @State var i = 0
    @State var photos: [Photo] = []
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let width = UIScreen.main.bounds.width

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(photos.indices, id: \.self) { index in
                        AsyncImage(url: URL(string: photos[index].imageUrl)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle().fill(.white).frame(height: width / CGFloat(photos[index].width) * CGFloat(photos[index].height))
                        }.id(index)
                    }
                }.onAppear {
                    scrollView.scrollTo(i, anchor: .top)
                }
            }
        }.navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true).toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left").font(.system(size: 16).bold()).foregroundColor(.black)
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
