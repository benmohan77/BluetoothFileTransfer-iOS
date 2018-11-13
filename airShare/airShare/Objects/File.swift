//
//  File.swift
//  airShare
//
//  Created by Tyler Gaffaney on 11/11/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//

import Foundation

enum FileType {
    case photo
    case video
    case document
}

class File {
    private var p_ext: String
    private var p_name: String
    private var p_type: FileType
    private var p_identifier: String
    var type: FileType {
        get {
            return p_type
        }
    }
    var name: String {
        get {
            return p_name
        }
    }
    var identifier: String {
        get {
            return p_identifier
        }
    }
    
    //In Bytes
    func getSize() -> Int64 {
        return 0
    }
    
    init(name: String, ext: String, id: String, type: FileType) {
        p_type = type
        p_name = name
        p_ext = ext
        p_identifier = id
    }
}


