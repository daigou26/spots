//
//  Created on 2021/12/16
//

import Foundation
import Photos
import SwiftUI

class ImageUseCaseImpl: ImageUseCase {
    func extractImagesData(assets: [PHAsset]) async -> [(data: Data, width: Float, height: Float)] {
        var images: [(data: Data, width: Float, height: Float)] = []
        await withTaskGroup(of: ((data: Data, width: Float, height: Float)?).self) { group in
            for asset in assets {
                group.addTask {
                    let uiImage = await self.getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize)
                    guard let uiImage = uiImage, let jpeg = uiImage.jpegData(compressionQuality: 0) else {
                        return nil
                    }

                    return (data: jpeg, width: Float(uiImage.size.width), height: Float(uiImage.size.height))
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
        // To cache image
        let imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = true
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.isSynchronous = true
        
        var resizedImage: UIImage? = nil
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imageOptions) { image, _ in
            resizedImage = image
        }
        
        return resizedImage
    }
}
