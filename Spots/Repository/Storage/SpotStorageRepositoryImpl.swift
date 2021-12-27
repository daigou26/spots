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
    
    func uploadImages(spotId: String, images: [Data]) async -> [String] {
        let timestamp = Int(Date().timeIntervalSince1970)
        var imageUrls: [String] = []

        await withTaskGroup(of: (String?).self) { group in
            for (index, image) in images.enumerated() {
                let path = "spots/\(spotId)/images/\(timestamp)_\(index)"
                group.addTask {
                    return await self.upload(index: index, path: path, image: image)
                }
            }
            
            for await imageUrl in group {
                if let imageUrl = imageUrl {
                    imageUrls.append(imageUrl)
                }
            }
        }
        return imageUrls
    }
    
    func upload(index: Int, path: String, image: Data) async -> String? {
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

        return imageUrl
    }
}
