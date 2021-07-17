//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

#if !os(macOS)
import Foundation
import CoreNFC
import CryptoSwift

public struct NxpCommandResult {
    var data: [UInt8]
    var statusMajor: UInt8
    var statusMinor: UInt8
    
    static func emptyResult() -> NxpCommandResult {
        return NxpCommandResult(data: [], statusMajor: 0, statusMinor: 0)
    }
}

public class DnaCommunicator {
    public var tag: NFCISO7816Tag?
    public var tagConfiguration: TagConfiguration?
    public var activeKeyNumber: UInt8 = 0
    var activeTransactionIdentifier: [UInt8] = [0,0,0,0]
    var commandCounter: Int = 0
    var sessionEncryptionMode: EncryptionMode?
    
    public var trace: Bool = false
    public var debug: Bool = false
    
    // Should move these somewhere else
    let SELECT_MODE_ANY: UInt8 = 0x00
    let SELECT_MODE_CHILD_DF: UInt8 = 0x01
    let SELECT_MODE_CHILD_EF: UInt8 = 0x02
    let SELECT_MODE_PARENT_DF: UInt8 = 0x03
    let SELECT_MODE_NAME: UInt8 = 0x04
    let CC_FILE_NUMBER: Int = 0x01
    let CC_FILE_ID: Int = 0xe103
    let NDEF_FILE_NUMBER: Int = 0x02
    let NDEF_FILE_ID: Int = 0xe104
    let DATA_FILE_NUMBER: Int = 0x03
    let DATA_FILE_ID: Int = 0xe105
    let PICC_FILE_ID: Int = 0x3f00
    let DF_FILE_ID: Int = 0xe110
    let DF_NAME: [UInt8] = [0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01]

    public init() {
        
    }
    
    func debugPrint(_ value: String) {
        if debug {
            print(value)
        }
    }
    
    func makeErrorIfNotExpectedStatus(_ result: NxpCommandResult, error: Error? = nil) -> Error? {
        if result.statusMajor != 0x91 || (result.statusMinor != 0x00 && result.statusMinor != 0xaf) {
            return Helper.makeError(102, "Unexpected status: \(result.statusMajor) / \(result.statusMinor)")
        }
        return nil
    }
    
    func getRandomBytes(ofLength: Int) -> [UInt8] {
        return Helper.randomBytes(ofLength: ofLength)
    }
    
    func isoTransceive(packet: [UInt8], completion: @escaping (NxpCommandResult, Error?) -> Void) {
        let data = Helper.dataFromBytes(bytes: packet)
        let apdu = NFCISO7816APDU(data: data)
        Helper.logBytes("Outbound", packet)

        if let apdu = apdu {
            tag!.sendCommand(apdu: apdu) {data, sw1, sw2, err in
                let bytes = Helper.bytesFromData(data: data)
                let result = NxpCommandResult(data: bytes, statusMajor: sw1, statusMinor: sw2)
                if self.trace {
                    Helper.logBytes("Inbound", bytes + [sw1] + [sw2])
                }
                if err != nil {
                    self.debugPrint("An error occurred: \(String(describing: err))")
                }
                completion(result, err)
            }
        } else {
            debugPrint("APDU Failure: Attempt")
            
            completion(NxpCommandResult.emptyResult(), Helper.makeError(100, "APDU Failure"))
        }
    }
            
    func nxpNativeCommand(command: UInt8, header: [UInt8], data: [UInt8]?, macData: [UInt8]? = nil, completion: @escaping (NxpCommandResult, Error?) -> Void) {
        let data = data ?? [UInt8]()
        var packet: [UInt8] = [
            0x90,
            command,
            0x00,
            0x00,
            UInt8(header.count + data.count + (macData?.count ?? 0))
        ]
        packet.append(contentsOf: header)
        packet.append(contentsOf: data)
        if let macData = macData {
            packet.append(contentsOf: macData)
        }
        packet.append(0x00)
        
        isoTransceive(packet: packet) { result, err in
            completion(result, err)
        }
    }
    
    public func nxpPlainCommand(command: UInt8, header: [UInt8], data: [UInt8]?, completion: @escaping (NxpCommandResult, Error?) -> Void) {
        nxpNativeCommand(command: command, header: header, data: data) {result, err in
            self.commandCounter += 1
            completion(result, err)
        }
    }
    
    public func nxpMacCommand(command: UInt8, header: [UInt8], data: [UInt8]?, completion: @escaping (NxpCommandResult, Error?) -> Void) {
        let data = data ?? [UInt8]()
        var macInputData: [UInt8] = [
            command,
            UInt8(commandCounter % 256), UInt8(commandCounter / 256),
            activeTransactionIdentifier[0], activeTransactionIdentifier[1], activeTransactionIdentifier[2], activeTransactionIdentifier[3],
        ]
        macInputData.append(contentsOf: header)
        macInputData.append(contentsOf: data)
        let macData = sessionEncryptionMode!.generateMac(message: macInputData)
        
        nxpNativeCommand(command: command, header: header, data: data, macData: macData) { result, err in
            self.commandCounter += 1
            if result.data.count < 8 {
                // No MAC available for this command
                let noDataResult = NxpCommandResult(data: [UInt8](), statusMajor: result.statusMajor, statusMinor: result.statusMinor)

                completion(noDataResult, err)
                return
            }
            
            let dataBytes = result.data[0...(result.data.count - 9)]
            let macBytes = result.data[(result.data.count - 8)...(result.data.count - 1)]
            
            // Check return MAC
            var returnMacInputData: [UInt8] = [
                result.statusMinor,
                UInt8(self.commandCounter % 256), UInt8(self.commandCounter / 256),
                self.activeTransactionIdentifier[0], self.activeTransactionIdentifier[1], self.activeTransactionIdentifier[2], self.activeTransactionIdentifier[3],
            ]
            returnMacInputData.append(contentsOf: dataBytes)
            let returnMacData = self.sessionEncryptionMode!.generateMac(message: returnMacInputData)
            
            let finalResult = NxpCommandResult(data: [UInt8](dataBytes), statusMajor: result.statusMajor, statusMinor: result.statusMinor)
            
            if !returnMacData.elementsEqual(macBytes) {
                self.debugPrint("Invalid MAC! (\(returnMacData)) / (\(macBytes)")
                completion(finalResult, Helper.makeError(101, "Invalid MAC"))
                return
            }
            
            completion(finalResult, nil)
        }
    }
    
    public func nxpEncryptedCommand(command: UInt8, header: [UInt8], data: [UInt8]?, completion: @escaping (NxpCommandResult, Error?) -> Void) {
        let data = data ?? [UInt8]()
        if trace {
            Helper.logBytes("Unencryped outgoing data", data)
        }
        let encryptedData = data.count == 0 ? [UInt8]() : sessionEncryptionMode!.encryptData(message: data)
        nxpMacCommand(command: command, header: header, data: encryptedData) {result, err in
            let decryptedResultData = result.data.count == 0 ? [UInt8]() : self.sessionEncryptionMode!.decryptData(message: result.data)
            let finalResult = NxpCommandResult(data: decryptedResultData, statusMajor: result.statusMajor, statusMinor: result.statusMinor)
            if self.trace {
                Helper.logBytes("Unencrypted incoming data", finalResult.data)
            }
            completion(finalResult, err)
        }
    }
    
    public func nxpSwitchedCommand(mode: CommuncationMode, command: UInt8, header: [UInt8], data: [UInt8], completion: @escaping (NxpCommandResult, Error?) -> Void) {
        if mode == CommuncationMode.FULL {
            nxpEncryptedCommand(command: command, header: header, data: data) { result, err in
                completion(result, err)
            }
        } else if mode == CommuncationMode.MAC {
            nxpMacCommand(command: command, header: header, data: data) { result, err in
                    completion(result, err)
            }
        } else {
            nxpPlainCommand(command: command, header: header, data: data) { result, err in
                    completion(result, err)
            }
        }
    }
    
    public func isoSelectFile(mode: UInt8, fileId: Int, completion: @escaping (Error?) -> Void) {
        let packet: [UInt8] = [
            0x00, // class
            0xa4, // ISOSelectFile
            0x00, // select by file identifier (1, 2, 3, and 4 have various meanings as well)
            0x0c, // Don't return FCI
            0x02, // Length of file identifier
            UInt8(fileId / 256),  // File identifier
            UInt8(fileId % 256),
            0x00 // Length of expected response
        ]
        
        isoTransceive(packet: packet) { result, err in
            completion(err)
        }
    }
    
    public func begin(completion: @escaping (Error?) -> Void) {
        // Looks like iOS has already selected the application
        // This is required on Android but fails on iOS,
        // so we're keeping the API but skipping the actual behavior
        /*
        isoSelectFile(mode: SELECT_MODE_CHILD_DF, fileId: DF_FILE_ID) { err in
            completion(err)
        }
         */
        completion(nil)
    }
    
    public func writeTagConfiguration(tagConfiguration: TagConfiguration) {
        
    }
}
#endif
