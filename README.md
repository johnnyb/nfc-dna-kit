# NfcDnaKit

This kit allows you to communicate with the NXP NTag 424 DNA NFC tag.  You can always access it as an NDEF tag, but you can't write/modify it that way. 

The DNA tag allows for encrypted access as well as authentication.  
It has some pretty interesting features that allows this to be used for authenticity verification, as well as secure message storing.  
Unfortunately, TapLinx (their communication library) is only available on Android. 
Therefore, I decided to write a communication library for this chip.

## Installing the Library

To get started, load this as a `git` package using the Swift package manager.
As of right now I'm not yet versioning, so just set the branch to `main`.
You also have to do the NFC things to your project, including:

* Add the "Near Field Communication Tag Reading" library to your capabilities
* Add the entitlements needed (this may happen automagically from the previous one, I can't remember)
* Add the following to your `Info.plist` file:
```
<key>NFCReaderUsageDescription</key>
<string>NFC required to read/write NFC tags</string>
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>D2760000850101</string>
</array>
```

## Using the Library

In your code, you need to initialize a TagReaderSession:

```
var session: NFCTagReaderSession?
override func viewDidAppear(_ animated: Bool) {
    if !NFCTagReaderSession.readingAvailable {
        print("Reading not available")
    }
    print("View did appear")
    tagReaderSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
    tagReaderSession?.alertMessage = "Tap the tag to scan"
    tagReaderSession?.begin()
}
```

Then you need to detect the tag:

```

func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
    print("Tag found - yippeee")
    let tag = tags.first!
    print(tag)
    
    session.connect(to: tag) { err in
        if case let .iso7816(isoTag) = tag {
            print("Cast successful")
            let dna = DnaCommunicator()
            dna.trace = true
            dna.debug = true
            dna.tagConfiguration = TagConfiguration()
            dna.tag = isoTag
            dna.begin { err in
                dna.authenticateEV2First(keyNum: 0) { succ, err in
                    dna.getChipUid { result, err in
                        print(result)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                            
                            // Disconnect and go back to work
                            session.restartPolling()
                        }
                    }
                }
            }
        }
    }
}
```

This creates a default tag configuration (keys all zero) which matches the way the factory DNA samples come.  
Because the communication is asynchronous, you need to do this command-embedded-within-command stuff.

To terminate the connection, we wait 1 second and then `restartPolling`.
If you don't do this, the code will continually re-pick up on the tag and run it again and again.
Not necessarily problematic, and you can deal with it in other ways, but this seemed pretty straightforward.

## Going from here

Right now I've got the basic AES encrpytion methods set up.  
You have three "basic" commands: `nxpPlainCommand` (no encryption), `nxpMacCommand` (MAC-authenticated command), and `nxpEncryptedCommand` (full encryption of data), and also `nxpSwitchedCommand` which allows the communication mode as a parameter.
Basically each function defined in the manual (like `getChipUid`) will get a small wrapper function around the proper communication mode.

Right now, just a few functions are defined, but I'm planning on implementing most of them.  They are pretty easy.

I also plan on having LRP communication setup soon.

## Related Libraries

I have a Go-related library for reading the LRP protocol:

https://github.com/johnnyb/gocrypto


