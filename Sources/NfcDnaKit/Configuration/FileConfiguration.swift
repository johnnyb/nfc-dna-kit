//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

import Foundation

public enum CommuncationMode: UInt8, Codable {
    case PLAIN = 0
    case MAC = 1
    case PLAIN_ALT = 2
    case FULL = 3
}

public enum Permission: UInt8, Codable {
    case KEY_0 = 0
    case KEY_1 = 1
    case KEY_2 = 2
    case KEY_3 = 3
    case KEY_4 = 4
    case ALL = 0xe
    case NONE = 0xf
    
    func displayValue() -> String {
        switch self {
        case .KEY_0:
            return "Key 0"
        case .KEY_1:
            return "Key 1"
        case .KEY_2:
            return "Key 2"
        case .KEY_3:
            return "Key 3"
        case .KEY_4:
            return "Key 4"
        case .ALL:
            return "All"
        case .NONE:
            return "None"
        }
    }
}

public enum FileSpecifier: UInt8, Codable {
    case CC_FILE = 1      // 32 bytes  (pg. 10)
    case NDEF_FILE = 2    // 256 bytes
    case PROPRIETARY = 3  // 128 bytes
    
    func size() -> Int {
        switch self {
        case .CC_FILE:
            return 32
        case .NDEF_FILE:
            return 256
        case .PROPRIETARY:
            return 128
        }
    }
}

public class FileConfiguration: Codable {
    public var fileSpecifier: FileSpecifier = .NDEF_FILE
    public var fileData: [UInt8] = []
    public var fileSettings = FileSettings()
     
    //     val SDM_READ_COUNTER_NO_MIRRORING = 16777215
    
    public init() {
        
    }
}
