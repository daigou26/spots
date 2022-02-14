//
//  Created on 2022/02/12
//

import Foundation
import Combine
import SwiftUI

struct CategoryItem: Hashable {
    var category: Category
    var editMode: Bool
}

class CategoriesViewModel: ObservableObject {
    @Published var categories = Account.shared.categories.map { category in
        return CategoryItem(category: category, editMode: false)
    }
    @Published var tempCategoryColor = Color.white
    @Published var tempCategoryName = ""
    @Published var uploading = false
    
    private var categoryUseCase: CategoryUseCase
    var cancellables = [AnyCancellable]()
    
    init(_ categoryUseCase: CategoryUseCase = CategoryUseCaseImpl()) {
        self.categoryUseCase = categoryUseCase
    }
    
    func resetTempData() {
        tempCategoryName = ""
        tempCategoryColor = Color.white
    }
    
    @MainActor
    func postCategory() async -> Bool {
        uploading = true
        let color = tempCategoryColor.hex
        let result: Bool = await withCheckedContinuation { continuation in
            categoryUseCase.postCategory(name: tempCategoryName, color: color, idx: categories.count)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished: do {
                        self.resetTempData()
                        continuation.resume(returning: true)
                    }
                    case .failure: do {
                        continuation.resume(returning: false)
                    }
                    }
                }, receiveValue: { category in
                    self.categories.append(CategoryItem(category: category, editMode: false))
                    Account.shared.update(categories: self.categories.map({ c in
                        return c.category
                    }))
                }).store(in: &cancellables)
        }
        uploading = false
        return result
    }
    
    @MainActor
    func updateCategory(idx: Int, name: String, color: Color) async -> Void {
        uploading = true
        let color = color.hex
        if let categoryId = categories[idx].category.id {
            let _: Void = await withCheckedContinuation { continuation in
                categoryUseCase.updateCategory(categoryId: categoryId, name: name, color: color, idx: idx)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished: do {
                            continuation.resume(returning: ())
                        }
                        case .failure: do {
                            continuation.resume(returning: ())
                        }
                        }
                    }, receiveValue: { res in
                        var updatedCategoryItem = self.categories[idx]
                        updatedCategoryItem.category.name = name
                        updatedCategoryItem.category.color = color
                        updatedCategoryItem.editMode = false
                        
                        self.categories[idx] = updatedCategoryItem
                        Account.shared.update(categories: self.categories.map({ c in
                            return c.category
                        }))
                    }).store(in: &cancellables)
            }
        }
        
        uploading = false
        return
    }
}
