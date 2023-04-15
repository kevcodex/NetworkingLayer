//
//  DownloadDestination.swift
//  
//
//  Created by Kevin Chen on 4/15/23.
//

import Foundation

public struct DownloadDestination {
    let destinationURL: URL
    let options: [Option]
    
    public enum Option: CaseIterable {
        case createIntermediateDirectories
        case removePreviousFile
    }
}
