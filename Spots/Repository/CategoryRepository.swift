//
//  Created on 2022/02/11
//

import Foundation

protocol CategoryRepository {
    func getCategories(_ uid: String) async throws -> [Category]
    func postCategory(uid: String, category: Category) async throws -> Category
    func updateCategory(categoryId: String, name: String?, color: String?, idx: Int?) async throws -> Void
}
