//  Copyright © 2020 Kirby. All rights reserved.

import Alamofire

public enum RequestType {
    case requestData

    /// If download destination is nil, it will not save to file system.
    /// It will however be saved in a temporary URL in the response, that you can get accordingly
    case download(DownloadDestination?)

    case uploadMultipart(body: [MultipartData])
}
