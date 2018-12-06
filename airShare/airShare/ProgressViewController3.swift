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
    
    @IBOutlet weak var line: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var labelText = ""
    var progressVal: Float = 0
    
    
    var waiting = false
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
        if(waiting){
            self.foregroundView.layer.cornerRadius = 10
            self.foregroundView.alpha = 0
            self.backgroundView.alpha = 0
            self.label.text = labelText
            self.activityIndicator.startAnimating()
            self.progress.progress = progressVal
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .allowAnimatedContent, animations: {
                self.backgroundView.alpha = 0.4
            })
        }else{
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
    }
    
    func p(){
        viewController.present(self, animated: true) {
            
        }
    }
    
    func d(){
        DispatchQueue.main.async {
            //print("D called")
            UIView.animate(withDuration: 0.4, animations: {
                self.backgroundView.alpha = 0
                self.foregroundView.alpha = 0
            }, completion: { (val) in
                self.dismiss(animated: true) {
                    self.inView = false
                }
            })
        }
    }
    
    func d(callback: @escaping ()->()){
        DispatchQueue.main.async {
            if(self.inView){
                //print("D Callback called")
                UIView.animate(withDuration: 0.4, animations: {
                    self.backgroundView.alpha = 0
                    self.foregroundView.alpha = 0
                }, completion: { (val) in
                    self.dismiss(animated: true) {
                        callback()
                        self.inView = false
                    }
                })
            }
            callback()
        }
    }
    
    var prevState = ProgressObject.State.resting
    
    private func updateState(){
        let newState = progressObject.currentState
        if(newState == .recieving){
            print("\(prevState) to \(newState)")
            //print("Recieving")
            labelText = "Recieving"
            progressVal = 0
            waiting = false
            //self.p()
            self.activityIndicator.stopAnimating()
            self.foregroundView.layer.cornerRadius = 10
            self.foregroundView.alpha = 0
            self.label.text = labelText
            self.progress.progress = progressVal
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .allowAnimatedContent, animations: {
                self.foregroundView.alpha = 1
            })
            prevState = ProgressObject.State.recieving
        }else if(newState == .sending){
            //print("Sending")
            print("\(prevState) to \(newState)")
            labelText = "Sending"
            progressVal = 0
            waiting = false
            self.p()
            
            prevState = ProgressObject.State.sending
        }else if(newState == .resting){
            print("\(prevState) to \(newState)")
            //print("Resting")
            waiting = false
            if(prevState != ProgressObject.State.recieving && prevState != ProgressObject.State.resting){
                self.d()
            }
            prevState = ProgressObject.State.resting
        }else if(newState == .waiting){
            if(newState != prevState){
                print("\(prevState) to \(newState)")
                waiting = true
                self.p()
                prevState = ProgressObject.State.waiting
            }
        }
    }
    
    private func updateByte(){
        if(inView){
            let total = progressObject.totalByteCount
            let current = progressObject.currentByteCount
            let progress = Double(current) / Double(total)
            self.progress.progress = Float(progress)
            //print("\(current) \(total) progress \(progress)")
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
