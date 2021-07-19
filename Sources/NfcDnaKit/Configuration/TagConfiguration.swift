//
//  File.swift
//  
//
//  Created by Jonathan Bartlett on 7/17/21.
//

import Foundation

public class TagConfiguration: Codable {
    public var name: String?
    
    public var ndefFileConfiguration: FileConfiguration?
    public var privateFileConfiguration: FileConfiguration?

    public var optEnableLrp: Bool = false
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
    
    public init() {
        
    }
    
    public func toJSON() -> String {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            return String(data:data, encoding: .utf8)!
        } catch {
            print("Unexpected error encoding to JSON!")
            return ""
        }
    }
    
    public static func fromJSON(_ json:String) -> TagConfiguration? {
        do {
            let decoder = JSONDecoder()
            let config = try decoder.decode(TagConfiguration.self, from: json.data(using: .utf8)!)
            return config
        } catch {
            print("Failed decoding JSON")
            return nil
        }
    }
}

