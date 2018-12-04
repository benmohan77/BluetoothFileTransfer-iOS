import UIKit
import CoreBluetooth

class CentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager:CBCentralManager!
    var peripheral:CBPeripheral?
    var dataBuffer:NSMutableData!
    var scanAfterDisconnecting:Bool = true
    var myPeripherals : Set<MyPeripheral>?
    var peripherals : Set<CBPeripheral>?
    var myData : Data?

    // MARK: Handling User Interactions
    override init() {
        super.init()
        
        dataBuffer = NSMutableData()
        myPeripherals = Set()
        peripherals = Set()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: Central management methods
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func startScanning() {
        if centralManager.isScanning {
            print("Central Manager is already scanning!!")
            return;
        }
        centralManager.scanForPeripherals(withServices: [CBUUID.init(string: Device.TransferService)], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        print("Scanning Started!")
    }
    
    func disconnect() {
        // verify we have a peripheral
        guard let peripheral = self.peripheral else {
            print("Peripheral object has not been created yet.")
            return
        }
        
        // check to see if the peripheral is connected
        if peripheral.state != .connected {
            print("Peripheral exists but is not connected.")
            self.peripheral = nil
            return
        }
        
        guard let services = peripheral.services else {
            // disconnect directly
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        for service in services {
            // iterate through characteristics
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    // find the Transfer Characteristic we defined in our Device struct
                    if characteristic.uuid == CBUUID.init(string: Device.TransferCharacteristic) {
                        // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                        // didUpdateNotificationStateForCharacteristic method will be called automatically
                        peripheral.setNotifyValue(false, for: characteristic)
                        return
                    }
                }
            }
        }
        
        // We have a connection to the device but we are not subscribed to the Transfer Characteristic for some reason.
        // Therefore, we will just disconnect from the peripheral
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager State Updated: \(central.state)")
        
        // We showed more detailed handling of this in Zero-to-BLE Part 2, so please refer to that if you would like more information.
        // We will just handle it the easy way here: if Bluetooth is on, proceed...
        if central.state != .poweredOn {
            self.peripheral = nil
            return
        }
        
        startScanning()

        // check for a peripheral object
        guard let peripheral = self.peripheral else {
            return
        }

        // see if that peripheral is connected
        guard peripheral.state == .connected else {
            return
        }

        // make sure the peripheral has services
        guard let peripheralServices = peripheral.services else {
            return
        }
        
        // we have services, but we need to check for the Transfer Service
        // (honestly, this may be overkill for our project but it demonstrates how to make this process more bulletproof...)
        // Also: Pardon the pyramid.
//        let serviceUUID = CBUUID(string: Device.TransferService)
//        if let serviceIndex = peripheralServices.index(where: {$0.uuid == serviceUUID}) {
//            // we have the service, but now we check to see if we have a characteristic that we've subscribed to...
//            let transferService = peripheralServices[serviceIndex]
//            let characteristicUUID = CBUUID(string: Device.TransferCharacteristic)
//            if let characteristics = transferService.characteristics {
//                if let characteristicIndex = characteristics.index(where: {$0.uuid == characteristicUUID}) {
//                    // Because this is a characteristic that we subscribe to in the standard workflow,
//                    // we need to check if we are currently subscribed, and if not, then call the
//                    // setNotifyValue like we did before.
//                    let characteristic = characteristics[characteristicIndex]
//                    if !characteristic.isNotifying {
//                       peripheral.setNotifyValue(true, for: characteristic)
//                    }
//                } else {
//                    // if we have not discovered the characteristic yet, then call discoverCharacteristics, and the delegate method will get called as in the standard workflow...
//                    peripheral.discoverCharacteristics([characteristicUUID], for: transferService)
//                }
//            }
//        } else {
//            // we have a CBPeripheral object, but we have not discovered the services yet,
//            // so we call discoverServices and the delegate method will handle the rest...
//            peripheral.discoverServices([serviceUUID])
//        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if !peripherals!.contains(peripheral){
            print("Discovered \(peripheral.name) at \(RSSI)")
            peripherals?.insert(peripheral)
            
            let tempMyPeripheral = MyPeripheral(peripheral: peripheral)
            tempMyPeripheral.name = advertisementData[CBAdvertisementDataLocalNameKey] as! String
            
            myPeripherals?.insert(tempMyPeripheral)
            
//            let transferSeviceUUID = CBUUID(string: Device.TransferService)
//            peripheral.discoverServices([transferSeviceUUID])
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePeripherals"), object: nil)
            
        }
        
//        // check to see if we've already saved a reference to this peripheral
//        if self.peripheral != peripheral {
////            self.peripheral = peripheral
//
//            let transferSeviceUUID = CBUUID(string: Device.TransferService)
//            peripheral.discoverServices([transferSeviceUUID])
//            // connect to the peripheral
////            print("Connecting to peripheral: \(peripheral)")
////            centralManager?.connect(peripheral, options: nil)
//        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected!!!")
        
        // Stop scanning
        centralManager.stopScan()
        print("Scanning Stopped!")

        // Clear any cached data...
        dataBuffer.length = 0
        
        self.peripheral = peripheral
        // IMPORTANT: Set the delegate property, otherwise we won't receive the discovery callbacks, like peripheral(_:didDiscoverServices)
        peripheral.delegate = self
        
        // Now that we've successfully connected to the peripheral, let's discover the services.
        // This time, we will search for the transfer service UUID
//        print("Looking for Transfer Service...")
        peripheral.discoverServices([CBUUID.init(string: Device.TransferService)])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // set our reference to nil and start scanning again...
        print("Disconnected from Peripheral")
        self.peripheral = nil
        if scanAfterDisconnecting {
            startScanning()
        }
    }
    
    //MARK: - CBPeripheralDelegate methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("Discovered Services!!!")

        if error != nil {
            print("Error discovering services: \(error?.localizedDescription)")
            disconnect()
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("Discovered service")
                
                // If we found either the transfer service, discover the transfer characteristic
                if (service.uuid == CBUUID(string: Device.TransferService)) {
                    let transferCharacteristicUUID = CBUUID.init(string: Device.TransferCharacteristic)
                    let nameCharacteristicUUID = CBUUID.init(string: Device.NameCharacteristic)
                    let centralNameCharacteristicUUID = CBUUID.init(string: Device.CentralNameCharacteristic)
                    
                    peripheral.discoverCharacteristics([transferCharacteristicUUID, nameCharacteristicUUID,centralNameCharacteristicUUID], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print("Error discovering characteristics: \(err.localizedDescription)")
            return
        }
        
        //Get my peripheral
        let myPeripheral = MyPeripheral.getFromCBPeripheral(cbPeripheral: peripheral, set: myPeripherals!)
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                
                // Transfer Characteristic
                if characteristic.uuid == CBUUID(string: Device.TransferCharacteristic) {
                    // subscribe to dynamic changes
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("found transfer characteristic")
                    myPeripheral?.transferCharacteristic = characteristic
                }else if characteristic.uuid == CBUUID(string: Device.NameCharacteristic){
                    print("found name characteristic")
                    myPeripheral?.nameCharacteristic = characteristic
                    //Get name from peripheral
                    peripheral.readValue(for: characteristic)
                }else if characteristic.uuid == CBUUID(string: Device.CentralNameCharacteristic){
                    print("found central name characteristic")
                    self.peripheral?.writeValue("Aaron".data(using: .utf8)!, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        // if there was an error then print it and bail out
        if error != nil {
            print("Error updating value for characteristic: \(characteristic) - \(error?.localizedDescription)")
            return
        }
        
        // make sure we have a characteristic value
        guard let value = characteristic.value else {
            print("Characteristic Value is nil on this go-round")
            return
        }
        
        //update name
        if characteristic.uuid == CBUUID(string: Device.NameCharacteristic){
            let myPeripheral = MyPeripheral.getFromCBPeripheral(cbPeripheral: peripheral, set: myPeripherals!)
            
            myPeripheral?.name = String(data: value, encoding: String.Encoding.utf8)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePeripherals"), object: nil)
        }else if characteristic.uuid == CBUUID(string: Device.TransferCharacteristic){
            // make sure we have a characteristic value
            if let checkEOM = String(data: value, encoding: String.Encoding.utf8){
                if checkEOM == Device.EOM{
                    print("Finished")
                    myData = dataBuffer as Data
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedData"), object: nil)
                    dataBuffer.length = 0
                    self.disconnect()
                }else{
                    dataBuffer.append(value)
                }
            }else{
                dataBuffer.append(value)
            }
        }
        
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // if there was an error then print it and bail out
        if error != nil {
            print("Error changing notification state: \(error?.localizedDescription)")
            return
        }
        
        if characteristic.isNotifying {
            // notification started
            print("Notification STARTED on characteristic: \(characteristic)")
        } else {
            // notification stopped
            print("Notification STOPPED on characteristic: \(characteristic)")
            self.centralManager.cancelPeripheralConnection(peripheral)
        }

    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral) (\(error?.localizedDescription))")
        self.disconnect()
    }
}
