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
            if let data = data, let title: String = data["title"] as? String, let address: String = data["address"] as? String, let favorite: Bool = data["favorite"] as? Bool, let star: Bool = data["star"] as? Bool, let latitude: Double = data["latitude"] as? Double, let longitude: Double =  data["longitude"] as? Double {
                let imageUrl = data["imageUrl"] as? String
                let category = data["category"] as? [String]
                let memo = data["memo"] as? String
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
                let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                
                var imageUploadingStatus: [ImageUploadingStatus] = []
                if let uploadingStatus = data["imageUploadingStatus"] as? [[String: Any]] {
                    for s in uploadingStatus {
                        if let count = s["count"] as? Int, let userName = s["userName"] as? String, let startedAt = (s["startedAt"] as? Timestamp)?.dateValue() {
                            imageUploadingStatus.append(ImageUploadingStatus(count: count, userName: userName, startedAt: startedAt))
                        }
                    }
                }
                
                return Spot(id: doc.documentID, title: title, imageUrl: imageUrl, address: address, latitude: latitude, longitude: longitude, favorite: favorite, star: star, imageUploadingStatus: imageUploadingStatus, category: category, memo: memo, createdAt: createdAt, updatedAt: updatedAt)
            }
        }
        throw QueryError.NotFound
    }
    
    func getSpotByAddress(uid: String, address: String) async throws -> [Spot] {
        var spots: [Spot] = []
        let snapshot = try await dbRef.whereField("uid", isEqualTo: uid).whereField("address", isEqualTo: address).getDocuments()
        
        if !snapshot.isEmpty {
            for doc in snapshot.documents {
                let data = doc.data()
                if doc.exists, let title: String = data["title"] as? String, let address: String = data["address"] as? String, let favorite: Bool = data["favorite"] as? Bool, let star: Bool = data["star"] as? Bool, let latitude: Double = data["latitude"] as? Double, let longitude: Double =  data["longitude"] as? Double {
                    let imageUrl = data["imageUrl"] as? String
                    let category = data["category"] as? [String]
                    let memo = data["memo"] as? String
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
                    let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
                    spots.append(Spot(id: doc.documentID, title: title, imageUrl: imageUrl, address: address, latitude: latitude, longitude: longitude, favorite: favorite, star: star, category: category, memo: memo, createdAt: createdAt, updatedAt: updatedAt))
                }
            }
        }
        return spots
    }
    
    func getPhotos(spotId: String) async throws -> [Photo] {
        var photos: [Photo] = []
        let snapshot = try await dbRef.document(spotId).collection("photos").getDocuments()
        if !snapshot.isEmpty {
            for doc in snapshot.documents {
                let data = doc.data()
                if doc.exists, let imageUrl: String = data["imageUrl"] as? String, let name: String = data["name"] as? String, let  width: Float = data["width"] as? Float, let height: Float = data["height"] as? Float {
                    let timestamp = (data["timestamp"] as! Timestamp).dateValue()
                    photos.append(Photo(id: doc.documentID, imageUrl: imageUrl, name: name, width: width, height: height, timestamp: timestamp))
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
                if document.exists, let title: String = data["title"] as? String, let address: String = data["address"] as? String, let favorite: Bool = data["favorite"] as? Bool, let star: Bool = data["star"] as? Bool, let latitude: Double = data["latitude"] as? Double, let longitude: Double =  data["longitude"] as? Double {
                    let imageUrl = data["imageUrl"] as? String
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
    
    func postSpot(uid: String, spot: Spot) async throws {
        var data = spot.asDictionary
        data["createdAt"] = Timestamp(date: spot.createdAt ?? Date())
        data["uid"] = uid
        
        if let imageUploadingStatus = spot.imageUploadingStatus?.first, imageUploadingStatus.count > 0 {
            var imageUploadingStatusData = imageUploadingStatus.asDictionary
            imageUploadingStatusData["startedAt"] = Timestamp(date: imageUploadingStatus.startedAt)
            data["imageUploadingStatus"] = FieldValue.arrayUnion([imageUploadingStatusData])
        } else {
            data["imageUploadingStatus"] = []
        }
        
        let error: Error? = try await withCheckedThrowingContinuation { continuation in
            let _ = dbRef.document(spot.id ?? "").setData(data) { err in
                var error: Error?
                if let err = err {
                    error = err
                }
                continuation.resume(returning: error)
            }
        }
        
        if let error = error {
            throw error
        }
        return
    }
    
    func updateSpot(
        spotId: String,
        title: String?,
        imageUrl: String?,
        address: String?,
        latitude: Double?,
        longitude: Double?,
        favorite: Bool?,
        star: Bool?,
        imageUploadingStatus: [ImageUploadingStatus]?,
        category: [String]?,
        memo: String?,
        updatedAt: Date
    ) async throws {
        var data: [String: Any] = [:]
        
        if let title = title {
            data["title"] = title
        }
        
        if let imageUrl = imageUrl {
            data["imageUrl"] = imageUrl
        }
        
        if let address = address, let latitude = latitude, let longitude = longitude {
            data["address"] = address
            data["latitude"] = latitude
            data["longitude"] = longitude
        }
        
        if let favorite = favorite {
            data["favorite"] = favorite
        }
       
        if let star = star {
            data["star"] = star
        }
        
        if let imageUploadingStatus = imageUploadingStatus?.first, imageUploadingStatus.count > 0 {
            var imageUploadingStatusData = imageUploadingStatus.asDictionary
            imageUploadingStatusData["startedAt"] = Timestamp(date: imageUploadingStatus.startedAt)
            data["imageUploadingStatus"] = FieldValue.arrayUnion([imageUploadingStatusData])
        }
        
        if let category = category {
            data["category"] = category
        }
        
        if let memo = memo {
            data["memo"] = memo
        }
        
        data["updatedAt"] = Timestamp(date: updatedAt)
        
        let error: Error? = try await withCheckedThrowingContinuation { continuation in
            let _ = dbRef.document(spotId).updateData(data) { err in
                var error: Error?
                if let err = err {
                    error = err
                }
                continuation.resume(returning: error)
            }
        }
        
        if let error = error {
            throw error
        }
        return
    }
    
    func updateImageUploadingStatus(uid: String, spotId: String, imageUploadingStatus: ImageUploadingStatus) async {
        var data: [String: Any] = [:]
        var imageUploadingStatusData = imageUploadingStatus.asDictionary
        imageUploadingStatusData["startedAt"] = Timestamp(date: imageUploadingStatus.startedAt)
        data["imageUploadingStatus"] = FieldValue.arrayRemove([imageUploadingStatusData])
        
        let _ = dbRef.document(spotId).updateData(data) { err in
            if let err = err {
                // TODO: send log
            }
        }
        return
    }
    
    func postPhotos(uid: String, spotId: String, photos: [Photo]) async {
        let batch = Firestore.firestore().batch()
        
        for photo in photos {
            var data = photo.asDictionary
            data["uid"] = uid
            data["timestamp"] = Timestamp(date: photo.timestamp)
            data["createdAt"] = Timestamp(date: photo.createdAt ?? photo.timestamp)
            dbRef.document(spotId).collection("photos").addDocument(data: data)
        }
        
        let _ = batch.commit() { err in
            if let err = err {
                // TODO: send log
            }
        }
        return
    }
}
