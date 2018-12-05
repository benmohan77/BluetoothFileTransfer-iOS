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
    @IBOutlet weak var progressView: NSLayoutConstraint!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBAction func buttonAction(_ sender: Any) {
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
    }
    
    var loading = false
    var viewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func loadIncrement(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.foregroundView.layer.cornerRadius = 10
        self.foregroundView.alpha = 0
        self.backgroundView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .allowAnimatedContent, animations: {
            self.backgroundView.alpha = 0.4
            self.foregroundView.alpha = 1
        })
    }
    
    
    private func updateViews(){
        
    }
    
    func disappear(){
        
    }
    
    static func presentOn(viewController: UIViewController) -> ProgressViewController? {
        if let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "progressVC") as? ProgressViewController {
            vc.viewController = viewController
            viewController.present(vc, animated: true, completion: nil)
        }
        return nil
    }
}
