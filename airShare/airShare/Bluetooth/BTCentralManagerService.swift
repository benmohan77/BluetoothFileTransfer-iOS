//
//  BTService.swift
//  Solen 3.0
//
//  Created by Aaron Sletten on 10/11/18.
//  Copyright © 2018 Aaron Sletten. All rights reserved.
//

import UIKit
import CoreBluetooth

class BTCentralManagerService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let instance = BTCentralManagerService()
    
//    let services : [CBUUID] = [CBUUID(string: "AB12"), CBUUID(string: "ED44")]
    
    var myCentralManager : CBCentralManager?
    var myPeripheral : CBPeripheral?
    var peripherals = Set<CBPeripheral>()
    
//    var dataCharacteristic : CBCharacteristic?
//    var interuptCharacteristic : CBCharacteristic?
    
//    var imuData : IMUData?
//    var interuptData : InteruptData?
    
    override init() {
        super .init()
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
        print("BTCentralManagerService: Start")
    }
 
    //Central manager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("BTCentralManagerService: centralManagerDidUpdateState \(central.state.rawValue)")
        
        switch central.state {
        case .unknown:
            print("BTCentralManagerService: central state is unknown")
        case .resetting:
            print("BTCentralManagerService: central state is resetting")
        case .unsupported:
            print("BTCentralManagerService: central state is unsupported")
        case .unauthorized:
            print("BTCentralManagerService: central state is unauthorized")
        case .poweredOff:
            print("BTCentralManagerService: central state is poweredOff")
        case .poweredOn:
            print("BTCentralManagerService: central state is poweredOn")

//            myCentralManager!.scanForPeripherals(withServices: services, options: nil)
//            myCentralManager!.scanForPeripherals(withServices: nil, options: nil)
//            CBUUID(string: "8AF553DB-A5EF-406E-9B5B-208F24BD4919")
            myCentralManager!.scanForPeripherals(withServices: [CBUUID(string: "8AF553DB-A5EF-406E-9B5B-208F24BD4919")], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("BTCentralManagerService: didDiscoverPeripheral \(peripheral.name)")
        
        for service in peripheral.services ?? []{
            print("BTCentralManagerService: didDiscoverSerivce \(service.uuid)")
            for characteristic in service.characteristics ?? []{
                print("BTCentralManagerService: didDiscoverSerivce \(characteristic.value)")
            }
        }
        
        //Unwrap name
        if let name = peripheral.name{
            peripherals.insert(peripheral)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePeripherals"), object: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        print("BTCentralManagerService: didFailToConnect")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "connection failed"), object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("BTCentralManagerService: didConnect", peripheral)
        peripheral.readRSSI()
        
        peripheral.discoverServices(nil);
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "connected"), object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("BTCentralManagerService: didDisconnectPeripheral")
//        if peripheral == myPeripheral{
//            myPeripheral = nil
//        }
        peripherals.remove(peripheral)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePeripherals"), object: nil)
    }
    
    //Periperal
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("BTCentralManagerService: didModifyServices")
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("BTCentralManagerService: peripheralDidUpdateName")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("BTCentralManagerService: didReadRSSI", RSSI)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if let err = error{
            print("BTCentralManagerService: Did not write value for. \(err)")
        }else{
            print("BTCentralManagerService: didWriteValueFor")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("BTCentralManagerService: didUpdateValueFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("BTCentralManagerService: didDiscoverIncludedServicesFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("BTCentralManagerService: didDiscoverDescriptorsFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("BTCentralManagerService: didUpdateNotificationStateFor", characteristic.uuid, characteristic.isNotifying)
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
//        print("didOpen", channel ?? "nil")
//    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("BTCentralManagerService: is ready")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("BTCentralManagerService: Did discover services")
        
        if let services = peripheral.services {
            for service in services{
                print("BTCentralManagerService: Got service", service.uuid)
                service.peripheral.discoverCharacteristics(nil, for: service);
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("BTCentralManagerService: Got characteristic", characteristic.uuid, characteristic.value ?? "nil")
//                6545
                print(characteristic.uuid)
//                if(characteristic.uuid.isEqual(CBUUID.init(string: "5664"))){
//                    dataCharacteristic = characteristic
//                }else if(characteristic.uuid.isEqual(CBUUID.init(string: "12DF"))){
//                    interuptCharacteristic = characteristic
//                }
            }
        }
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//
//        if(characteristic.isEqual(dataCharacteristic)){
//            self.imuData = IMUData(inData: characteristic.value)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateIMUData"), object: nil)
//
//        }else if(characteristic.isEqual(interuptCharacteristic)){
//            self.interuptData = InteruptData(inData: characteristic.value);
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateInteruptData"), object: nil)
//        }
//    }

}
