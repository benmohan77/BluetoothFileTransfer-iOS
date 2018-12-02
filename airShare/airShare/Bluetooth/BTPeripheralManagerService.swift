import UIKit
import CoreBluetooth

class BTPeripheralManagerService: NSObject, CBPeripheralManagerDelegate {
    
    var testText = "This is a test"
    
    var peripheralManager:CBPeripheralManager?
    var transferCharacteristic:CBMutableCharacteristic?
    var dataToSend:Data?
    var sendDataIndex = 0
    let notifyMTU = 20
    var sendingEOM = false
    var contentUpdated = false
    var currentTextSnapshot = ""
    var sendingTextData = false
    var count = 0
    
    override init() {
        super.init()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func resetData() {
        print("Resetting Data...")
        currentTextSnapshot = ""
        dataToSend = nil
        sendDataIndex = 0
    }
    
    func captureCurrentText() {
        print("captureCurrentText")
        
        // if we are not sending right now, capture the current state
        if !sendingTextData {
            //            print("Not currently sending data. Capturing snapshot and will send it over!")
            count += 1
            currentTextSnapshot = testText + " \(count)"
            //            dataToSend = currentTextSnapshot.data(using: String.Encoding.utf8)
            //            dataToSend = UIImage(named: "ExampleFile")!.pngData()
            //            dataToSend = UIImage(named: "Image")!.pngData()
            dataToSend = UIImage(named: "ExampleFile")!.pngData()
            
            sendDataIndex = 0
            sendTextData()
        } else {
            print("Currently sending data. Will wait to capture in a second...")
        }
    }
    
    func sendTextData() {
        //        print("Attempting to send data...")
        
        guard let peripheralManager = self.peripheralManager else {
            print("No peripheral manager!!!")
            return
        }
        
        guard let transferCharacteristic = self.transferCharacteristic else {
            print("No transfer characteristic available!!!")
            return
        }
        
        // Is it time for the EOM message?
        if sendingEOM {
            print("Attempting to send EOM...")
            
            let didSend = peripheralManager.updateValue(Device.EOM.data(using: String.Encoding.utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
            if didSend {
                sendingEOM = false
                print("EOM Sent!!!")
                sendingTextData = false
            }
            
            // Return and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendTextData again
            return
        }
        
        
        // Since we're not sending an EOM message, we'll send data
        // check to see if we actually have any data to send (return if nil)...
        guard let dataToSend = dataToSend else {
            return
        }
        
        if sendDataIndex >= dataToSend.count {
            return;
        }
        
        // We have determined that there is data left to send, so we will send until the point at which either a) the callback fails or b) we're done.
        var didSend = true
        while didSend {
            
            // turn on our sending text flag to prevent updating the buffer until we're done
            sendingTextData = true
            
            // ---- Prepare the next message chunk
            //            print("Preparing next message chunk...")
            
            // Determine chunk size
            var amountToSend = dataToSend.count - sendDataIndex
            print("Next amout to send: \(amountToSend)")
            
            // we have a 20-byte limit, so if the amount to send is greater than 20, then clamp it down to 20.
            if (amountToSend > Device.notifyMTU) {
                amountToSend = Device.notifyMTU
            }
            
            // extract the data we want to send
            let upToIndex = sendDataIndex + amountToSend
            //            print("Next Chunk should be \(amountToSend) bytes long and goes from \(sendDataIndex) to \(upToIndex)")
            
            // verify chunk length
            let chunk = dataToSend.subdata(in: sendDataIndex ..< upToIndex)
            //            print("Next Chunk is \(chunk.count) bytes long.")
            
            // output the chunk to see if we got the right block of text...
            //            let chunkText = String(data: chunk, encoding: String.Encoding.utf8)
            //            print("Next Chunk from data: \(chunkText)")
            
            // Send the chunk of text...
            // updateValue sends an updated characteristic value to one or more subscribed centrals via a notification.
            // passing nil for the centrals notifies all subscribed centrals, but you can target specific ones if you need to.
            didSend = peripheralManager.updateValue(chunk, for: transferCharacteristic, onSubscribedCentrals: nil)
            
            // If it didn't work, drop out and wait for the callback
            if !didSend {
                return
            }
            
            //            if let stringFromData = String.init(data: chunk, encoding: String.Encoding.utf8) {
            //                print("Sent: \(stringFromData)")
            //            }
            
            // It did send, so update our index
            self.sendDataIndex += amountToSend;
            
            // Determine if that was was the last chunk of data to send, and if so, send the EOM tag
            if sendDataIndex >= dataToSend.count {
                
                // Set this so if the send fails, we'll send it next time
                sendingEOM = true
                
                // Send the EOM tag
                let eomData = Device.EOM.data(using: String.Encoding.utf8)!
                let eomSent = peripheralManager.updateValue(eomData, for: transferCharacteristic, onSubscribedCentrals: nil)
                if (eomSent) {
                    // If the send was successful, then we're done, otherwise we'll send it next time
                    sendingEOM = false
                    print("Successfully sent EOM!!!");
                    
                    // turn off sending flag
                    sendingTextData = false
                }
                
                return;
            }
            
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        print("Peripheral Manager State Updated: \(peripheral.state)")
        
        // bail out if peripheral is not powered on
        if peripheral.state != .poweredOn {
            return
        }
        peripheralManager?.startAdvertising(["name" : "Aaron", CBAdvertisementDataServiceUUIDsKey : [CBUUID.init(string: Device.TransferService)]])
        
        print("Bluetooth is Powered Up!!!")
        
        // Build Peripheral Service: first, create service characteristic
        self.transferCharacteristic = CBMutableCharacteristic(type: CBUUID.init(string: Device.TransferCharacteristic), properties: .notify, value: nil, permissions: .readable)
        
        // create the service
        let service = CBMutableService(type: CBUUID.init(string: Device.TransferService), primary: true)
        
        // add characteristic to the service
        service.characteristics = [self.transferCharacteristic!]
        
        // add service to the peripheral manager
        self.peripheralManager?.add(service)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central has subscribed to characteristic: \(central)")
        captureCurrentText()
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        // This callback comes in when the PeripheralManager is ready to send the next chunk of data.
        // This is to ensure that packets will arrive in the order they are sent
        sendTextData()
    }
    
    func updateValue(){
        captureCurrentText()
        sendTextData()
    }
}
