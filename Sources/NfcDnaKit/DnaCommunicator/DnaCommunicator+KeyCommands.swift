//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/19/21.
//

import Foundation

public extension DnaCommunicator {
    
    func getKeyVersion(keyNum: UInt8, completion: @escaping (UInt8, Error?) -> Void) {
        nxpMacCommand(command: 0x64, header: [keyNum], data: nil) { result, err in
            let resultValue = result.data.count < 1 ? 0 : result.data[0]
            completion(resultValue, err ?? self.makeErrorIfNotExpectedStatus(result))
        }
    }
    
    func changeKey(keyNum: UInt8, oldKey: [UInt8], newKey: [UInt8], keyVersion: UInt8, completion: @escaping (Bool, Error?) -> Void) {
        if activeKeyNumber != 0 {
            debugPrint("Not sure if changing keys when not authenticated as key0 is allowed - documentation is unclear")
        }
        
        if(keyNum == 0) {
            // If we are changing key0, can just send the request
            // This may need to check if keyNum == activeKeyNumber.  Documentation is unclear
            nxpEncryptedCommand(command: 0xc4, header: [keyNum], data: newKey + [keyVersion]) { result, err in
                let err = err ?? self.makeErrorIfNotExpectedStatus(result)
                completion(err == nil, err)
            }
        } else {
            // Weird validation methodology
            let crc = Helper.crc32(newKey)
            let xorkey = Helper.xor(oldKey, newKey)
            nxpEncryptedCommand(command: 0xc4, header: [keyNum], data:xorkey + [keyVersion] + crc) { result, err in
                let err = err ?? self.makeErrorIfNotExpectedStatus(result)
                completion(err == nil, err)
            }
        }
    }
}
