//
//  Created on 2022/02/16
//

import SwiftUI

struct CategoriesFilterView: View {
    @EnvironmentObject var spotsViewModel: SpotsViewModel
    @ObservedObject var viewModel = CategoriesViewModel()
    @Binding var showCategoriesFilter: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("カテゴリー").font(.system(size: 20, weight: .bold))
                Spacer()
                Text("決定").font(.system(size: 16)).foregroundColor(.textGray).onTapGesture {
                    spotsViewModel.categoriesFilter = viewModel.categoryItems.map({ item in
                        if item.checked {
                            return item.category
                        }
                        return nil
                    }).compactMap{$0}
                    spotsViewModel.updateSpots()
                    showCategoriesFilter = false
                }
            }.padding(.bottom, 30)
            
            List {
                ForEach(viewModel.categoryItems.indices, id: \.self) { idx in
                    CategoryCard(idx: idx, editing: false, tempCategoryColor: Color(hex: viewModel.categoryItems[idx].category.color), tempCategoryName: viewModel.categoryItems[idx].category.name)
                        .environmentObject(viewModel)
                        .onTapGesture {
                            viewModel.categoryItems[idx].checked = !viewModel.categoryItems[idx].checked
                        }
                        .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                }
            }
            .listStyle(.plain)
        }
        .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Set spot categories
            viewModel.categoryItems = viewModel.categoryItems.map { categoryItem in
                var categoryItem = categoryItem
                categoryItem.checked = false
                if spotsViewModel.categoriesFilter.map({ cf in cf.id }).contains(categoryItem.category.id ?? "") {
                    categoryItem.checked = true
                }
                return categoryItem
            }
        }
    }
}

struct CategoriesFilterView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesFilterView(showCategoriesFilter: .constant(true)).environmentObject(SpotsViewModel())
    }
}
