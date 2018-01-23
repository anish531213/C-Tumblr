//
//  PhotosViewController.swift
//  tumblr
//
//  Created by Anish Adhikari on 1/22/18.
//  Copyright © 2018 Anish Adhikari. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [[String: Any]]? = []
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 278
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector (PhotosViewController.didPullToRefresh(_:)),  for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 1)
        
        
        loadPhotos()
        

        // Do any additional setup after loading the view.
    }

    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        loadPhotos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPhotos() {
        // Network request snippet
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as? [[String: Any]]
                
                
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
//                print(self.posts)
                
                // TODO: Get the posts and store in posts property
                
                // TODO: Reload the table view
            }
        }
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let post = self.posts {
            return post.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell

        let post = posts![indexPath.row]
        if let photos = post["photos"] as? [[String: Any]] {
            // photos is NOT nil, we can use it!
            // TODO: Get the photo url
            let photo = photos[0]
            // 2.
            let originalSize = photo["original_size"] as! [String: Any]
            // 3.
            let urlString = originalSize["url"] as! String
            // 4.
            if let imageUrl = URL(string: urlString) {
                cell.photoImageView.af_setImage(withURL: imageUrl)
            } else {
                print("ImageURLString not found")
            }
        }
        
        return cell
    }

}
