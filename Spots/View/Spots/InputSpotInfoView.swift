//
//  Created on 2021/12/03
//

import SwiftUI

struct InputSpotInfoView: View {
    @EnvironmentObject var addSpotViewModel: AddSpotViewModel
    @EnvironmentObject var spotsViewModel: SpotsViewModel
    @State var goNext = false
    @State var goInputLocationView = false
    
    var body: some View {
        ZStack(alignment: .center) {
            ScrollView {
                Group {
                    HStack {
                        Text("タイトル")
                        Spacer()
                    }
                    
                    TextField(addSpotViewModel.title, text: $addSpotViewModel.title).frame(height: 22)
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
                        Toggle("", isOn: $addSpotViewModel.favorite).padding(.trailing, 6)
                    }
                    HStack {
                        Text("行きたい")
                        Spacer()
                        Toggle("", isOn: $addSpotViewModel.star).padding(.trailing, 6)
                    }
                    Divider().padding(.vertical, 18)
                    HStack {
                        Text("メモ")
                        Spacer()
                    }
                    TextEditor(text: $addSpotViewModel.memo).frame(height: 200)
                }.alert("スポットが重複しています", isPresented: $addSpotViewModel.duplicatedTitleAndAddress, actions:{
                    Button(action: {
                        addSpotViewModel.loading = false
                        addSpotViewModel.duplicatedTitleAndAddress = false
                    }, label: {
                        Text("OK")
                    })
                }) {
                    Text("タイトルまたは住所を変更してください")
                }.alert("すでに同一住所のスポットが存在しています。\n登録を続けますか？", isPresented: $addSpotViewModel.duplicatedAddress, actions:{
                    Button(action: {
                        addSpotViewModel.loading = false
                        addSpotViewModel.duplicatedAddress = false
                    }, label: {
                        Text("キャンセル")
                    })
                    Button(action: {
                        addSpotViewModel.duplicatedAddress = false
                        spotsViewModel.postSpot(mainImage: addSpotViewModel.mainImage?.jpegData(compressionQuality: 0), images: addSpotViewModel.images, title: addSpotViewModel.title, address: addSpotViewModel.address, favorite: addSpotViewModel.favorite, star: addSpotViewModel.star, memo: addSpotViewModel.memo)
                    }, label: {
                        Text("はい")
                    })
                })
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
                addSpotViewModel.loading = true
                
                // If this spot address is duplicated, show an alert. If not, post this spot.
                addSpotViewModel.checkToExistsSameAddressSpot {
                    spotsViewModel.postSpot(mainImage: addSpotViewModel.mainImage?.jpegData(compressionQuality: 0), images: addSpotViewModel.images, title: addSpotViewModel.title, address: addSpotViewModel.address, favorite: addSpotViewModel.favorite, star: addSpotViewModel.star, memo: addSpotViewModel.memo)
                    
                }
            }) {
                Text("登録")
            }.disabled(addSpotViewModel.title == "" || addSpotViewModel.address == ""))
    }
}

struct InputSpotInfoView_Previews: PreviewProvider {
    static var previews: some View {
        InputSpotInfoView().environmentObject(AddSpotViewModel()).environmentObject(SpotsViewModel())
    }
}
