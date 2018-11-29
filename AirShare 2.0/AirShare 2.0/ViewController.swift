//
//  ViewController.swift
//  AirShare 2.0
//
//  Created by Aaron Sletten on 11/29/18.
//  Copyright © 2018 Tyler Gaffaney Inc. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    var centralManager : CentralManager?
    var peripheralManager : PeripheralManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePeripherals), name: NSNotification.Name(rawValue: "updatePeripherals"), object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        //Bluetooth
        centralManager = CentralManager.init()
        peripheralManager = PeripheralManager.init()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return centralManager!.peripherals!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCollectionViewCell
        
        if let name = (Array(centralManager!.peripherals!)[indexPath.row] as! CBPeripheral).name{
            cell.userNameLabel.text = name
        }else{
            cell.userNameLabel.text = "No Name"
        }
        
        return cell
    }
    
    @ objc func updatePeripherals(notif: NSNotification) {
        //Insert code here
//        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
}

