import UIKit
import CoreBluetooth
import UserNotifications

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var textView: UITextView!
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var imageView: UIImageView!
    
    @IBAction func testButton(_ sender: Any) {
        peripheralManager?.updateValue()
    }
    
    var centralManager : CentralManager?
    var peripheralManager : PeripheralManager2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePeripherals), name: NSNotification.Name(rawValue: "updatePeripherals"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePeripheralNames), name: NSNotification.Name(rawValue: "updatePeripheralNames"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatedData), name: NSNotification.Name(rawValue: "updatedData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestedFiles), name: NSNotification.Name(rawValue: "requestedFiles"), object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Bluetooth
        
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
        centralManager = CentralManager.init()
        peripheralManager = PeripheralManager2.init()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return centralManager?.myPeripherals?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCollectionViewCell
        
        let myPeripheral = Array(centralManager!.myPeripherals!)[indexPath.row] as! MyPeripheral
        
        if let name = myPeripheral.name{
            cell.userNameLabel.text = name
        }else{
            cell.userNameLabel.text = "No Name"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let myPeripheral = Array(centralManager!.myPeripherals!)[indexPath.row] as? MyPeripheral{
            print("Connecting to \(myPeripheral.name)")
            
            centralManager?.centralManager.connect(myPeripheral.peripheral!, options: nil)
//            myPeripheral.peripheral!.setNotifyValue(true, for: myPeripheral.transferCharacteristic!)
           
        }else{
            print("Couldnt find peripheral")
        }
    }
    
    @ objc func updatePeripherals(notif: NSNotification) {
        self.collectionView.reloadData()
    }
    
    @ objc func updatePeripheralNames(notif: NSNotification){
        self.collectionView.reloadData()
    }
    
    @ objc func updatedData(notif: NSNotification){
        //var message = String(data: centralManager!.myData!, encoding: .utf8)
        var data = centralManager!.myData!
        var image = UIImage.init(data: data)
        imageView.image = image
//        textView!.text = message
    }
    
    @ objc func requestedFiles(notif: NSNotification){
        let alert = UIAlertController(title: "Send File?", message: "\(peripheralManager?.centralName ?? "Someone") is requesting a file", preferredStyle: .alert)
        
        let sendAction = UIAlertAction(title: "Send", style: .default) {
            [unowned self] action in
            
            //Kick off sending data
            self.peripheralManager?.updateValue()
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

