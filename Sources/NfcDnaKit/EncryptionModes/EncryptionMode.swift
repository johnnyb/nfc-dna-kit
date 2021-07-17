//
//  File 2.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

import Foundation

public protocol EncryptionMode {
    func encryptData(message: [UInt8]) -> [UInt8]
    func decryptData(message: [UInt8]) -> [UInt8]
    func generateMac(message: [UInt8]) -> [UInt8]
}
