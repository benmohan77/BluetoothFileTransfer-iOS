//
//  CentralManagerViewController.swift
//  BLEConnect
//
//  Created by Evan Stone on 8/12/16.
//  Copyright © 2016 Cloud City. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralManagerViewController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager:CBCentralManager!
    var peripheral:CBPeripheral?
    var dataBuffer:NSMutableData!
    var scanAfterDisconnecting:Bool = true
    
    //My stuff
    var peripherals : Set<CBPeripheral>?
    var myPeripherals : Set<MyPeripheral>?
    
    override init() {
        super.init()
        
        dataBuffer = NSMutableData()
        peripherals = Set<CBPeripheral>()
        myPeripherals = Set()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

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
        
        if central.state != .poweredOn {
            self.peripheral = nil
            return
        }
        
        startScanning()
        
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
        
        let serviceUUID = CBUUID(string: Device.TransferService)
        if let serviceIndex = peripheralServices.index(where: {$0.uuid == serviceUUID}) {
            // we have the service, but now we check to see if we have a characteristic that we've subscribed to...
            let transferService = peripheralServices[serviceIndex]
            let characteristicUUID = CBUUID(string: Device.TransferCharacteristic)
            if let characteristics = transferService.characteristics {
                if let characteristicIndex = characteristics.index(where: {$0.uuid == characteristicUUID}) {
                    let characteristic = characteristics[characteristicIndex]
                    if !characteristic.isNotifying {
                       peripheral.setNotifyValue(true, for: characteristic)
                    }
                } else {
                    peripheral.discoverCharacteristics([characteristicUUID], for: transferService)
                }
            }
        } else {
            peripheral.discoverServices([serviceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name) at \(RSSI)")
        
        // check to see if we've already saved a reference to this peripheral
        if self.peripheral != peripheral {
            
            // save a reference to the peripheral object so Core Bluetooth doesn't get rid of it
            self.peripheral = peripheral
            
            // connect to the peripheral
            print("Connecting to peripheral: \(peripheral)")
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected!!!")

        // Stop scanning
        centralManager.stopScan()
        print("Scanning Stopped!")

        // Clear any cached data...
        dataBuffer.length = 0
        
        // IMPORTANT: Set the delegate property, otherwise we won't receive the discovery callbacks, like peripheral(_:didDiscoverServices)
        peripheral.delegate = self
        
        // Now that we've successfully connected to the peripheral, let's discover the services.
        // This time, we will search for the transfer service UUID
        print("Looking for Transfer Service...")
        peripheral.discoverServices([CBUUID.init(string: Device.TransferService)])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral) (\(error?.localizedDescription))")
        self.disconnect()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // set our reference to nil and start scanning again...
        print("Disconnected from Peripheral")
        self.peripheral = nil
        if scanAfterDisconnecting {
            startScanning()
        }
    }

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
                print("Discovered service \(service)")
                
                // If we found either the transfer service, discover the transfer characteristic
                if (service.uuid == CBUUID(string: Device.TransferService)) {
                    let transferCharacteristicUUID = CBUUID.init(string: Device.TransferCharacteristic)
                    peripheral.discoverCharacteristics([transferCharacteristicUUID], for: service)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering characteristics: \(error?.localizedDescription)")
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Transfer Characteristic
                if characteristic.uuid == CBUUID(string: Device.TransferCharacteristic) {
                    // subscribe to dynamic changes
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueForCharacteristic: \(Date())")
        
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
        
        print("Bytes transferred: \(value.count)")
        
        // make sure we have a characteristic value
        guard let nextChunk = String(data: value, encoding: String.Encoding.utf8) else {
            print("Next chunk of data is nil.")
            return
        }
        
        print("Next chunk: \(nextChunk)")
        
        // If we get the EOM tag, we fill the text view
        if (nextChunk == Device.EOM) {
            if let message = String(data: dataBuffer as Data, encoding: String.Encoding.utf8) {
                print("Final message: \(message)")
                
                // truncate our buffer now that we received the EOM signal!
                dataBuffer.length = 0
            }
        } else {
            dataBuffer.append(value)
            print("Next chunk received: \(nextChunk)")
            if let buffer = self.dataBuffer {
                print("Transfer buffer: \(String(data: buffer as Data, encoding: String.Encoding.utf8))")
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
}
