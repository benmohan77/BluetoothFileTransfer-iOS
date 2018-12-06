//
//  CollectionViewCell.swift
//  airShare
//
//  Created by Tyler Gaffaney on 11/11/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//

import UIKit
import Photos

class MiniCollectionViewCell: UICollectionViewCell {
    @IBAction func deleteItem(_ sender: Any) {
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
        deleteHandler(file.identifier)
    }
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    private var deleteHandler: ((String)->())!
    private var file: File!
    
    func setup(_ file: File, deleteHandler: @escaping ((String)->())) {
        self.file = file
        label.text = ""//file.name
        self.deleteHandler = deleteHandler
        switch file.type {
        case .photo:
            
            let photo = file as! Photo
            image.image = getAssetThumbnail(asset: photo.image)
            break
        default:
            let _ = 0
            //print("Non photo")
        }
        
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let size = CGSize(width: 65, height: 90)
//        let retinaScale = UIScreen.main.scale
//        let retineSquare = CGSize(width: size.width, height: size.height * retinaScale)
//        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
//        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height: CGFloat(cropSizeLength))
//        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        //options.normalizedCropRect = cropRect
        
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
}

