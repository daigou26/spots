//
//  Created on 2021/11/25
//

import Foundation
import FirebaseFirestore

class SpotRepositoryImpl: SpotRepository {
    let dbRef = Firestore.firestore().collection("spots")
    
    func getSpot(spotId: String) async throws -> Spot {
        let doc = try await dbRef.document(spotId).getDocument()
        if doc.exists {
            let data = doc.data()
            if let data = data, let title: String = data["title"] as? String, let address: String = data["address"] as? String, let imageUrl: String = data["imageUrl"] as? String, let favorite: Bool = data["favorite"] as? Bool, let star: Bool = data["star"] as? Bool, let latitude: Double = data["latitude"] as? Double, let longitude: Double =  data["longitude"] as? Double {
                let category = data["category"] as? [String]
                let memo = data["memo"] as? String
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
                let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                return Spot(id: doc.documentID, title: title, imageUrl: imageUrl, address: address, latitude: latitude, longitude: longitude, favorite: favorite, star: star, category: category, memo: memo, createdAt: createdAt, updatedAt: updatedAt)
            }
        }
        throw QueryError.NotFound
    }
    
    func getSpotByAddress(uid: String, address: String) async throws -> [Spot] {
        var spots: [Spot] = []
        let snapshot = try await dbRef.whereField("uid", isEqualTo: uid).getDocuments()
        
        if !snapshot.isEmpty {
            for doc in snapshot.documents {
                let data = doc.data()
                if doc.exists, let title: String = data["title"] as? String, let address: String = data["address"] as? String, let imageUrl: String = data["imageUrl"] as? String, let favorite: Bool = data["favorite"] as? Bool, let star: Bool = data["star"] as? Bool, let latitude: Double = data["latitude"] as? Double, let longitude: Double =  data["longitude"] as? Double {
                    let category = data["category"] as? [String]
                    let memo = data["memo"] as? String
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
                    let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                    spots.append(Spot(id: doc.documentID, title: title, imageUrl: imageUrl, address: address, latitude: latitude, longitude: longitude, favorite: favorite, star: star, category: category, memo: memo, createdAt: createdAt, updatedAt: updatedAt))
                }
            }
            return spots
        }
        throw QueryError.NotFound
    }
    
    func getPhotos(spotId: String) async throws -> [Photo] {
        var photos: [Photo] = []
        let snapshot = try await dbRef.document(spotId).collection("photos").getDocuments()
        if !snapshot.isEmpty {
            for doc in snapshot.documents {
                let data = doc.data()
                if doc.exists, let imageUrl: String = data["imageUrl"] as? String, let name: String = data["name"] as? String {
                    let timestamp = (data["timestamp"] as! Timestamp).dateValue()
                    photos.append(Photo(id: doc.documentID, imageUrl: imageUrl, name: name, timestamp: timestamp))
                }
            }
        }

        return photos
    }
    
    func getSpots(uid: String) async throws -> [Spot]? {
        var spots: [Spot] = []
        let snapshot = try await dbRef.whereField("uid", isEqualTo: uid).getDocuments()
        if !snapshot.isEmpty {
            for document in snapshot.documents {
                let data = document.data()
                if document.exists, let title: String = data["title"] as? String, let address: String = data["address"] as? String, let imageUrl: String = data["imageUrl"] as? String, let favorite: Bool = data["favorite"] as? Bool, let star: Bool = data["star"] as? Bool, let latitude: Double = data["latitude"] as? Double, let longitude: Double =  data["longitude"] as? Double {
                    let category = data["category"] as? [String]
                    let memo = data["memo"] as? String
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
                    let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                    spots.append(Spot(id: document.documentID, title: title, imageUrl: imageUrl, address: address, latitude: latitude, longitude: longitude, favorite: favorite, star: star, category: category, memo: memo, createdAt: createdAt, updatedAt: updatedAt))
                }
            }
        }
        return spots
    }
    
    func getNewDocumentId() -> String {
        return dbRef.document().documentID
    }
    
    func postSpot(uid: String, spot: Spot, assets: [Data]?) async throws {
        let semaphore = DispatchSemaphore(value: 0)
        var error: Error? = nil
        var data = spot.asDictionary
        data["id"] = spot.id
        data["createdAt"] = Timestamp(date: Date())
        data["uid"] = uid
        
        dbRef.addDocument(data: data) { err in
            if let err = err {
                error = err
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = error {
            throw error
        }
        return
    }
    
    func postPhotos(uid: String, spot: Spot, assets: [Data]?) async throws {
        let semaphore = DispatchSemaphore(value: 0)
        var error: Error? = nil
        var data = spot.asDictionary
        data["id"] = spot.id
        data["createdAt"] = Timestamp(date: Date())
        data["uid"] = uid
        
        dbRef.addDocument(data: data) { err in
            if let err = err {
                error = err
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = error {
            throw error
        }
        return
    }
}
