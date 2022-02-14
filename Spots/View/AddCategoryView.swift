////
////  Created on 2022/02/12
////
//
//import SwiftUI
//
//struct AddCategoryView: View {
//    @State var items: [CategoryItem] = [CategoryItem(title: "", color: Color.white)]
//    
//    var body: some View {
//        VStack {
//            List {
//                ForEach(0..<items.count) { i in
//                    if i > 0 {
//                        Divider().padding(.vertical, 8)
//                    }
//                    HStack {
//                        TextField("カテゴリー", text: $items[i].title)
//                        ColorPicker("", selection: $items[i].color)
//                    }
//                }
//                .onDelete { index in
//                    if let index = index.map({$0}).first {
//                        items.remove(at: index)
//                    }
//                }
//            }
//            Button {
//                items.append(CategoryItem(title: "", color: Color.white))
//            } label: {
//                HStack {
//                    Image(systemName: "plus").foregroundColor(.textGray)
//                    Text("さらにカテゴリーを追加").foregroundColor(.textGray)
//                }
//                
//            }.padding(.top, 28)
//        }
//        .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
//        .navigationBarTitleDisplayMode(.inline)
//        //        .navigationBarBackButtonHidden(true)
//        //        .toolbar {
//        //            ToolbarItem(placement: .navigationBarLeading){
//        //                Button(action: {
//        //                    spotsViewModel.goSpotDetailView = false
//        //                    if let spot = viewModel.spot {
//        //                        spotsViewModel.updateSpot(spotId: id, spot: spot)
//        //                    }
//        //                }) {
//        //                    Image(systemName: "chevron.left").font(.system(size: 14).bold()).foregroundColor(.black).frame(width: 35, height: 35).background(Color.white).clipShape(Circle())
//        //                }.disabled(spotsViewModel.updating)
//        //            }
//        //            ToolbarItem(placement: .navigationBarTrailing){
//        //                Button(action: {
//        //                    viewModel.updateStar(spotId: id, star: !spot.star)
//        //                }) {
//        //                    Image(systemName: spot.star ? "star.fill" : "star").font(.system(size: 16).bold()).foregroundColor(.yellow).frame(width: 35, height: 35).background(Color.white).clipShape(Circle())
//        //                }.disabled(viewModel.updatingStar || spotsViewModel.updating)
//        //            }
//        //            ToolbarItem(placement: .navigationBarTrailing){
//        //                Button(action: {
//        //                    viewModel.updateFavorite(spotId: id, favorite: !spot.favorite)
//        //                }) {
//        //                    Image(systemName: spot.favorite ? "heart.fill" : "heart").font(.system(size: 16).bold()).foregroundColor(.pink).frame(width: 35, height: 35).background(Color.white).clipShape(Circle())
//        //                }.disabled(viewModel.updatingFavorite || spotsViewModel.updating)
//        //            }
//        //            ToolbarItem(placement: .navigationBarTrailing){
//        //                Button(action: {
//        //                    actionDialogEnable = true
//        //                }) {
//        //                    Image(systemName: "ellipsis").font(.system(size: 16).bold()).foregroundColor(.black).frame(width: 35, height: 35).background(Color.white).clipShape(Circle())
//        //                }.disabled(spotsViewModel.updating)
//        //            }
//        //        }
//    }
//}
//
//struct CategoryItem: Hashable {
//    var title: String
//    var color: Color
//}
//
//struct AddCategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddCategoryView()
//    }
//}
