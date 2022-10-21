//  Copyright © 2020 Kirby. All rights reserved.

import Foundation

struct ProgressResponse {

    let progress: Progress

    init(progress: Progress) {
        self.progress = progress
    }

    var isCompleted: Bool {
        return progress.fractionCompleted == 1.0
    }
}

public struct ProgressHandler {
    public let progressBlock: ((ProgressResponse) -> Void)
    public let callbackQueue: DispatchQueue

    public init(callbackQueue: DispatchQueue = .main,
         progressBlock: @escaping ((ProgressResponse) -> Void)) {
        self.callbackQueue = callbackQueue
        self.progressBlock = progressBlock
    }
}
