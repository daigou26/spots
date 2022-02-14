//
//  Created on 2022/02/12
//

import SwiftUI

struct CategoriesList: View {
    @EnvironmentObject var spotDetailViewModel: SpotDetailViewModel
    @ObservedObject var viewModel = CategoriesViewModel()
    @State var showAddCategoryForm = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("カテゴリー").font(.system(size: 20, weight: .bold)).padding(.bottom, 30)
                if viewModel.categories.count == 0 {
                    Text("カテゴリーが存在しません").foregroundColor(.textGray)
                }
                List {
                    ForEach(viewModel.categories.indices, id: \.self) { idx in
                        CategoryCard(idx: idx, tempCategoryColor: Color(hex: viewModel.categories[idx].category.color), tempCategoryName: viewModel.categories[idx].category.name)
                            .environmentObject(viewModel)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button {
                                    viewModel.categories[idx].editMode = true
                                } label: {
                                    Text("編集")
                                }

                            })
                            .padding(.vertical, 16)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
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
        }
    }
}

struct CategoriesList_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesList().environmentObject(SpotDetailViewModel())
    }
}
