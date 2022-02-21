//
//  Created on 2021/11/12
//

import Foundation

enum AuthError: Error {
    case Unknown
    case NotFoundUser
    case Invalid
    case Expired
}

// TODO: Localize
extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .Unknown: return "Someting went wrong"
        case .NotFoundUser: return "Not found User"
        case .Invalid: return "Invalid authentication"
        case .Expired: return "Authentication expired"
        }
    }
}
