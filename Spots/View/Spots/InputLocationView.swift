//
//  Created on 2021/12/05
//

import SwiftUI

struct InputLocationView: View {
    @EnvironmentObject var addSpotViewModel: AddSpotViewModel
    @State var address = ""
    @Binding var goInputLocationView: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("住所を入力", text: $address).frame(height: 22)
            Divider().padding(.vertical, 5)
            Text(addSpotViewModel.addressErrorMessage).foregroundColor(Color.red)
            Spacer()
        }.padding(.horizontal, 20).padding(.vertical, 30)
            .navigationTitle("場所")
            .navigationBarItems(trailing: Button(action: {
                Task {
                    await addSpotViewModel.validateAddress(address: address)
                    if addSpotViewModel.addressErrorMessage == "" {
                        addSpotViewModel.setAddress(address)
                        goInputLocationView = false
                    }
                }
            }) {
                Text("決定")
            }).onAppear {
                self.address = addSpotViewModel.address
            }
    }
}

struct InputLocationView_Previews: PreviewProvider {
    static var previews: some View {
        InputLocationView(goInputLocationView: .constant(false)).environmentObject(AddSpotViewModel())
    }
}
