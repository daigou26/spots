//
//  Created on 2021/12/16
//

import Foundation
import Photos
import SwiftUI

class ImageUseCaseImpl: ImageUseCase {
    func extractImagesData(assets: [PHAsset]) async -> [Data] {
        var images: [Data] = []
        await withTaskGroup(of: (Data?).self) { group in
            for asset in assets {
                group.addTask {
                    let uiImage = await self.getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize)
                    guard let uiImage = uiImage else {
                        return nil
                    }

                    return uiImage.jpegData(compressionQuality: 0)
                }
            }
            
            for await image in group {
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
    
    func getImageFromAsset(asset: PHAsset, size: CGSize) async -> UIImage? {
        let semaphore = DispatchSemaphore(value: 0)
        
        // To cache image
        let imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = true
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.isSynchronous = false
        
        var resizedImage: UIImage? = nil
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imageOptions) { image, _ in
            resizedImage = image
            semaphore.signal()
        }
        semaphore.wait()
        
        return resizedImage
    }
}
