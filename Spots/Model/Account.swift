//
//  Created on 2021/11/14
//

import Foundation

// Logged in user's data(singlton)
final public class Account {
    private init() {}
    public static let shared = Account()
    
    public var uid: String = ""
    public var email: String = ""
    public var name: String = ""
    public var imageUrl: String? = ""
    
    public func save(uid: String, email: String, name: String, imageUrl: String?) {
        self.uid = uid
        self.email = email
        self.name = name
        self.imageUrl = imageUrl
    }
    
    public func reset() {
        self.uid = ""
        self.email = ""
        self.name = ""
        self.imageUrl = ""
    }
}
