//
//  Created on 2022/02/11
//

import Foundation
import FirebaseFirestore

class CategoryRepositoryImpl: CategoryRepository {
    let dbRef = Firestore.firestore().collection("categories")
    func getCategories(_ uid: String) async throws -> [Category] {
        var categories: [Category] = []
        let snapshot = try await dbRef.whereField("uid", isEqualTo: uid).whereField("deleted", isEqualTo: false).getDocuments()
        
        if !snapshot.isEmpty {
            for doc in snapshot.documents {
                let data = doc.data()
                if doc.exists,
                   let name: String = data["name"] as? String,
                   let color: String = data["color"] as? String,
                   let idx: Int = data["idx"] as? Int,
                   let createdAt: Date = (data["createdAt"] as? Timestamp)?.dateValue() {
                    categories.append(Category(id: doc.documentID, name: name, color: color, idx: idx, createdAt: createdAt, deleted: false))
                }
            }
        }
        categories.sort {
            return  $0.idx < $1.idx
        }
        return categories
    }
    
    func postCategory(uid: String, category: Category) async throws -> Category {
        var category = category
        let docId = dbRef.document().documentID
        var data = category.asDictionary
        data["uid"] = uid
        data["createdAt"] = Timestamp(date: data["createdAt"] as? Date ?? Date())
        try await dbRef.document(docId).setData(data)
        category.id = docId
        return category
    }
    
    func updateCategory(categoryId: String, name: String?, color: String?, idx: Int?) async throws {
        var data: [String: Any] = [:]
        
        if let name = name {
            data["name"] = name
        }
        if let color = color {
            data["color"] = color
        }
        if let idx = idx {
            data["idx"] = idx
        }
        try await dbRef.document(categoryId).updateData(data)
    }
}
