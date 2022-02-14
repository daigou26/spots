//
//  Created on 2022/02/12
//

import SwiftUI

struct CategoriesList: View {
    @EnvironmentObject var spotDetailViewModel: SpotDetailViewModel
    @ObservedObject var viewModel = CategoriesViewModel()
    @Binding var showCategoriesSheet: Bool
    @State var showAddCategoryForm = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text("カテゴリー").font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text("保存").font(.system(size: 16)).foregroundColor(.textGray).onTapGesture {
                        Task {
                            if let spotId = spotDetailViewModel.spot?.id {
                                let res = await spotDetailViewModel.updateCategories(spotId: spotId, categories: viewModel.categoryItems.map({ item in
                                    if item.checked {
                                        return item.category.id
                                    }
                                    return nil
                                }).compactMap{$0})
                                if res {
                                    showCategoriesSheet = false
                                }
                            }
                            
                        }
                    }
                }.padding(.bottom, 30)
                
                if viewModel.categoryItems.count == 0 {
                    Text("カテゴリーが存在しません").foregroundColor(.textGray)
                }
                List {
                    ForEach(viewModel.categoryItems.indices, id: \.self) { idx in
                        CategoryCard(idx: idx, tempCategoryColor: Color(hex: viewModel.categoryItems[idx].category.color), tempCategoryName: viewModel.categoryItems[idx].category.name)
                            .environmentObject(viewModel)
                            .environmentObject(spotDetailViewModel)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button {
                                    viewModel.categoryItems[idx].editMode = true
                                } label: {
                                    Text("編集")
                                }

                            })
                            .onTapGesture {
                                viewModel.categoryItems[idx].checked = !viewModel.categoryItems[idx].checked
                            }
                            .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                    }
                }
                .listStyle(.plain)
                
                if !showAddCategoryForm {
                    Button {
                        showAddCategoryForm = true
                    } label: {
                        HStack {
                            Image(systemName: "plus").foregroundColor(.textGray)
                            Text("カテゴリを作成する").font(.system(size: 18)).foregroundColor(.textGray)
                        }
                    }
                }
                if showAddCategoryForm {
                    HStack {
                        ColorPicker("", selection: $viewModel.tempCategoryColor).labelsHidden()
                        TextField("カテゴリー", text: $viewModel.tempCategoryName)
                        Button {
                            viewModel.resetTempData()
                            showAddCategoryForm = false
                        } label: {
                            Image(systemName: "xmark").font(.system(size: 18, weight: .bold)).foregroundColor(.background)
                        }.disabled(viewModel.uploading)
                        Button {
                            Task {
                                let res = await viewModel.postCategory()
                                if res {
                                    showAddCategoryForm = false
                                }
                            }
                        } label: {
                            Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)).foregroundColor(.green)
                        }
                        .padding(.leading)
                        .disabled(viewModel.uploading || viewModel.tempCategoryName == "")
                    }
                }
            }
            .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
            .navigationBarHidden(true)
            .onAppear {
                viewModel.categoryItems = viewModel.categoryItems.map { categoryItem in
                    var categoryItem = categoryItem
                    if spotDetailViewModel.isSetCategory(id: categoryItem.category.id ?? "") {
                        categoryItem.checked = true
                    }
                    return categoryItem
                }
            }
        }
    }
}

struct CategoriesList_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesList(showCategoriesSheet: .constant(true)).environmentObject(SpotDetailViewModel())
    }
}
