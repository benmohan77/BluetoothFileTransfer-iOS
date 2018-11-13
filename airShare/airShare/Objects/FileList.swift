//
//  FileList.swift
//  airShare
//
//  Created by Tyler Gaffaney on 11/11/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//

import Foundation
import Photos

class FileList {
    private var photoDictionary: Dictionary<String, String>!
    private var list: [File]!
    private var updateFunction: (()->())?
    
    subscript(index: Int) -> File {
        get {
            return list[index]
        }
    }
    
    init() {
        list = [File]()
        photoDictionary = Dictionary<String,String>()
    }
    
    var count: Int {
        get {
            return list.count
        }
    }
    
    func setUpdateFunction( _ update: @escaping (() -> ()) ){
        updateFunction = update
    }
    
    func getFileSize() {
        var size: Int64 = 0
        for element in list {
            let val = element.getSize()
            size += val
        }
        //return size
    }
    
    static func converByteToHumanReadable(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    func getSelectedPhotos() -> [String] {
        return Array(photoDictionary.keys)
    }
    
    func indexOf(identifier: String)-> Int{
        var index = 0
        for element in list {
            if element.identifier == identifier {
                return index
            }
            index += 1
        }
        return -1
    }
    
    func addPhotos(_ photos: [Photo]){
        var changesMade = false
        var nd = Dictionary<String,String>()
        
        for photo in photos {
            if photoDictionary[photo.identifier] == nil {
                list.append(photo)
                changesMade = true
            }else{
                photoDictionary.removeValue(forKey: photo.identifier)
            }
            
            let id = photo.identifier
            nd[id] = " "
        }
        
        for key in photoDictionary.keys {
            removeFile(identifier: key)
            changesMade = true
        }
        
        photoDictionary = nd
        if changesMade {
            updateDependant()
        }
    }
    
    func addCamera(_ cameraPhoto: Photo){
        // FIXME
    }
    
    func removeFile(identifier: String){
        var index = 0
        for file in list {
            if file.identifier == identifier {
                if file.type == .photo {
                    photoDictionary.removeValue(forKey: file.identifier)
                }
                list.remove(at: index)
                break
            }
            index += 1
        }
    }
    
    func removeFile(index: Int){
        // FIXME
    }
    
    
    func removeAll(){
        photoDictionary = Dictionary<String,String>()
        list = [File]()
        updateDependant()
    }
    
    func addDocument(_ document: File){
        // FIXME
    }
    
    private func updateDependant(){
        if let up = updateFunction {
            up()
        }
    }
}
