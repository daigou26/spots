//
//  Created on 2022/02/04
//

import SwiftUI

struct UpdateSpotView: View {
    @EnvironmentObject var spotDetailViewModel: SpotDetailViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var title: String = ""
    @State var memo: String = ""
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .leading) {
                if spotDetailViewModel.updatingTitle {
                    Text("タイトル").foregroundColor(.textGray)
                    TextField(title, text: $title).frame(height: 22)
                }
                if spotDetailViewModel.updatingMemo {
                    Text("メモ").foregroundColor(.textGray)
                    TextEditor(text: $memo).frame(height: 200)
                }
                Divider().padding(.vertical, 9)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            if spotDetailViewModel.updating {
                ProgressView().scaleEffect(x: 1.5, y: 1.5, anchor: .center).progressViewStyle(CircularProgressViewStyle(tint: Color.white)).zIndex(1)
                Rectangle().fill(Color.black).opacity(0.4).edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear(perform: {
            title = spotDetailViewModel.spot?.title ?? ""
            memo = spotDetailViewModel.spot?.memo ?? ""
        })
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    spotDetailViewModel.updatingTitle = false
                    spotDetailViewModel.updatingMemo = false
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left").font(.system(size: 16).bold()).foregroundColor(.black)
                }.disabled(spotDetailViewModel.updating)
            }
            ToolbarItem(placement: .navigationBarTrailing){
                Button("保存") {
                    Task {
                        var res = false
                        if let id = spotDetailViewModel.spot?.id, spotDetailViewModel.updatingTitle {
                            res = await spotDetailViewModel.updateTitle(spotId: id, title: title)
                        }
                        if let id = spotDetailViewModel.spot?.id, spotDetailViewModel.updatingMemo {
                            res = await spotDetailViewModel.updateMemo(spotId: id, memo: memo)
                        }
                        if res {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }.disabled(spotDetailViewModel.updating)
            }
        }
    }
}

struct UpdateSpotView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateSpotView().environmentObject(SpotDetailViewModel())
    }
}
