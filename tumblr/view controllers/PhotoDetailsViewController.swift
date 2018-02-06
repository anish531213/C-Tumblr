//
//  PhotoDetailsViewController.swift
//  tumblr
//
//  Created by Anish Adhikari on 1/27/18.
//  Copyright © 2018 Anish Adhikari. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchPhoto(sender:)))
        
        self.view.addGestureRecognizer(tapGesture)
        
        if let url = URL(string: imageUrl!) {
            imageView.af_setImage(withURL: url)
        } else {
            print("ImageURLString not found")
        } 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pinchPhoto(sender: UIPinchGestureRecognizer) {
        print("image i=pinched")
        
        performSegue(withIdentifier: "fullScreenSegue", sender: PhotoDetailsViewController.self)
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let fullScreen = segue.destination as! FullScreenPhotoViewController
        fullScreen.imageUrlString = imageUrl
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
