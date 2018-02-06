//
//  FullScreenPhotoViewController.swift
//  tumblr
//
//  Created by Anish Adhikari on 1/28/18.
//  Copyright © 2018 Anish Adhikari. All rights reserved.
//

import UIKit

class FullScreenPhotoViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var image: UIImageView!
    
    var imageUrlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        
        let imgURL = URL(string: imageUrlString)
        image.af_setImage(withURL: imgURL!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return image
    }

    @IBAction func closeFullScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
