//
//  BookmarkVc.swift
//  PregBuddy Tweets
//
//  Created by Rahul Chandnani on 09/03/18.
//  Copyright © 2018 Rahul Chandnani. All rights reserved.
//

import UIKit
import TwitterKit

class BookmarkVc: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var tblBookmark: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!

    // MARK :-
    // MARK: - Variables
    
    var tweets: [TWTRTweet] = []
    var prototypeCell: TWTRTweetTableViewCell?
    let tweetTableCellReuseIdentifier = "bookmarkCell"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    // MARK :-
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblBookmark.tableFooterView = UIView.init(frame: CGRect.zero)
        self.prototypeCell = TWTRTweetTableViewCell(style: .default, reuseIdentifier: tweetTableCellReuseIdentifier)
        
        // Register the identifier for TWTRTweetTableViewCell.
        self.tblBookmark.register(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableCellReuseIdentifier)
        loadSavedTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tweets = appDelegate.bookmarkTweets
        tweets = tweets.reversed()
        tblBookmark.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadSavedTweets(){
        // set tweetIds to find
        if (UserDefaults.standard.value(forKey: UserDefaults.Keys.bookmark) != nil) {
            let  tweetIDs = UserDefaults.standard.value(forKey: UserDefaults.Keys.bookmark) as! [String]
            loader.startAnimating()
            let client = TWTRAPIClient()
            
            // Find the tweets with the tweetIDs
            client.loadTweets(withIDs: tweetIDs) { (twttrs, error) -> Void in
                
                // If there are tweets do something magical
                if ((twttrs) != nil) {
                    
                    // Loop through tweets and do something
                    for i in twttrs! {
                        // Append the Tweet to the Tweets to display in the table view.
                        self.appDelegate.bookmarkTweets.append(i as TWTRTweet)
                    }
                    self.tweets = self.appDelegate.bookmarkTweets
                    self.tweets = self.tweets.reversed()

                    DispatchQueue.main.async {
                        self.loader.stopAnimating()
                        self.tblBookmark.reloadData()
                    }
                } else {
                    print(error as Any)
                }
            }
        }
        }
        

}

extension BookmarkVc : UITableViewDelegate,UITableViewDataSource{
    
    // MARK :-
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve the Tweet cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableCellReuseIdentifier, for: indexPath) as! TWTRTweetTableViewCell
        
        // Assign the delegate to control events on Tweets.
        cell.tweetView.delegate = self
        
        // Retrieve the Tweet model from loaded Tweets.
        let tweet = tweets[indexPath.row]
        
        // Configure the cell with the Tweet.
        cell.configure(with: tweet)
        
        return cell
    }
    // MARK :-
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tweet = self.tweets[indexPath.row]
        self.prototypeCell?.configure(with: tweet)
        
        return TWTRTweetTableViewCell.height(for: tweet, style: TWTRTweetViewStyle.compact, width: self.view.bounds.width, showingActions: false)
    }
    
    
}
extension BookmarkVc: TWTRTweetViewDelegate{
    // MARK: TWTRTweetViewDelegate
    func tweetView(_ tweetView: TWTRTweetView!, didSelect tweet: TWTRTweet!) {
        // Display a Web View when selecting the Tweet.
        let webViewController = UIViewController()
        let webView = UIWebView(frame: webViewController.view.bounds)
        webView.loadRequest(URLRequest(url: tweet.permalink))
        webViewController.view = webView
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
}

