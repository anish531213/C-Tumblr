//
//  PhotosViewController.swift
//  tumblr
//
//  Created by Anish Adhikari on 1/22/18.
//  Copyright © 2018 Anish Adhikari. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [[String: Any]]? = []
    
    var refreshControl: UIRefreshControl!
    var loadingMoreView: InfiniteScrollActivityView?
    var isLoadingMoreData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 278
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector (PhotosViewController.didPullToRefresh(_:)),  for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 1)
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
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
                let alert = UIAlertController(title: "Cannot Get Photos", message: "The internet connection appears to be offline", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
                    
                    self.loadPhotos()
                    // handle cancel response here. Doing nothing will dismiss the view.
                }
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isLoadingMoreData) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isLoadingMoreData = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreResults()
                // ... Code to load more results ...
            }
        }
    }
    
    func loadMoreResults() {
        let url: String = "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(self.posts!.count)"
        Alamofire.request(url).responseJSON { response in
            // Update flag
            self.isLoadingMoreData = false
            
            // Stop the loading indicator
            
            let data = response.result.value! as! NSDictionary
            let response = data["response"] as! NSDictionary
            let new_posts = response["posts"] as! [[String: Any]]
            self.posts = self.posts!+new_posts
            
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
            //print(self.posts?.count)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let post = self.posts {
//            return post.count
//        }
//        return 0
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell

        let post = posts![indexPath.section]
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let post = self.posts {
            return post.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        profileView.af_setImage(withURL: URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        let publishDateView = UILabel(frame: CGRect(x: 60, y: 15, width:200, height:20))
        publishDateView.adjustsFontSizeToFitWidth = true
        
        let post = posts![section]
        
        let date = Date(timeIntervalSince1970: post["timestamp"] as! TimeInterval)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "ET")
        dateFormatter.dateFormat = "MMM dd, yyyy, HH:mm"
        let strDate = dateFormatter.string(from: date)
        
        publishDateView.text = strDate
        
        headerView.addSubview(publishDateView)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell

        if let indexPath = tableView.indexPath(for: cell) {
            let imagePost = self.posts![indexPath.section]
            let vc = segue.destination as! PhotoDetailsViewController
            let photos = imagePost["photos"] as? [[String: Any]]
            let photo = photos![0]
            // 2.
            let originalSize = photo["original_size"] as! [String: Any]
            // 3.
            let urlString = originalSize["url"] as! String
            vc.imageUrl = urlString
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    }
    
    

}
