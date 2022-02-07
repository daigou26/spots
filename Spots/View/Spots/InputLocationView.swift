//
//  Created on 2021/12/05
//

import SwiftUI

struct InputLocationView: View {
    @EnvironmentObject var addSpotViewModel: AddSpotViewModel
    @EnvironmentObject var spotDetailViewModel: SpotDetailViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var editing = false
    @State var address = ""
    
    var body: some View {
        ZStack (alignment: .center) {
            VStack(alignment: .leading) {
                Text("住所").foregroundColor(.textGray)
                TextField("住所を入力", text: $address).frame(height: 22)
                Divider().padding(.vertical, 5)
                Text(editing ? spotDetailViewModel.errorMessage : addSpotViewModel.addressErrorMessage).foregroundColor(Color.red)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            if editing, spotDetailViewModel.updating {
                ProgressView().scaleEffect(x: 1.5, y: 1.5, anchor: .center).progressViewStyle(CircularProgressViewStyle(tint: Color.white)).zIndex(1)
                Rectangle().fill(Color.black).opacity(0.4).edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left").font(.system(size: 16).bold()).foregroundColor(.black)
                }.disabled(editing ? spotDetailViewModel.updating : false)
            }
            ToolbarItem(placement: .navigationBarTrailing){
                Button(editing ? "保存" : "決定") {
                    Task {
                        if editing {
                            if let id = spotDetailViewModel.spot?.id {
                                let res = await spotDetailViewModel.updateAddress(spotId: id, address: address)
                                if res, spotDetailViewModel.errorMessage == "" {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } else {
                            await addSpotViewModel.validateAddress(address: address)
                            if addSpotViewModel.addressErrorMessage == "" {
                                addSpotViewModel.address = address
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }.disabled(editing ? spotDetailViewModel.updating : false)
            }
        }
        .onAppear {
            if editing {
                address = spotDetailViewModel.spot?.address ?? ""
            } else {
                address = addSpotViewModel.address
            }
        }
    }
}

struct InputLocationView_Previews: PreviewProvider {
    static var previews: some View {
        InputLocationView().environmentObject(AddSpotViewModel())
    }
}
