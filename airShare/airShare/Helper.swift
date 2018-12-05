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
    
    static func askForName(vc: ViewController, callback: @escaping ()->()){
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
            vc.progressVC!.dismiss(animated: true, completion: {
                
            })
            
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
    
    static func alert(data: Data, vc: ViewController){
        if let image = UIImage.init(data: data){
            let alert = UIAlertController(title: "File Received!", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Accept", style: .default) { (alert) in
                // image to share
                // set up activity view controller
                let imageToShare: [UIImage] = [image]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = vc.view // so that iPads won't crash
                
                // exclude some activity types from the list (optional)
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                
                // present the view controller
                vc.present(activityViewController, animated: true, completion: nil)
            }
            let ac = UIAlertAction(title: "Discard", style: .destructive) { (asfd) in
                
            }
            alert.addAction(ac)
            alert.addAction(action)
            
            
            print(alert.view.frame.width)
            DispatchQueue.main.async {
                alert.view.alpha = 0
                vc.progressVC!.d {
                    vc.present(alert, animated: true) {
                        let imageWidth = image.size.width
                        let imageHeight = image.size.height
                        let alertWidth = alert.view.frame.size.width
                        
                        let scale:CGFloat = alertWidth / imageWidth
                        
                        let newHeight = scale * imageHeight
                        let newWidth = scale * imageWidth
                        let imgViewTitle = UIImageView(frame: CGRect(x: 0, y: 55, width: newWidth, height: newHeight))
                        
                        imgViewTitle.image = resizeImage(image: image, targetSize: CGSize(width: newWidth, height: newHeight))
                        
                        alert.view.addSubview(imgViewTitle)
                        
                        
                        let desiredHeight: CGFloat = newHeight + 100
                        var height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: desiredHeight)
                        alert.view.addConstraint(height);
                        UIView.animate(withDuration: 0.4, animations: {
                            alert.view.alpha = 1
                        })
                    }
                }
            }
            
        }else{
            //Data not an image
        }
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
