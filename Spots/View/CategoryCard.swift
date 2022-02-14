//
//  Created on 2022/02/13
//

import SwiftUI

struct CategoryCard: View {
    @EnvironmentObject var categoriesViewModel: CategoriesViewModel
    @State var idx: Int
    @State var tempCategoryColor = Color.white
    @State var tempCategoryName = ""
    
    var body: some View {
        VStack(spacing: 1) {
            HStack {
                if !categoriesViewModel.categories[idx].editMode {
                    Circle()
                        .fill(Color(hex: categoriesViewModel.categories[idx].category.color))
                        .frame(width:22, height: 22)
                    Text(categoriesViewModel.categories[idx].category.name)
                } else {
                    ColorPicker("", selection: $tempCategoryColor).labelsHidden()
                    TextField("カテゴリー", text: $tempCategoryName)
                    Button {
                        categoriesViewModel.categories[idx].editMode = false
                    } label: {
                        Image(systemName: "xmark").font(.system(size: 18, weight: .bold)).foregroundColor(.background)
                    }.disabled(categoriesViewModel.uploading)
                    Button {
                        Task {
                            await categoriesViewModel.updateCategory(idx: idx, name: tempCategoryName, color: tempCategoryColor)
                        }
                    } label: {
                        Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)).foregroundColor(.green)
                    }
                    .padding(.leading)
                    .disabled(categoriesViewModel.uploading || tempCategoryName == "")
                }
            }
        }
    }
}

struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCard(idx: 0).environmentObject(CategoriesViewModel())
    }
}
