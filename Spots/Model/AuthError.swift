//
//  Created on 2021/11/12
//

import Foundation

enum AuthError: Error {
    case unknown
    case notFoundUser
    case invalid
    case expired
}

// TODO: Localize
extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown: return "Someting went wrong"
        case .notFoundUser: return "Not found User"
        case .invalid: return "Invalid authentication"
        case .expired: return "Authentication expired"
        }
    }
}
