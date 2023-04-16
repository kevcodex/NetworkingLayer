// Created by Kirby 191 on 8/4/20.
// Copyright © 2020 Kirby. All rights reserved.

import Foundation

public protocol CodableRequest: NetworkRequest {
    associatedtype Response: Decodable
}
