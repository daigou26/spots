//
//  Created on 2021/11/14
//

import Foundation
import Firebase
import Combine

class ProfileViewModel: NSObject, ObservableObject {
    @Published var account = Account.shared
}
