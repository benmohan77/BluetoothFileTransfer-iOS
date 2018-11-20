//
//  BTPeripheralManagerService.swift
//  airShare
//
//  Created by Aaron Sletten on 11/12/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//

import UIKit
import CoreBluetooth

class BTPeripheralManagerService: NSObject, CBPeripheralManagerDelegate {
    static let instance = BTPeripheralManagerService()
    
    var myServiceUUID : CBUUID?
    var myCharacteristic : CBMutableCharacteristic?
    var myService : CBMutableService?
    var peripheralManager : CBPeripheralManager?
    
    override init() {
        super.init()
        print("BTPeripheralMangargerService: init")
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        //Create service and characteristics
        myServiceUUID = CBUUID(string: "8AF553DB-A5EF-406E-9B5B-208F24BD4919")
        myCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "9621B12C-FD7B-470B-8D8E-F3CF25DFAE2F"), properties: CBCharacteristicProperties.broadcast, value: Data(base64Encoded: "Test Characteristic Data"), permissions: CBAttributePermissions.readable)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("BTPeripheralManagerService: peripheral state: \(peripheral.state.rawValue)")
        
        if peripheral.state == CBManagerState.poweredOn {
            myService = CBMutableService(type: myServiceUUID!, primary: true)
            myService!.characteristics = [myCharacteristic!]
            
//            peripheralManager!.add(myService!)
            
            let test = ["Hello": "This is a test", "Hello again" : "This is another test"]
            peripheralManager!.startAdvertising(test)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("BTPeripheralManagerService: Added service")
        
//        let test = ["Hello": "This is a test", "Hello again" : "This is another test"]
//        peripheralManager!.startAdvertising(test)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("BTPeripheralManagerService: Did start advertising")
        print("BTPeripheralManagerService: Is Advertising \(peripheralManager!.isAdvertising)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("BTPeripheralManagerService: did recieve read request")
        
        request.value = Data(base64Encoded: "Test data")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("BTPeripheralManagerService: did subscribe to")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("BTPeripheralManagerService: didReceiveWrite request")
    }
}
