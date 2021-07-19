//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/19/21.
//

import Foundation
public class FileSettings {
    public var sdmEnabled: Bool = false
    public var communicationMode: CommuncationMode = .PLAIN
    public var readPermission: Permission = .ALL
    public var writePermission: Permission = .ALL
    public var readWritePermission: Permission = .ALL
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
    
    public var fileType: UInt8? // Basically read-only
    
    init() {
        
    }
    
    convenience init(fromResultData: NxpCommandResult) {
        // Pg. 13
        
        self.init()
        let data = fromResultData.data
        fileType = data[0]
        let options = data[1]
        sdmEnabled = Helper.getBitLSB(options, 6)
        
        communicationMode = .PLAIN
        if Helper.getBitLSB(options, 1) && Helper.getBitLSB(options, 0) {
            communicationMode = .FULL
        }
        if Helper.getBitLSB(options, 0) && Helper.getBitLSB(options, 0) {
            communicationMode = .MAC
        }
        
        
        readPermission = Permission(rawValue: Helper.leftNibble(data[2]))!
        writePermission = Permission(rawValue: Helper.rightNibble(data[2]))!
        readWritePermission = Permission(rawValue: Helper.leftNibble(data[3]))!
        changePermission = Permission(rawValue: Helper.rightNibble(data[3]))!
        
        fileSize = Helper.bytesToIntLE(Array(data[4...6]))
        
        var currentOffset = 7
        
        if sdmEnabled {
            let sdmOptions = data[currentOffset]
            currentOffset += 1
            
            sdmOptionUid = Helper.getBitLSB(sdmOptions, 7)
            sdmOptionReadCounter = Helper.getBitLSB(sdmOptions, 6)
            sdmOptionReadCounterLimit = Helper.getBitLSB(sdmOptions, 5)
            sdmOptionEncryptFileData = Helper.getBitLSB(sdmOptions, 4)
            sdmOptionUseAscii = Helper.getBitLSB(sdmOptions, 0)
            
            let sdmAccessRights1 = data[currentOffset]
            currentOffset += 1
            let sdmAccessRights2 = data[currentOffset]
            currentOffset += 1
            sdmMetaReadPermission = Permission(rawValue: Helper.leftNibble(sdmAccessRights1))!
            sdmFileReadPermission = Permission(rawValue: Helper.rightNibble(sdmAccessRights1))!
            sdmReadCounterRetrievalPermission = Permission(rawValue: Helper.rightNibble(sdmAccessRights2))!
            
            if sdmMetaReadPermission == .ALL {
                if sdmOptionUid {
                    sdmUidOffset = Helper.bytesToIntLE(Array(data[currentOffset...(currentOffset + 2)]))
                    currentOffset += 3
                }
                if sdmOptionReadCounter {
                    sdmReadCounterOffset = Helper.bytesToIntLE(Array(data[currentOffset...(currentOffset + 2)]))
                    currentOffset += 3
                }
            } else {
                if sdmMetaReadPermission != .NONE {
                    sdmPiccDataOffset = Helper.bytesToIntLE(Array(data[currentOffset...(currentOffset + 2)]))
                    currentOffset += 3
                }
            }
            if sdmFileReadPermission != .NONE {
                sdmMacInputOffset = Helper.bytesToIntLE(Array(data[currentOffset...(currentOffset + 2)]))
                currentOffset += 3
                
                if sdmOptionEncryptFileData {
                    sdmEncOffset = Helper.bytesToIntLE(Array(data[currentOffset...(currentOffset+2)]))
                    currentOffset += 3
                    sdmEncLength = Helper.bytesToIntLE(Array(data[currentOffset...(currentOffset+2)]))
                    currentOffset += 3
                }
                
                sdmMacOffset = Helper.bytesToIntLE(Array(data[currentOffset...(currentOffset+2)]))
                currentOffset += 3
            }
            if sdmOptionReadCounterLimit {
                sdmReadCounterLimit = Helper.bytesToIntLE(Array(data[currentOffset...(currentOffset+2)]))
                currentOffset += 3
            }
        }
    }
}
