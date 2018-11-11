//
//  ViewController.swift
//  airShare
//
//  Created by Tyler Gaffaney on 11/7/18.
//  Copyright © 2018 Tyler Gaffaney. All rights reserved.
//


import UIKit
import BSImagePicker
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    
    
    private var selectedFiles: [File]!
    private var actionSheet: UIAlertController!
    private var actionSheetIsPresented: Bool = false
    var list: FileList!

    @IBOutlet weak var CollectionWrapper: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mediaButton: UIButton!
    @IBAction func mediaButtonAction(_ sender: Any) {
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
        if(!actionSheetIsPresented){
            self.present(actionSheet, animated: true, completion: {
                self.actionSheetIsPresented = false
            })
            actionSheetIsPresented = true
        }
        
        
        
        
        
//        let vc = BSImagePickerViewController()
//        vc.settings.maxNumberOfSelections = 200
//
//        bs_presentImagePickerController(vc, animated: true,
//                                        select: { (asset: PHAsset) -> Void in
//                                            // User selected an asset.
//                                            // Do something with it, start upload perhaps?
//        }, deselect: { (asset: PHAsset) -> Void in
//            // User deselected an assets.
//            // Do something, cancel upload?
//
//        }, cancel: { (assets: [PHAsset]) -> Void in
//            // User cancelled. And this where the assets currently selected.
//            print("Cancelled")
//        }, finish: { (assets: [PHAsset]) -> Void in
//            // User finished with these assets
//            print("Finished")
//        }, completion: nil)
    }
    
    override func viewDidLoad() {
        self.CollectionWrapper.alpha = 0
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.isScrollEnabled = true
        
        list = FileList()
        list.setUpdateFunction {
            self.updateCollectView()
        }
        let actionSheet = UIAlertController(title: Constants.actionTitle, message: Constants.actionMessage, preferredStyle: .actionSheet)
        //actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in self.handleAction(.camera) }))
        actionSheet.addAction(UIAlertAction(title: Constants.photos, style: .default, handler: { (action) -> Void in self.handleAction(.photo)}))
        //actionSheet.addAction(UIAlertAction(title: Constants.videos, style: .default, handler: { (action) -> Void in self.handleAction(.video) }))
        //actionSheet.addAction(UIAlertAction(title: Constants.file, style: .default, handler: { (action) -> Void in self.handleAction(.document)}))
        actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
        self.selectedFiles = [File]()
        self.actionSheet = actionSheet
        self.actionSheetIsPresented = false
        
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        updateCollectView()
    }
    
    func updateCollectView() {
        DispatchQueue.main.async {
            if self.list.count > 0 {
                if self.CollectionWrapper.alpha == 0 {
                    self.updateListLabels()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.CollectionWrapper.alpha = 1
                    }) { (val) in
                        self.collectionView.reloadData()
                        self.CollectionWrapper.isUserInteractionEnabled = true
                    }
                }else{
                    self.collectionView.reloadData()
                    self.CollectionWrapper.isUserInteractionEnabled = true
                    self.updateListLabels()
                }
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.CollectionWrapper.alpha = 0
                }) { (val) in
                    self.collectionView.reloadData()
                    self.CollectionWrapper.isUserInteractionEnabled = false
                    self.updateListLabels()
                }
            }
        }
    }
    
    func handleAction(_ fileType: Types){
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
        switch fileType {
        case .camera:
            // FIXME
            break
        case .photo:
            let vc = BSImagePickerViewController()
            vc.settings.maxNumberOfSelections = 200
            vc.selectionCharacter = " "
            let defaultAssets = PHAsset.fetchAssets(withLocalIdentifiers: list.getSelectedPhotos(), options: nil)
            vc.defaultSelections = defaultAssets
            bs_presentImagePickerController(vc, animated: true,
                                                select: { (asset: PHAsset) -> Void in
                                                    // User selected an asset.
                                                    // Do something with it, start upload perhaps?
                }, deselect: { (asset: PHAsset) -> Void in
                    // User deselected an assets.
                    // Do something, cancel upload?
        
                }, cancel: { (assets: [PHAsset]) -> Void in
                    // User cancelled. And this where the assets currently selected.
                    print("Cancelled")
                }, finish: { (assets: [PHAsset]) -> Void in
                    var arr = [Photo]()
                    for element in assets {
                        if let name = element.originalFilename {
                            arr.append(Photo(image: element, name: name))
                        }
                    }
                    self.list.addPhotos(arr)
                    print("Finished")
            }, completion: nil)
        case .video:
            // FIXME
            break
        case .document:
            // FIXME
            break
        }
    }
    
    enum Types {
        case document
        case photo
        case video
        case camera
    }
    
    func removeFile(with identifier: String){
        
        if list.count > 1 {
            let index = list.indexOf(identifier: identifier)
            self.list.removeFile(identifier: identifier)
            collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
            updateListLabels()
        }else{
            self.list.removeFile(identifier: identifier)
            updateCollectView()
        }
    }
    
    func updateListLabels(){
        DispatchQueue.main.async {
            let size = self.list.getFileSize()
            let text = FileList.converByteToHumanReadable(size)
            self.sizeLabel.text = "Size: \(text)"
        }
        
    }
    
    /* Collection View */
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "miniCollect", for: indexPath) as! MiniCollectionViewCell
        cell.setup(list[indexPath.row], deleteHandler: removeFile)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 65, height: 142)
    }
}


