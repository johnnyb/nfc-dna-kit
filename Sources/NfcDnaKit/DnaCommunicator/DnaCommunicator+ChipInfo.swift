//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

#if !os(macOS)
public extension DnaCommunicator {
    func getChipUid(completion: @escaping ([UInt8], Error?) -> Void) {
        nxpEncryptedCommand(command: 0x51, header: [], data: []) { result, err in
            let err = err ?? self.makeErrorIfNotExpectedStatus(result)
            if err != nil {
                completion([], err)
                return
            }
            completion(Array(result.data[0...6]), err)
        }
    }
    
    func getKeyVersion(keyNum: UInt8, completion: @escaping (UInt8, Error?) -> Void) {
        nxpMacCommand(command: 0x64, header: [keyNum], data: nil) { result, err in
            let resultValue = result.data.count < 1 ? 0 : result.data[0]
            completion(resultValue, err ?? self.makeErrorIfNotExpectedStatus(result))
        }
    }
}
#endif
