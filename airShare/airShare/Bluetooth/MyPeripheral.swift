//
//  MyPeripheral.swift
//  AirShare 2.0
//
//  Created by Aaron Sletten on 11/29/18.
//  Copyright © 2018 Tyler Gaffaney Inc. All rights reserved.
//

import UIKit
import CoreBluetooth

class MyPeripheral: NSObject {
    
    var peripheral : CBPeripheral?
    var nameCharacteristic : CBCharacteristic?
    var transferCharacteristic : CBCharacteristic?
    var transferService : CBService?
    var name : String?
    
    init(peripheral : CBPeripheral) {
        super.init()
        self.peripheral = peripheral
    }
    
    //Go through a set of MyPeripherals and grab the one that has the same CBPeripheral
    static func getFromCBPeripheral(cbPeripheral : CBPeripheral, dict : Dictionary<String,MyPeripheral>) -> MyPeripheral?{
        return dict[cbPeripheral.identifier.uuidString]
    }
}
