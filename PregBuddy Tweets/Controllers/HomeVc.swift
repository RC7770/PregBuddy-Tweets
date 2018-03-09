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

    var tweets: [TWTRTweet] = [] {
        didSet {
            tblHomeTweets.reloadData()
        }
    }
    
    var prototypeCell: HomeTweetCell?
    let tweetTableCellReuseIdentifier = "HomeTweetCell"
    var isLoadingTweets = false
    
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
           selctedButtonsAction(btnSelected: sender, first: btnTopLiked, second: btnTopRetweets)
        }else if sender == btnTopLiked{
            selctedButtonsAction(btnSelected: sender, first: btnRecent, second: btnTopRetweets)
            
        }else if sender == btnTopRetweets{
            selctedButtonsAction(btnSelected: sender, first: btnRecent, second: btnTopLiked)
        }
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
