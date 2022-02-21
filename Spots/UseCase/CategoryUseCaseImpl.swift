//
//  Created on 2022/02/13
//

import Foundation
import Combine

class CategoryUseCaseImpl: CategoryUseCase {
    let categoryRepository: CategoryRepository
    let uid = Account.shared.uid
    
    init(categoryRepository: CategoryRepository = CategoryRepositoryImpl()) {
        self.categoryRepository = categoryRepository
    }
    
    func postCategory(name: String, color: String, idx: Int) -> AnyPublisher<Category, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        let category = Category(id: "", name: name, color: color, idx: idx, createdAt: Date(), deleted: false)
                        
                        let res = try await self.categoryRepository.postCategory(uid: self.uid, category: category)
                        promise(.success(res))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateCategory(categoryId: String, name: String?, color: String?, idx: Int?) -> AnyPublisher<Bool, Error> {
        return Deferred {
            Future { promise in
                Task {
                    do {
                        try await self.categoryRepository.updateCategory(categoryId: categoryId, name: name, color: color, idx: idx)
                        promise(.success(true))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
