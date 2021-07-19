//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/19/21.
//

import Foundation

public extension DnaCommunicator {
    func writeFileData(fileNum: UInt8, data: [UInt8], mode: CommuncationMode? = nil, offset: Int = 0, completion: @escaping (Error?) -> Void) {
        // Pg. 75
        
        // Auto-detect mode if not specified
        if mode == nil {
            getFileSettings(fileNum: fileNum) { settings, err in
                if err != nil {
                    completion(err)
                } else {
                    self.writeFileData(fileNum: fileNum, data: data, mode: settings?.communicationMode, offset: offset) { err in
                        completion(err)
                    }
                }
            }
            return
        }
        
        let dataSizeBytes = Helper.byteArrayLE(from: Int32(data.count))[0...2]
        let offsetBytes = Helper.byteArrayLE(from: Int32(offset))[0...2]
        
        nxpSwitchedCommand(mode: mode!, command: 0x8d, header: [fileNum] + offsetBytes + dataSizeBytes, data: data) { result, err in
            completion(self.makeErrorIfNotExpectedStatus(result, error: err))
        }
    }
    
    func readFileData(fileNum: UInt8, length: Int, mode: CommuncationMode? = nil, offset: Int = 0, completion: @escaping ([UInt8], Error?) -> Void) {
        // Pg. 73
        
        // Auto-detect mode if not specified
        if mode == nil {
            getFileSettings(fileNum: fileNum) { settings, err in
                if err != nil {
                    completion([], err)
                } else {
                    self.readFileData(fileNum: fileNum, length: length, mode: settings?.communicationMode, offset: offset) { data, err in
                        completion(data, err)
                    }
                }
            }
            return
        }
        
        let offsetBytes = Helper.byteArrayLE(from: Int32(offset))[0...2]
        let lengthBytes = Helper.byteArrayLE(from: Int32(length))
        
        nxpSwitchedCommand(mode: mode!, command: 0xad, header: [fileNum] + offsetBytes + lengthBytes, data: []) { result, err in
            completion(result.data, self.makeErrorIfNotExpectedStatus(result, error: err))
        }
    }
    
    func getFileSettings(fileNum: UInt8, completion: @escaping (FileSettings?, Error?) -> Void) {
        // Pg. 69
        
        nxpMacCommand(command: 0xf5, header: [fileNum], data: []) { result, err in
            
            let settings = FileSettings(fromResultData:result)
            completion(settings, self.makeErrorIfNotExpectedStatus(result, error: err))
        }
    }
}
