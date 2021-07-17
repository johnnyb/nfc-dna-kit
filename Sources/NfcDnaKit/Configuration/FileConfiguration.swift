//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

import Foundation

public enum CommuncationMode: UInt8 {
    case PLAIN = 0
    case MAC = 1
    case PLAIN_ALT = 2
    case FULL = 3
}

public enum Permission: UInt8 {
    case KEY_0 = 0
    case KEY_1 = 1
    case KEY_2 = 2
    case KEY_3 = 3
    case KEY_4 = 4
    case ALL = 0xe
    case NONE = 0xf
}

public enum FileSpecifier: UInt8 {
    case CC_FILE = 1      // 32 bytes  (pg. 10)
    case NDEF_FILE = 2    // 256 bytes
    case PROPRIETARY = 3  // 128 bytes
}

public class FileConfiguration {
    public var fileData: [UInt8]?
        
    public var sdmEnabled: Bool = false
    public var communicationMode: CommuncationMode = .PLAIN
    public var readPermission: Permission = .ALL
    public var writePermission: Permission = .ALL
    public var changePermission: Permission = .ALL
    public var fileSize: Int?
    public var sdmOptionUid: Bool = false
    public var sdmOptionReadCounter: Bool = false
    public var sdmOptionReadCounterLimit: Bool = false
    public var sdmOptionEncryptFileData: Bool = false
    public var sdmOptionUseAscii: Bool = false
    public var sdmMetaReadPermission: Permission = .ALL
    public var sdmFileReadPermission: Permission = .ALL
    public var sdmReadCounterRetrievalPermission: Permission = .ALL
    public var sdmUidOffset: Int?
    public var sdmReadCounterOffset: Int?
    public var sdmPiccDataOffset: Int?
    public var sdmMacInputOffset: Int?
    public var sdmMacOffset: Int?
    public var sdmEncOffset: Int?
    public var sdmEncLength: Int?
    public var sdmReadCounterLimit: Int?
     
    //     val SDM_READ_COUNTER_NO_MIRRORING = 16777215
    
    public init() {
        
    }
}
