//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

import Foundation
class TagConfiguration {
    var name: String?
    
    var ndefFileConfiguration: FileConfiguration?
    var privateFileConfiguration: FileConfiguration?

    var optLrpEnable: Bool = false
    var optUseRandomId: Bool = false
    var optEnableStrongBackModulation: Bool = true
    var optUseFailCounter: Bool = false
    var failCounterLimit: Int = 1000
    var failCounterDecrement: Int = 10
    var resetSdmCounter: Bool = false
    
    var keys: [[UInt8]] = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    ]
}

