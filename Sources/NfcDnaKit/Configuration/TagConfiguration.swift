//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

import Foundation

public class TagConfiguration {
    public var name: String?
    
    public var ndefFileConfiguration: FileConfiguration?
    public var privateFileConfiguration: FileConfiguration?

    public var optLrpEnable: Bool = false
    public var optUseRandomId: Bool = false
    public var optEnableStrongBackModulation: Bool = true
    public var optUseFailCounter: Bool = false
    public var failCounterLimit: Int = 1000
    public var failCounterDecrement: Int = 10
    public var resetSdmCounter: Bool = false
    
    public var keys: [[UInt8]] = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    ]
}

