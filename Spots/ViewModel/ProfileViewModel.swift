//
//  Created on 2021/11/14
//

import Foundation
import Firebase
import Combine

class ProfileViewModel: ObservableObject {
    @Published var account = Account.shared
}
