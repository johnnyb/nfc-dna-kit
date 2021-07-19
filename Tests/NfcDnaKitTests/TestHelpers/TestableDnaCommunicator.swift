//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

import Foundation

@testable import NfcDnaKit

class DnaCommunicatorForTesting: DnaCommunicator {
    var randomBytes: [UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    override func getRandomBytes(ofLength: Int) -> [UInt8] {
        return Array(randomBytes[0...(ofLength - 1)])
    }
}
