//
//  ProgressViewController.swift
//  airShare
//
//  Created by Tyler Gaffaney on 12/5/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    @IBOutlet weak var foregroundView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBAction func buttonAction(_ sender: Any) {
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
    }
    
    var labelText = ""
    var progressVal: Float = 0
    
    
    var loading = false
    var viewController: UIViewController!
    var progressObject: ProgressObject!
    var inView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func loadIncrement(){
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        inView = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        inView = true
        self.foregroundView.layer.cornerRadius = 10
        self.foregroundView.alpha = 0
        self.backgroundView.alpha = 0
        self.label.text = labelText
        self.progress.progress = progressVal
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .allowAnimatedContent, animations: {
            self.backgroundView.alpha = 0.4
            self.foregroundView.alpha = 1
        })
    }
    
    func p(){
        viewController.present(self, animated: true) {
            
        }
    }
    
    func d(){
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundView.alpha = 0
            self.foregroundView.alpha = 0
        }, completion: { (val) in
            self.dismiss(animated: true) {
                
            }
        })
    }
    
    func d(callback: @escaping ()->()){
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundView.alpha = 0
            self.foregroundView.alpha = 0
        }, completion: { (val) in
            self.dismiss(animated: true) {
                callback()
            }
        })
    }
    
    
    private func updateState(){
        let newState = progressObject.currentState
        if(newState == .recieving){
            print("Recieving")
            labelText = "Recieving"
            progressVal = 0
            self.p()
        }else if(newState == .sending){
            print("Sending")
            labelText = "Sending"
            progressVal = 0
            self.p()
        }else if(newState == .resting){
            print("Resting")
            self.d()
        }
    }
    
    private func updateByte(){
        if(inView){
            let total = progressObject.totalByteCount
            let current = progressObject.currentByteCount
            let progress = Double(current) / Double(total)
            self.progress.progress = Float(progress)
            print("\(current) \(total) progress \(progress)")
        }else{
            
        }
    }
    
    static func construct(parentController: UIViewController, progressObject: ProgressObject) -> ProgressViewController? {
        if let vc = parentController.storyboard?.instantiateViewController(withIdentifier: "progressVC") as? ProgressViewController {
            vc.viewController = parentController
            vc.progressObject = progressObject
            vc.progressObject.updateCurrentByteCountCallback = {
                vc.updateByte()
            }
            vc.progressObject.updateStateCallback = {
                vc.updateState()
            }
            return vc
        }
        return nil
    }
}