//
//  ViewController.swift
//  airShare
//
//  Created by Tyler Gaffaney on 11/7/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//


import UIKit
import BSImagePicker
import Photos
import UserNotifications

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var statusLabel: UILabel!
    var centralManager : CentralManager?
    var peripheralManager : PeripheralManager?
    
    override func viewDidLoad() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) { (granted, error) in }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePeripherals), name: NSNotification.Name(rawValue: "updatePeripherals"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePeripheralNames), name: NSNotification.Name(rawValue: "updatePeripheralNames"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatedData), name: NSNotification.Name(rawValue: "updatedData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestedFiles), name: NSNotification.Name(rawValue: "requestedFiles"), object: nil)
        
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        updateCollectView()
    }
    
    override func viewDidLayoutSubviews() {
        if(Helper.getName() == nil){
            Helper.askForName(vc: self, callback: {
                self.setManagers()
            })
        }else{
            self.setManagers()
        }
    }
    
    func setManagers(){
        centralManager = CentralManager()
        peripheralManager = PeripheralManager()
    }
    
    func updateCollectView() {
        DispatchQueue.main.async {
            
        }
    }
    
    /* Collection View */
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return centralManager?.myPeripherals?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "usercell", for: indexPath) as! UserCollectionViewCell
        let myPeripheral = Array(centralManager!.myPeripherals!.values)[indexPath.row]
        
        
        cell.subview.layer.cornerRadius = 27
        if let name = myPeripheral.name{
            cell.letter.text = "\(name.first ?? "%")"
            cell.label.text = name
        }else{
            cell.letter.text = "N"
            cell.label.text = "No Name"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let myPeripheral = Array(centralManager!.myPeripherals!.values)[indexPath.row] as? MyPeripheral{
            
            print("Connecting to \(myPeripheral.name)")
            
            centralManager?.centralManager.connect(myPeripheral.peripheral!, options: nil)
            //            myPeripheral.peripheral!.setNotifyValue(true, for: myPeripheral.transferCharacteristic!)
        }else{
            print("Couldnt find peripheral")
        }
    }
    
    func measure(_ title: String, block: (() -> ()) -> ()) {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        block {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("\(title):: Time: \(timeElapsed)")
        }
    }
    
    @ objc func updatePeripherals(notif: NSNotification) {
        self.collectionView.reloadData()
    }
    
    @ objc func updatePeripheralNames(notif: NSNotification){
        self.collectionView.reloadData()
    }
    
    @ objc func updatedData(notif: NSNotification){
        let alert = UIAlertController(title: "File Received!", message: "Message", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        let data = centralManager!.myData!
        let image = UIImage.init(data: data)
        let maxWidth = image?.size.width
        let maxHeight = image?.size.height
        print(maxWidth)
        print(maxHeight)
        let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        imgViewTitle.image = image
        
        alert.view.addSubview(imgViewTitle)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @ objc func requestedFiles(notif: NSNotification){
        let alert = UIAlertController(title: "Send File?", message: "\(peripheralManager?.centralName ?? "Someone") is requesting a file", preferredStyle: .alert)
        
        let sendAction = UIAlertAction(title: "Send", style: .default) {
            [unowned self] action in
            let f = BSImagePickerViewController.init()
            f.maxNumberOfSelections = 1
            self.bs_presentImagePickerController(f, animated: true, select: { (asset) in
                //
            }, deselect: { (asset) in
                //
            }, cancel: { (assetArr) in
                //
            }, finish: { (assetArr) in
                //
                if let asset = assetArr.first {
                    let manager = PHImageManager.default()
                    let option = PHImageRequestOptions()
                    var thumbnail = UIImage()
                    option.isSynchronous = true
                    manager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                        thumbnail = result!
                    })
                    self.peripheralManager?.imageToSend = thumbnail
                    self.peripheralManager?.updateValue()
                }
                
            }, completion: {
                
            }, selectLimitReached: { (num) in
                //
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            [unowned self] action in
            
            //Kick off sending data
            self.peripheralManager?.sendEOM()
        }
        
        alert.addAction(sendAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
        //Send local notification
        let identifier = "UYLLocalNotification"
        let content = UNMutableNotificationContent()
        content.title = "File Request"
        content.body = "\(peripheralManager?.centralName ?? "Someone") is requesting a file"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
        })
    }
}


