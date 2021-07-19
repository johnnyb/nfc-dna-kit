    import XCTest
    @testable import NfcDnaKit
    
    final class NfcDnaKitTests: XCTestCase {
        func testEncoding() {
            let tagConfig = TagConfiguration()
            print(tagConfig.toJSON())
        }
        func testKeyGeneration() {
            let chA = Helper.decodeHexString("6E DA 19 A6 EA 72 2A 07 03 E4 F9 03 59 F3 0E 14")
            let chB = Helper.decodeHexString("B3 20 5A 85 58 1E 76 E2 27 A5 0D AF B0 DC 42 3D")
            let key = Helper.decodeHexString("00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00")
            
            let comm = DnaCommunicatorForTesting()
            
            let aes = AESEncryptionMode(communicator: comm, key: key, challengeA: chA, challengeB: chB)
            
            XCTAssert(aes.sessionEncryptionKey.elementsEqual(Helper.decodeHexString("AE E1 B8 24 21 36 B8 86 EB E7 0A 39 F7 6E 5C F1")))
            XCTAssert(aes.sessionMacKey.elementsEqual(Helper.decodeHexString("2E 3C 87 34 89 12 92 DD 92 4B 3C 59 40 57 AA FF")))
            
            comm.activeTransactionIdentifier = Helper.decodeHexString("13 81 2B 95")
            comm.commandCounter = 8
            let dataForEncryption = Helper.decodeHexString("40 30 E0 C1 F1 12 64 00 00 85 00 00 85 00 00")
            let encryptedData = aes.encryptData(message: dataForEncryption)
            let expectedEncryptedData = Helper.decodeHexString("D0 97 9F 07 62 E0 D1 1F 3F AD E8 C2 77 C7 1A 3D")
            XCTAssert(expectedEncryptedData.elementsEqual(encryptedData))
        } 
    }
