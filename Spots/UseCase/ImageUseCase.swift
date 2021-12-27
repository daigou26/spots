//
//  Created on 2021/12/16
//

import Foundation
import Photos
import UIKit

protocol ImageUseCase {
    func extractImagesData(assets: [PHAsset]) async -> [Data]
}
