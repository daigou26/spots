//
//  Created on 2022/02/13
//

import SwiftUI

struct CategoryCard: View {
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @EnvironmentObject var spotDetailViewModel: SpotDetailViewModel
    @State var idx: Int
    @State var editing: Bool = false
    @State var tempCategoryColor = Color.white
    @State var tempCategoryName = ""
    
    var body: some View {
        VStack(spacing: 1) {
            if !categoriesViewModel.categoryItems[idx].editMode {
                Button {
                    categoriesViewModel.categoryItems[idx].checked = !categoriesViewModel.categoryItems[idx].checked
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(hex: categoriesViewModel.categoryItems[idx].category.color))
                            .frame(width:22, height: 22)
                        Text(categoriesViewModel.categoryItems[idx].category.name)
                        Spacer()
                        if categoriesViewModel.categoryItems[idx].checked {
                            Image(systemName: "checkmark").foregroundColor(.textGray)
                        }
                    }.frame(height: 50)
                }
            } else {
                HStack {
                    ColorPicker("", selection: $tempCategoryColor).labelsHidden()
                    TextField("カテゴリー", text: $tempCategoryName)
                    Button {
                        categoriesViewModel.categoryItems[idx].editMode = false
                    } label: {
                        Image(systemName: "xmark").font(.system(size: 18, weight: .bold)).foregroundColor(.textGray)
                    }.disabled(categoriesViewModel.uploading)
                    Button {
                        Task {
                            await categoriesViewModel.updateCategory(idx: idx, name: tempCategoryName, color: tempCategoryColor)
                            if editing {
                                // Update SpotDetailView categories
                                spotDetailViewModel.categories[idx].name = tempCategoryName
                                spotDetailViewModel.categories[idx].color = tempCategoryColor.hex
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)).foregroundColor(.green)
                    }
                    .padding(.leading)
                    .disabled(categoriesViewModel.uploading || tempCategoryName == "")
                }.frame(height: 50)
            }
        }
    }
}

struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCard(idx: 0).environmentObject(CategoriesViewModel())
    }
}
