//
//  ProgressObject.swift
//  airShare
//
//  Created by Aaron Sletten on 12/5/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//

import UIKit

class ProgressObject: NSObject {
    
    var totalByteCount : Int = 0
    var currentByteCount : Int = 0
    
    //Callbacks
    var updateCurrentByteCountCallback : (()->())?
    var updateTotalByteCountCallback : (()->())?
    var updateStateCallback : (()->())?
    
    enum State {
        case sending
        case recieving
        case resting
        case waiting
    }
    var currentState = State.resting
    
    override init() {
        super.init()
    }
    
    func updateCurrentByteCount(newCurrentByteCount : Int){
        currentByteCount = newCurrentByteCount
        
        if let callback = updateCurrentByteCountCallback{
            callback()
        }
    }
    
    func updateTotalByteCount(newTotalByteCount : Int){
        totalByteCount = newTotalByteCount
        
        if let callback = updateTotalByteCountCallback{
            callback()
        }
    }
    
    func updateState(newState : State){
        currentState = newState
        
        if let callback = updateStateCallback{
            callback()
        }
    }
}
