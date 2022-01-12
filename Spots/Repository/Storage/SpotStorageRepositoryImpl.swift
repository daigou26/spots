//
//  Created on 2021/12/09
//

import Foundation
import FirebaseStorage

class SpotStorageRepositoryImpl: SpotStorageRepository {
    var ref = Storage.storage().reference()
    
    func uploadMainImage(spotId: String, image: Data) async throws -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var imageUrl: String = ""
        var error: Error? = nil
        
        let newRef = ref.child("spots/\(spotId)/main")
        let uploadTask = newRef.putData(image)
        uploadTask.observe(.success) { _ in
            newRef.downloadURL { url, e in
                if e != nil {
                    error = e
                }
                if let url = url {
                    imageUrl = url.absoluteString
                }
                semaphore.signal()
            }
        }
        uploadTask.observe(.failure) { snapshot in
            if let e = snapshot.error {
                error = e
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        
        if let error = error {
            throw error
        }
        return imageUrl
    }
    
    func uploadImages(spotId: String, images: [Data]) async -> [Photo] {
        let timestamp = Int(Date().timeIntervalSince1970)
        var photos: [Photo] = []
        let date = Date()

        await withTaskGroup(of: (Photo?).self) { group in
            for (index, image) in images.enumerated() {
                let name = "\(timestamp)_\(index)"
                let path = "spots/\(spotId)/images/\(name)"
                group.addTask {
                    return await self.upload(index: index, path: path, name: name, image: image, date: date)
                }
            }
            
            for await photo in group {
                if let photo = photo {
                    photos.append(photo)
                }
            }
        }
        return photos
    }
    
    func upload(index: Int, path: String, name: String, image: Data, date: Date) async -> Photo? {
        let newRef = ref.child(path)
        let semaphore = DispatchSemaphore(value: 0)
        let uploadTask = newRef.putData(image)
        var imageUrl: String? = nil

        uploadTask.observe(.success) { _ in
            newRef.downloadURL { url, e in
                if let url = url {
                    imageUrl = url.absoluteString
                }
                semaphore.signal()
            }
        }
        semaphore.wait()

        if let imageUrl = imageUrl {
            return Photo(imageUrl: imageUrl, name: name, timestamp: date, createdAt: date)
        }
        return nil
    }
}
