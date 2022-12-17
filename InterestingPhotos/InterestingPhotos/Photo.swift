// Photo.swift

import UIKit

class Photo: NSObject, Codable {
    var caption: String
    var photoName: String

    init(caption: String, photoName: String) {
        self.caption = caption
        self.photoName = photoName
    }
}
