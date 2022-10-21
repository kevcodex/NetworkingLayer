// Created by Kevin Chen on 9/25/20.
// Copyright © 2020 Kirby. All rights reserved.

import Foundation

public struct MultipartData {

    let data: Data

    /// The key name.
    let name: String

    let fileName: String?

    let mimeType: String?

    init(data: Data, name: String, fileName: String? = nil, mimeType: String? = nil) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }

}
