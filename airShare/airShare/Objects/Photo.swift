//
//  Photo.swift
//  airShare
//
//  Created by Tyler Gaffaney on 11/11/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//

import Foundation
import Photos

class Photo: File {
    private var p_image: PHAsset!
    var image: PHAsset {
        get {
            return p_image
        }
    }
    
    init(image: PHAsset, name: String){
        p_image = image
        var values = name.components(separatedBy: ".")
        if values.count < 2 {
            super.init(name: "Hi", ext: "", id: "", type: .document)
        }else if values.count == 2 {
            super.init(name: values[0], ext: values[1], id: image.localIdentifier, type: .photo)
        }else{
            super.init(name: "Hi", ext: "", id: "", type: .document)
        }
    }
    
    override func getSize() -> Int64 {
        let resources = PHAssetResource.assetResources(for: image) // your PHAsset
        
        var sizeOnDisk: Int64? = 0
        
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
        }
        return sizeOnDisk ?? 0
    }
}

extension PHAsset {
    
    var originalFilename: String? {
        
        var fname:String?
        
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first {
                fname = resource.originalFilename
            }
        }
        
        if fname == nil {
            // this is an undocumented workaround that works as of iOS 9.1
            fname = self.value(forKey: "filename") as? String
        }
        
        return fname
    }
}
