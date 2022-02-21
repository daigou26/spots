//
//  Created on 2021/12/01
//

import Foundation
import Photos
import UIKit

class ImagePickerViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var libraryStatus = PhotoAuthStatus.Denied
    @Published var assets: [Asset] = []
    @Published var selectedImagePreview: UIImage? = nil
    @Published var selectedImages: [Asset] = []
    var allAssets: PHFetchResult<PHAsset>!
    
    override init() {
        super.init()
        // Register observer
        PHPhotoLibrary.shared().register(self)
    }
    
    func setUp(_ thmbnailSize: Int) {
        // Request permission
        PHPhotoLibrary.requestAuthorization(for: .readWrite) {[self] status in
            DispatchQueue.main.async {
                switch status {
                case .denied: libraryStatus = .Denied
                case .authorized:
                    libraryStatus = .Approved
                    fetchAssets(thmbnailSize)
                case .limited:
                    libraryStatus = .Limited
                    fetchAssets(thmbnailSize)
                default: libraryStatus = .Denied
                }
            }
        }
    }
    
    func setSelectedImages(_ asset: Asset) {
        if selectedImages.contains(asset) {
            selectedImages.removeAll() {result in
                return result == asset
            }
        } else {
            selectedImages.append(asset)
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let _ = allAssets else {return}
        if let updates = changeInstance.changeDetails(for: allAssets) {
            let updatedAssets = updates.fetchResultAfterChanges
            updatedAssets.enumerateObjects {[self] asset, index, _ in
                if asset.mediaType != .image {return}
                if !allAssets.contains(asset) {
                    // If it's not included, get the image and append to array
                    getImageFromAsset(asset: asset, size: CGSize(width: 150, height: 150)) { image in
                        DispatchQueue.main.async {
                            assets.append(Asset(asset: asset, image: image))
                        }
                    }
                }
            }
            
            allAssets.enumerateObjects { asset, index, _ in
                if !updatedAssets.contains(asset) {
                    DispatchQueue.main.async {
                        self.assets.removeAll() { result in
                            return result.asset == asset
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.allAssets = updatedAssets
            }
        }
    }
    
    func fetchAssets(_ thmbnailSize: Int) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.includeHiddenAssets = false
        
        let fetchResults = PHAsset.fetchAssets(with: options)
        allAssets = fetchResults
        fetchResults.enumerateObjects {[self] asset, index, _ in
            if asset.mediaType == .image {
                getImageFromAsset(asset: asset, size: CGSize(width: thmbnailSize, height: thmbnailSize)) { image in
                    assets.append(Asset(asset: asset, image: image))
                }
            }
        }
    }
    
    // Called if the image is selected
    func extractPreviewData(asset: PHAsset) {
        if asset.mediaType == .image {
            getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize) { image in
                DispatchQueue.main.async {
                    self.selectedImagePreview = image
                }
            }
        }
    }
    
    func getImageFromAsset(asset: PHAsset, size: CGSize, completion: @escaping (UIImage) -> ()) {
        // To cache image
        let imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = true
        
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.isSynchronous = false
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imageOptions) { image, _ in
            guard let resizedImage = image else {return}
            completion(resizedImage)
            
        }
    }
}
