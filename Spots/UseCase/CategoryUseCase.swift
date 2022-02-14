//
//  Created on 2022/02/13
//

import Foundation
import Combine

protocol CategoryUseCase {
    func postCategory(name: String, color: String, idx: Int) -> AnyPublisher<Category, Error>
    func updateCategory(categoryId: String, name: String?, color: String?, idx: Int?) -> AnyPublisher<Bool, Error>
}
