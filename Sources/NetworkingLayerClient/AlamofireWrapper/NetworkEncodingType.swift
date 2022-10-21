//  Copyright © 2020 Kirby. All rights reserved.
//

import Foundation

public enum NetworkEncodingType {
    case json
}

extension NetworkEncodingType {
    var contentTypeValue: String {
        switch self {
        case .json:
            return "application/json"
        }
    }
}
