//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

import Foundation
import CryptoSwift

class Helper {
    /* **** HELPER FUNCTIONS **** */
    static let zeroIVPS: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    static func bytesAsString(_ data: [UInt8]) -> String {
        var str = ""
        for x in data {
            let st = String(format:"%02X", x)
            str = str + st + " "
        }
        return str
    }
    
    static func logBytes(_ name: String, _ data: [UInt8]) {
        print(name + ": " + bytesAsString(data))
    }
    
    static func makeError(_ code: Int, _ message: String) -> Error {
        return NSError(domain: "DNA", code: code, userInfo: ["message":message])
    }
    
    static func evensOnly(_ data: [UInt8]) -> [UInt8] {
        var newData = [UInt8](repeating: 0, count: data.count / 2)
        var idx = 0
        while idx < newData.count {
            newData[idx] = data[idx * 2 + 1]
            idx += 1
        }
        return newData
    }
    
    static func simpleCMAC(key: [UInt8], data: [UInt8], iv: [UInt8]? = nil) -> [UInt8] {
        let iv = iv ?? zeroIVPS
        do {
            let cipher = try AES(key: key, blockMode: CBC(iv: iv), padding: .noPadding)
            let cmac = try CMAC(key: key)
            let result = try cmac.authenticate(data, cipher: cipher)
            
            return result
        } catch {
            print("Error on simpleCMAC")
            return [UInt8]()
        }
    }

    static func simpleAesEncrypt(key: [UInt8]?, data: [UInt8]?, iv:[UInt8]? = nil) -> [UInt8] {
        let key = key ?? [UInt8]()
        let data = data ?? [UInt8]()
        let iv = iv ?? zeroIVPS
        
        do {
            let encryption = try AES(key: key, blockMode: CBC(iv: iv), padding: .noPadding)
            return try encryption.encrypt(data)
        } catch let error {
            print("Error on simpleAesEncrypt: \(error)")
            return [UInt8]()
        }
    }
    
    static func messageWithPadding(_ message: [UInt8]) -> [UInt8] {
        let blockSize = 16
        let remainder = message.count % blockSize
        
        if remainder == 0 {
            return message
        }
        
        let blocks = message.count / blockSize
        var result = [UInt8](repeating: 0, count: (blocks + 1)*blockSize)
        
        // Copy existing message
        var idx = 0
        while idx < message.count {
            result[idx] = message[idx]
            idx += 1
        }
        
        // Add the boundary marker
        result[message.count] = 0x80
        
        return result
    }
    
    static func simpleAesDecrypt(key: [UInt8]?, data: [UInt8]?, iv:[UInt8]? = nil) -> [UInt8] {
        let key = key ?? [UInt8]()
        let data = data ?? [UInt8]()
        let iv = iv ?? zeroIVPS
        
        do {
            let encryption = try AES(key: key, blockMode: CBC(iv: iv), padding: .noPadding)
            return try encryption.decrypt(data)
        } catch {
            print("Error on simpleAesDecrypt")
            return [UInt8]()
        }
    }
    
    static func dataFromBytes(bytes: [UInt8]?) -> Data {
        guard let bytes = bytes else { return Data() }
        return Data(bytes: bytes, count: bytes.count)
    }
    
    static func bytesFromData(data:Data?) -> [UInt8] {
        guard let data = data else { return [UInt8]() }
        var buffer = [UInt8]()
        data.withUnsafeBytes {
            buffer.append(contentsOf: $0)
        }
        return buffer
    }
    
    static func randomBytes(ofLength length: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
 
        if status != errSecSuccess {
            print("Bad mojo in randomBytes")
        }

        return bytes
     }
    
    static func decodeHexString(_ str: String) -> [UInt8] {
        let strs = str.split(separator: " ")
        var vals = [UInt8]()
        
        for x in strs {
            vals.append(UInt8(x, radix: 16)!)
        }
        
        return vals
    }
    
    static func rotateLeft(_ value: [UInt8], _ numRots:Int = 1) -> [UInt8] {
        var newAry = [UInt8](repeating: 0, count: value.count)
        var idx = 0
        while idx < value.count {
            let newIdx = (idx < numRots) ? (value.count - (numRots + idx)) : (idx - numRots)
            newAry[newIdx] = value[idx]
            idx += 1
        }
        return newAry
    }
    
    static func rotateRight(_ value: [UInt8], _ numRots:Int = 1) -> [UInt8] {
        var newAry = [UInt8](repeating: 0, count: value.count)
        var idx = 0
        while idx < value.count {
            let newIdx = (idx >= (value.count - numRots)) ? (idx - value.count + numRots) : (idx + numRots)
            newAry[newIdx] = value[idx]
            idx += 1
        }
        return newAry
    }
    
    static func xor(_ value1: UInt8, _ value2: UInt8) -> UInt8 {
        return (value1 | value2) - (value1 & value2)
    }
    
    static func xor(_ value1:[UInt8], _ value2: [UInt8]) -> [UInt8] {
        guard value1.count == value2.count else { return [] }
        var newValue = [UInt8](repeating: 0, count: value1.count)
        for idx in 0...(value1.count - 1) {
            newValue[idx] = Helper.xor(value1[idx], value2[idx])
        }
        
        return newValue
    }
    
    static func diversifyKey(key: [UInt8], applicationInfo: [UInt8], identifier: [UInt8]) -> [UInt8] {
        var newData: [UInt8] = [0x01]
        newData.append(contentsOf: identifier)
        newData.append(contentsOf: applicationInfo)
        
        return simpleCMAC(key: key, data: newData)
    }
    
    static func byteArrayLE<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        
        withUnsafeBytes(of: value.littleEndian, Array.init)
    }
    
    static func byteArrayBE<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
    
    static func getBitLSB(_ byte: UInt8, _ index: Int) -> Bool {
        let mask = UInt8(1 << index)
        let result = byte & mask
        return result != 0
    }
    
    static func bytesToInt32LE(_ data:[UInt8]) -> UInt32 {
        var multiplier: UInt32 = 1
        var value: UInt32 = 0
        for x in data {
            value += UInt32(x) * multiplier
            multiplier *= 256
        }
        return value
    }
    
    
    static func bytesToIntLE(_ data:[UInt8]) -> Int {
        return Int(bytesToInt32LE(data))
    }
    
    static func crc32(_ data:[UInt8]) -> [UInt8] {
        let val = Checksum.crc32(data)
        
        let basicCRC = byteArrayLE(from: val)
        let jamXorMask: [UInt8] = [0xff, 0xff, 0xff, 0xff]
        
        let jamCRC = Helper.xor(basicCRC, jamXorMask)
        return jamCRC
    }
    
    static func leftNibble(_ data: UInt8) -> UInt8 {
        return (data >> 4)
    }
    
    static func rightNibble(_ data: UInt8) -> UInt8 {
        return (data & UInt8(15))
    }
}
