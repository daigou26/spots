//
//  Created on 2021/12/01
//

import Foundation
import Photos
import UIKit

class ImagePickerViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var libraryStatus = PhotoAuthStatus.Denied
    @Published var photos: [Asset] = []
    @Published var selectedImagePreview: UIImage? = nil
    @Published var selectedImages: [Asset] = []
    var allPhotos: PHFetchResult<PHAsset>!
    
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
                    fetchPhotos(thmbnailSize)
                case .limited:
                    libraryStatus = .Limited
                    fetchPhotos(thmbnailSize)
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
        guard let _ = allPhotos else {return}
        if let updates = changeInstance.changeDetails(for: allPhotos) {
            let updatedPhotos = updates.fetchResultAfterChanges
            updatedPhotos.enumerateObjects {[self] asset, index, _ in
                if asset.mediaType != .image {return}
                if !allPhotos.contains(asset) {
                    // If it's not included, get the image and append to array
                    getImageFromAsset(asset: asset, size: CGSize(width: 150, height: 150)) { image in
                        DispatchQueue.main.async {
                            photos.append(Asset(asset: asset, image: image))
                        }
                    }
                }
            }
            
            allPhotos.enumerateObjects { asset, index, _ in
                if !updatedPhotos.contains(asset) {
                    DispatchQueue.main.async {
                        self.photos.removeAll() { result in
                            return result.asset == asset
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.allPhotos = updatedPhotos
            }
        }
    }
    
    func fetchPhotos(_ thmbnailSize: Int) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.includeHiddenAssets = false
        
        
        let fetchResults = PHAsset.fetchAssets(with: options)
        allPhotos = fetchResults
        fetchResults.enumerateObjects {[self] asset, index, _ in
            if asset.mediaType == .image {
                getImageFromAsset(asset: asset, size: CGSize(width: thmbnailSize, height: thmbnailSize)) { image in
                    photos.append(Asset(asset: asset, image: image))
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
