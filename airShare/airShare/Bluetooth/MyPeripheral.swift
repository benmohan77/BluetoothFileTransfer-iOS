//
//  MyPeripheral.swift
//  airShare
//
//  Created by Tyler Gaffaney on 12/2/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//

import UIKit
import CoreBluetooth

class MyPeripheral: NSObject {
    
    var peripheral : CBPeripheral?
    var nameCharacteristic : CBCharacteristic?
    var airshareService : CBService?
    var name : String?
    
    init(peripheral : CBPeripheral) {
        super.init()
        self.peripheral = peripheral
    }
    
    //Go through a set of MyPeripherals and grab the one that has the same CBPeripheral
    static func getFromCBPeripheral(cbPeripheral : CBPeripheral, set : Set<MyPeripheral>) -> MyPeripheral?{
        
        for perph in set {
            if perph.peripheral!.isEqual(cbPeripheral){
                return perph
            }
        }
        return nil
    }
}
