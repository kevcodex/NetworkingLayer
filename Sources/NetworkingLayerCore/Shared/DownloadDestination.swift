//
//  DownloadDestination.swift
//  
//
//  Created by Kevin Chen on 4/15/23.
//

import Foundation

public struct DownloadDestination {
    public let destinationURL: URL
    public let options: [Option]
    
    public enum Option: CaseIterable {
        case createIntermediateDirectories
        case removePreviousFile
    }
}
