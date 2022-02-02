//
//  Created on 2021/12/09
//

import Foundation
import FirebaseStorage

class SpotStorageRepositoryImpl: SpotStorageRepository {
    var ref = Storage.storage().reference()
    
    func uploadMainImage(spotId: String, image: Data) async throws -> String {
        var error: Error?
        
        let newRef = ref.child("spots/\(spotId)/main")
        let uploadTask = newRef.putData(image)
        
        // Convert a completion handler into an async function
        let imageUrl: String? = try await withCheckedThrowingContinuation { continuation in
            var imageUrl: String?
            uploadTask.observe(.success) { _ in
                newRef.downloadURL { url, e in
                    if e != nil {
                        error = e
                    }
                    if let url = url {
                        imageUrl = url.absoluteString
                    }
                    continuation.resume(returning: imageUrl)
                }
            }
            uploadTask.observe(.failure) { snapshot in
                if let e = snapshot.error {
                    error = e
                }
                continuation.resume(returning: imageUrl)
            }
        }
        
        if let imageUrl = imageUrl {
            return imageUrl
        }
        
        if let error = error {
            throw error
        }
        throw QueryError.SomethingWentWrong
    }
    
    func uploadImages(spotId: String, images: [(data: Data, width: Float, height: Float)]) async -> [Photo] {
        let timestamp = Int(Date().timeIntervalSince1970)
        let date = Date()

        let photos: [Photo?] = await withTaskGroup(of: (Photo?).self, returning: [Photo?].self) { group in
            for (index, image) in images.enumerated() {
                let name = "\(timestamp)_\(index)"
                let path = "spots/\(spotId)/images/\(name)"
                group.addTask {
                    return await self.upload(path: path, name: name, image: image, date: date)
                }
            }
            
            var results: [Photo?] = []
            for await photo in group {
                if let photo = photo {
                    results.append(photo)
                }
            }

            return results
        }
        return photos.compactMap { $0 }
    }
    
    func upload(path: String, name: String, image: (data: Data, width: Float, height: Float), date: Date) async -> Photo? {
        let newRef = ref.child(path)
        let uploadTask = newRef.putData(image.data)

        let imageUrl: String? = await withCheckedContinuation { continuation in
            uploadTask.observe(.success) { _ in
                newRef.downloadURL { url, e in
                    var imageUrl: String? = nil
                    if let url = url {
                        imageUrl = url.absoluteString
                    }
                    continuation.resume(returning: imageUrl)
                }
            }
        }

        if let imageUrl = imageUrl {
            return Photo(imageUrl: imageUrl, name: name, width: image.width, height: image.height, timestamp: date, createdAt: date)
        }
        return nil
    }
}
