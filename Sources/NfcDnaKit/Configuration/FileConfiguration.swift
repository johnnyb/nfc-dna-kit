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
    var fileData: [UInt8]?
        
    var sdmEnabled: Bool = false
    var communicationMode: CommuncationMode = .PLAIN
    var readPermission: Permission = .ALL
    var writePermission: Permission = .ALL
    var changePermission: Permission = .ALL
    var fileSize: Int?
    var sdmOptionUid: Bool = false
    var sdmOptionReadCounter: Bool = false
    var sdmOptionReadCounterLimit: Bool = false
    var sdmOptionEncryptFileData: Bool = false
    var sdmOptionUseAscii: Bool = false
    var sdmMetaReadPermission: Permission = .ALL
    var sdmFileReadPermission: Permission = .ALL
    var sdmReadCounterRetrievalPermission: Permission = .ALL
    var sdmUidOffset: Int?
    var sdmReadCounterOffset: Int?
    var sdmPiccDataOffset: Int?
    var sdmMacInputOffset: Int?
    var sdmMacOffset: Int?
    var sdmEncOffset: Int?
    var sdmEncLength: Int?
    var sdmReadCounterLimit: Int?
     
    //     val SDM_READ_COUNTER_NO_MIRRORING = 16777215
}
