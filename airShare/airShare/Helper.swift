//
//  Helper.swift
//  AirShare 2.0
//
//  Created by Tyler Gaffaney on 12/3/18.
//  Copyright © 2018 Tyler Gaffaney Inc. All rights reserved.
//

import Foundation
import UIKit

enum Types {
    case document
    case photo
    case video
    case camera
}

class Helper {
    
    static func askForName(vc: UIViewController, callback: @escaping ()->()){
        var textField: UITextField?
        
        // create alertController
        let alertController = UIAlertController(title: "Device Name", message: "Please enter a device name", preferredStyle: .alert)
        
        alertController.addTextField { (pTextField) in
            pTextField.placeholder = "Noah's iPhone"
            pTextField.clearButtonMode = .whileEditing
            pTextField.borderStyle = .none
            textField = pTextField
        }
        
        // create Ok button
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (pAction) in
            // when user taps OK, you get your value here
            if let inputValue = textField?.text {
                if inputValue != "" {
                    Helper.set(name: inputValue)
                    alertController.dismiss(animated: true, completion: nil)
                    callback()
                }
            }
        }))
        
        // show alert controller
        DispatchQueue.main.async {
            vc.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    private static func set(name: String){
        let standard = UserDefaults.standard
        standard.set(name, forKey: "my_device_name")
    }
    
    static func getName() -> String?{
        let standard = UserDefaults.standard
        return standard.string(forKey: "my_device_name")
    }
    
    static func getNameFor(id: String) -> String?{
        let standard = UserDefaults.standard
        var test = standard.string(forKey:"id_" + id)
        return test
    }
    
    static func set(name: String, id: String){
        if(name == "Someone"){
            print("NOOOOOOOOOOO")
        }
        let standard = UserDefaults.standard
        standard.set(name, forKey: "id_" + id)
    }
    
    static func alert(data: Data, vc: UIViewController){
        if let image = UIImage.init(data: data){
            let alert = UIAlertController(title: "File Received!", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            let imageWidth = image.size.width * 3
            let imageHeight = image.size.height * 3
            let alertWidth = alert.view.frame.size.width - 20.0
            
            let scale = alertWidth / imageWidth
            
            let newHeight = scale * imageHeight
            let newWidth = scale * imageWidth
            let imgViewTitle = UIImageView(frame: CGRect(x: 0, y: 55, width: newWidth, height: newHeight))
            let edges = UIEdgeInsets(top: 0, left: 0, bottom: newHeight, right: newWidth)
            let newImage = image.resizableImage(withCapInsets: edges)
            imgViewTitle.image = newImage
            
            alert.view.addSubview(imgViewTitle)
            alert.addAction(action)
            
            let desiredHeight: CGFloat = newHeight + 100
            var height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: desiredHeight)
            alert.view.addConstraint(height);
            print(alert.view.frame.width)
            
            vc.present(alert, animated: true, completion: nil)
//            vc.present(alert, animated: true) {
//                <#code#>
//            }
        }else{
            //Data not an image
        }
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
