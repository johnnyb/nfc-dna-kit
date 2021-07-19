//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

#if !os(macOS)
import Foundation

public extension DnaCommunicator {
    func authenticateEV2First(keyNum: UInt8, keyData: [UInt8]? = nil, completion: @escaping (Bool, Error?) -> Void) -> Void {
        guard let keyData = keyData ?? tagConfiguration?.keys[Int(keyNum)] else { completion(false, nil); return }
        
        // STAGE 1 Authentication (pg. 46)
        nxpNativeCommand(command: 0x71, header: [keyNum, 0x00], data: []) { result, err in
            
            if err != nil {
                self.debugPrint("Err: \(String(describing: err))")
                completion(false, err)
                return
            }
            
            if(result.statusMajor != 0x91) {
                self.debugPrint("Wrong status Major")
                completion(false, Helper.makeError(103, "Wrong status major: \(result.statusMajor)"))
                return
            }
            
            if(result.statusMinor == 0xad) {
                self.debugPrint("Requested retry")
                // Unsure - retry? pg. 52
                completion(false, Helper.makeError(104, "Don't know how to handle retries"))
                return
            }
            
            if(result.statusMinor != 0xaf) {
                self.debugPrint("Bad status minor: \(result.statusMinor)")
                completion(false, Helper.makeError(105, "Wrong status minor: \(result.statusMinor)"))
                return
            }
            
            if(result.data.count != 16) {
                self.debugPrint("Incorrect data count")
                completion(false, Helper.makeError(106, "Incorrect data size"))
                return
            }
            
            let encryptedChallengeB = result.data
            let challengeB = Helper.simpleAesDecrypt(key: keyData, data: encryptedChallengeB)
            let challengeBPrime = Helper.rotateLeft(Array(challengeB[0...]))
            let challengeA = self.getRandomBytes(ofLength: 16)
            self.debugPrint("Challenge A: \(challengeA)")
            let combinedChallenge = Helper.simpleAesEncrypt(key: keyData, data: (challengeA + challengeBPrime))
            
            // STAGE 2 (pg. 47)
            self.nxpNativeCommand(command: 0xaf, header: combinedChallenge, data: nil) {innerResult, err in
                
                if err != nil {
                    completion(false, err)
                    return
                }
                
                if innerResult.statusMajor != 0x91 {
                    completion(false, Helper.makeError(107, "Bad status major"))
                    return
                }
                
                if(innerResult.statusMinor != 0x00) {
                    completion(false, Helper.makeError(108, "Bad status minor"))
                    return
                }
                
                let resultData = Helper.simpleAesDecrypt(key: keyData, data: innerResult.data)
                let ti = Array(resultData[0...3])
                let challengeAPrime = Array(resultData[4...19])
                let pdCap = resultData[20...25]
                let pcCap = resultData[26...31]
                let newChallengeA = Helper.rotateRight(challengeAPrime)
                
                if !newChallengeA.elementsEqual(challengeA) {
                    self.debugPrint("Challenge A response not valid")
                    completion(false, Helper.makeError(109, "Invalid Challenge A response"))
                }
                
                self.debugPrint("Data: TI: \(ti), challengeA: \(newChallengeA), pdCap: \(pdCap), pcCap: \(pcCap)")
                
                // Activate Session
                self.activeKeyNumber = keyNum
                self.commandCounter = 0
                self.activeTransactionIdentifier = ti
                
                self.debugPrint("Starting AES encryption")
                self.sessionEncryptionMode = AESEncryptionMode(communicator: self, key: keyData, challengeA: challengeA, challengeB: challengeB)
                
                completion(true, nil)
            }
        }
    }
}
#endif
