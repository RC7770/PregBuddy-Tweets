//
//  HomeVc.swift
//  PregBuddy Tweets
//
//  Created by Rahul Chandnani on 09/03/18.
//  Copyright © 2018 Rahul Chandnani. All rights reserved.
//

import UIKit
import TwitterKit

class HomeVc: UIViewController {
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var btnRecent: UIButton!
    @IBOutlet weak var btnTopLiked: UIButton!
    @IBOutlet weak var btnTopRetweets: UIButton!
    @IBOutlet weak var tblHomeTweets: UITableView!

    
    
    // MARK :-
    // MARK: - Variables

    var tweets: [TWTRTweet] = []
    var tweetsRecent: [TWTRTweet] = []
    var tweetsLiked: [TWTRTweet] = []
    var tweetsRetweets: [TWTRTweet] = []

    var prototypeCell: HomeTweetCell?
    let tweetTableCellReuseIdentifier = "HomeTweetCell"
    var isLoadingTweets = false
    
    enum TweetTypes {
        case recent
        case liked
        case reTweets
    }
    
    var currentSelected :TweetTypes = .recent
    
    // MARK :-
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a single prototype cell for height calculations.

        self.prototypeCell = TWTRTweetTableViewCell(style: .default, reuseIdentifier: tweetTableCellReuseIdentifier) as? HomeTweetCell

        setUp()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Do not trigger another request if one is already in progress.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK :-
    // MARK: - Helper Methods
    
    fileprivate func setUp() {
        btnRecent.layer.cornerRadius = 10;
        btnTopRetweets.layer.cornerRadius = 10;
        btnTopLiked.layer.cornerRadius = 10;
    }
    func selctedButtonsAction(btnSelected:UIButton,first:UIButton,second:UIButton){
        btnSelected.backgroundColor = UIColor.appRedColor()
        btnSelected.tintColor = UIColor.white
        first.backgroundColor = UIColor.white
        first.tintColor = UIColor.appRedColor()
        second.backgroundColor = UIColor.white
        second.tintColor = UIColor.appRedColor()
    }
    
   
    // MARK :-
    // MARK: - Buttons Action
    
    @IBAction func btnActions(_ sender: UIButton) {        
        if sender == btnRecent{
            currentSelected = .recent
           selctedButtonsAction(btnSelected: sender, first: btnTopLiked, second: btnTopRetweets)
        }else if sender == btnTopLiked{
            currentSelected = .liked
            selctedButtonsAction(btnSelected: sender, first: btnRecent, second: btnTopRetweets)
            
        }else if sender == btnTopRetweets{
            currentSelected = .reTweets
            selctedButtonsAction(btnSelected: sender, first: btnRecent, second: btnTopLiked)
        }
    }
    
    @objc func btnBookmarkClicked(_ sender: UIButton){
        if sender.isSelected {
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
    }
    
    // MARK :-
    // MARK: - Load Tweets
    
    func loadRecentTweets(){
        
    }
    

}

extension HomeVc: TWTRTweetViewDelegate{
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

extension HomeVc :UITableViewDelegate,UITableViewDataSource{
    
    // MARK :-
    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve the Tweet cell.
        if indexPath.row == tweets.count - 2{
            let t = tweets.last
           // loadTweets(with: (t?.tweetID)!)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableCellReuseIdentifier, for: indexPath) as! HomeTweetCell
        
        // Assign the delegate to control events on Tweets.
        cell.tweetView.delegate = self
        
        // Retrieve the Tweet model from loaded Tweets.
        let tweet = tweets[indexPath.row]
        
        // Configure the cell with the Tweet.
        cell.configure(with: tweet)
//        cell.btnBookMark.layer.zPosition = 1
        cell.btnBookMark.superview?.bringSubview(toFront: cell.btnBookMark)

        cell.btnBookMark.addTarget(self, action: #selector(btnBookmarkClicked(_:)), for: .touchUpInside)
//        cell.subviews.last!.bringSubview(toFront: cell.btnBookMark)
        // Return the Tweet cell.
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
