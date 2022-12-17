// Country.swift

import UIKit

class Country: NSObject, Codable {
    let name: String
    let shortDescription: String

    init(name: String, shortDescription: String) {
        self.name = name
        self.shortDescription = shortDescription
    }

    static var example = Country(name: "Name", shortDescription: "Short description")
}
