import UIKit
import CoreBluetooth

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePeripherals), name: NSNotification.Name(rawValue: "updatePeripherals"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePeripheralNames), name: NSNotification.Name(rawValue: "updatePeripheralNames"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatedData), name: NSNotification.Name(rawValue: "updatedData"), object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Bluetooth
        centralManager = CentralManager.init()
        peripheralManager = PeripheralManager2.init()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return centralManager!.peripherals!.count
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
}

