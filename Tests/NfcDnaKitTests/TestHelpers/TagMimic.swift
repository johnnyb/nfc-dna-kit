//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

import Foundation
import CoreNFC

@testable import NfcDnaKit

class TagMimic: NSObject, NFCISO7816Tag {
    var initialSelectedAID: String = "asdf"
    
    var identifier: Data = Helper.dataFromBytes(bytes: [1,2,3])
    
    var historicalBytes: Data?
    
    var applicationData: Data?
    
    var proprietaryApplicationDataCoding: Bool = false
    
    var type: __NFCTagType = .iso7816Compatible
    
    var session: NFCReaderSessionProtocol?
    
    var isAvailable: Bool = true
    
    func asNFCISO15693Tag() -> NFCISO15693Tag? {
        return nil
    }
    
    func asNFCISO7816Tag() -> NFCISO7816Tag? {
        return nil
    }
    
    func asNFCFeliCaTag() -> NFCFeliCaTag? {
        return nil
    }
    
    func asNFCMiFareTag() -> NFCMiFareTag? {
        return nil
    }
    
    func queryNDEFStatus(completionHandler: @escaping (NFCNDEFStatus, Int, Error?) -> Void) {
    }
    
    func readNDEF(completionHandler: @escaping (NFCNDEFMessage?, Error?) -> Void) {
    }
    
    func writeNDEF(_ ndefMessage: NFCNDEFMessage, completionHandler: @escaping (Error?) -> Void) {
    }
    
    func writeLock(completionHandler: @escaping (Error?) -> Void) {
    }
    
    static var supportsSecureCoding: Bool = false
    
    func copy(with zone: NSZone? = nil) -> Any {
        return 0
    }
    
    func encode(with coder: NSCoder) {
    }
    
    required init?(coder: NSCoder) {
    }
    
    var responseIndex = 0
    var responseList: [[UInt8]] = [[UInt8]]()
    
    func sendCommand(apdu: NFCISO7816APDU, completionHandler: @escaping (Data, UInt8, UInt8, Error?) -> Void) {
        let response = responseList[responseIndex]
        responseIndex += 1
        let data = Helper.dataFromBytes(bytes: Array(response[0...(response.count - 3)]))
                                        completionHandler(data, response[response.count - 2], response[response.count - 1], nil)
    }
    
    func setResponses(responseList: [[UInt8]]) {
        self.responseList = responseList
        self.responseIndex = 0
    }
}
