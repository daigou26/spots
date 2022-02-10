//
//  Created on 2021/11/25
//

import Foundation
import Combine

protocol SpotUseCase {
    func getSpot(spotId: String) -> AnyPublisher<Spot, Error>
    func getPhotos(spotId: String) -> AnyPublisher<[Photo], Error> 
    func checkSpotDuplication(title: String, address: String) -> AnyPublisher<CheckSpotDuplicationResponse, Error>
    func getSpots() -> AnyPublisher<[Spot]?, Error>
    func postSpot(mainImage: Data?, images: [Asset]?, title: String, address: String, favorite: Bool, star: Bool, memo: String) -> AnyPublisher<Spot, Error>
    func updateSpot(spotId: String, mainImage: Data?, images: [Asset]?, title: String?, address: String?, favorite: Bool?, star: Bool?, memo: String?, deleted: Bool?) -> AnyPublisher<(Spot, [Photo]), Error>
    func updatePhoto(spotId: String, photoId: String, photo: Photo) -> AnyPublisher<Photo, Error>
}
