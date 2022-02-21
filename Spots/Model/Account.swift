//
//  Created on 2021/11/14
//

import Foundation

// Logged in user's data(singlton)
final class Account {
    private init() {}
    static let shared = Account()
    
    var uid: String = ""
    var email: String = ""
    var name: String = ""
    var imageUrl: String? = ""
    var categories: [Category] = []
    
    func save(uid: String, email: String, name: String, imageUrl: String?, categories: [Category]) {
        self.uid = uid
        self.email = email
        self.name = name
        self.imageUrl = imageUrl
        self.categories = categories
    }
    
    func update(categories: [Category]) {
        self.categories = categories
    }
    
    func reset() {
        self.uid = ""
        self.email = ""
        self.name = ""
        self.imageUrl = ""
        self.categories = []
    }
}
