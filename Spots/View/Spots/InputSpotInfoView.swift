//
//  Created on 2021/12/03
//

import SwiftUI

struct InputSpotInfoView: View {
    @EnvironmentObject var addSpotViewModel: AddSpotViewModel
    @EnvironmentObject var spotsViewModel: SpotsViewModel
    @State var goNext = false
    @State var goInputLocationView = false
    @State var title = ""
    @State var favorite = false
    @State var star = false
    @State var memo = ""
    
    var body: some View {
        ZStack(alignment: .center) {
            ScrollView {
                Group {
                    HStack {
                        Text("タイトル")
                        Spacer()
                    }
                    
                    TextField("", text: $title).frame(height: 22)
                    Divider().padding(.bottom, 18).padding(.top, 5)
                    HStack {
                        Text("場所")
                        Spacer()
                        Button(action: {goInputLocationView = true}) {
                            Text(addSpotViewModel.address).lineLimit(1).frame(maxWidth: UIScreen.main.bounds.width / 3, alignment: .trailing)
                            Image(systemName: "chevron.right")
                        }.foregroundColor(.black)
                    }
                    Divider().padding(.vertical, 18)
                    HStack {
                        Text("お気に入り")
                        Spacer()
                        Toggle("", isOn: $favorite).padding(.trailing, 6)
                    }
                    HStack {
                        Text("行きたい")
                        Spacer()
                        Toggle("", isOn: $star).padding(.trailing, 6)
                    }
                    Divider().padding(.vertical, 18)
                    HStack {
                        Text("メモ")
                        Spacer()
                    }
                    TextEditor(text: $memo).frame(height: 200).background(Color.red)
                }
            }.padding(.horizontal, 20).padding(.vertical, 30)
            
            NavigationLink(destination: InputLocationView(goInputLocationView: $goInputLocationView), isActive: $goInputLocationView) {
                EmptyView()
            }
            
            if addSpotViewModel.loading {
                ProgressView().scaleEffect(x: 1.5, y: 1.5, anchor: .center).progressViewStyle(CircularProgressViewStyle(tint: Color.white)).zIndex(1)
                Rectangle().fill(Color.black).opacity(0.4).edgesIgnoringSafeArea(.all)
            }
        }.navigationBarBackButtonHidden(addSpotViewModel.loading)
            .navigationBarItems(trailing: Button(action: {
                addSpotViewModel.setLoading(value: true)
                spotsViewModel.postSpot(mainImage: addSpotViewModel.mainImage, images: addSpotViewModel.images, title: title, address: addSpotViewModel.address, favorite: favorite, star: star, memo: memo)
            }) {
                Text("登録")
            }.disabled(title == "" || addSpotViewModel.address == ""))
    }
}

struct InputSpotInfoView_Previews: PreviewProvider {
    static var previews: some View {
        InputSpotInfoView().environmentObject(AddSpotViewModel()).environmentObject(SpotsViewModel())
    }
}
