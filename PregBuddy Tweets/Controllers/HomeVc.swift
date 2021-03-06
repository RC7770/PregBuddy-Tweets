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

    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    
    // MARK :-
    // MARK: - Variables
    let keyword = "pregnancy"
    var tweets: [TWTRTweet] = []
    var tweetsRecent: [TWTRTweet] = []
    var tweetsLiked: [TWTRTweet] = []
    var tweetsRetweets: [TWTRTweet] = []

    var prototypeCell: HomeTweetCell?
    let tweetTableCellReuseIdentifier = "HomeTweetCell"
    var isLoadingTweets = false
    var recentTweetAlertShowd = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    enum TweetTypes {
        case recent
        case liked
        case reTweets
    }
    lazy var bookMarkedTweets:[String] = {
        return [String]()
    }()
    
    
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
        switch currentSelected {
        case .recent:
            loadRecentTweets(with: "")
            break
        case .liked:
            loadTop10LikedTweets()
            break
        case .reTweets:
            loadTop10ReTweets()
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK :-
    // MARK: - Helper Methods
    
    fileprivate func setUp() {
        tblHomeTweets.tableFooterView = UIView.init(frame: CGRect.zero)        
        btnRecent.layer.cornerRadius = 10;
        btnTopRetweets.layer.cornerRadius = 10;
        btnTopLiked.layer.cornerRadius = 10;
        if (UserDefaults.standard.value(forKey: UserDefaults.Keys.bookmark) != nil) {
            bookMarkedTweets = UserDefaults.standard.value(forKey: UserDefaults.Keys.bookmark) as! [String]
        }else{
            bookMarkedTweets = []
            UserDefaults.standard.set(bookMarkedTweets, forKey: UserDefaults.Keys.bookmark)
        }
        UserDefaults.standard.synchronize()

    }
    fileprivate func selctedButtonsAction(btnSelected:UIButton,first:UIButton,second:UIButton){
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
            tweets = tweetsRecent;
            selctedButtonsAction(btnSelected: sender, first: btnTopLiked, second: btnTopRetweets)
            tweets.removeAll()
            tweetsRecent.removeAll()
            loadRecentTweets(with: "")
            
        }else if sender == btnTopLiked{
            currentSelected = .liked
            tweets = tweetsLiked;
            selctedButtonsAction(btnSelected: sender, first: btnRecent, second: btnTopRetweets)
            loadTop10LikedTweets()
            
        }else if sender == btnTopRetweets{
            currentSelected = .reTweets
            tweets = tweetsRetweets;
            selctedButtonsAction(btnSelected: sender, first: btnRecent, second: btnTopLiked)
            loadTop10ReTweets()
        }
        tblHomeTweets.reloadData()
    }
    
    @objc func btnBookmarkClicked(_ sender: UIButton){
        let tag = sender.tag
        let tweet = self.tweets[tag]
        if sender.isSelected {
            // unBook
            let newRecords = bookMarkedTweets.filter({
                $0 != tweet.tweetID
            })
            bookMarkedTweets = newRecords
            
            let newBook = appDelegate.bookmarkTweets.filter({
                $0 != tweet
            })
            appDelegate.bookmarkTweets = newBook
            sender.isSelected = false
        }else{
            //book
            if !bookMarkedTweets.contains(tweet.tweetID){
                appDelegate.bookmarkTweets.append(tweet)
                bookMarkedTweets.append(tweet.tweetID)
            }
            sender.isSelected = true
        }
        UserDefaults.standard.set(bookMarkedTweets, forKey: UserDefaults.Keys.bookmark)
        UserDefaults.standard.synchronize()

    }
    
    // MARK :-
    // MARK: - Load Tweets
    
    fileprivate func loadRecentTweets(with strSince:String){
        if self.tweets.count >= 100 {
            if !recentTweetAlertShowd{
                self.showAlert(withTitle: "Alert!", andMessage: "Recent 100 Tweets loaded");
                recentTweetAlertShowd = true
            }
           
            return;
        }
        var params = ["q":keyword,"result_type": "recent","count":"20"]
        
        if strSince != "" {
            params = ["q":keyword,"result_type": "recent","count":"20","max_id":strSince]
        }
        self.loadTweets(with: params, toAdd: tweetsRecent, selected: currentSelected)
    }
    fileprivate func loadTop10LikedTweets(){
        self.tweetsLiked.removeAll()
        let params = ["q":keyword,"result_type": "popular","count":"50"]
        self.loadTweets(with: params, toAdd: tweetsLiked, selected: currentSelected)


    }
    fileprivate func loadTop10ReTweets(){
        self.tweetsRetweets.removeAll()
        let params = ["q":keyword,"result_type": "mixed","count":"50"]
        self.loadTweets(with: params, toAdd: tweetsLiked, selected: currentSelected)
    }
    
    fileprivate func loadTweets(with params:[String:String],toAdd arrTweets:[TWTRTweet],selected:TweetTypes){
        loader.startAnimating()
        var arrTweets = arrTweets
        let client = TWTRAPIClient()
        ///search/tweets.json
        let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json"
        var clientError : NSError?
        let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            self.isLoadingTweets = false
            if connectionError != nil {
                print("Error: \(String(describing: connectionError))")
            }
            do {
                if data == nil{
                    DispatchQueue.main.async {
                        self.loader.stopAnimating()
                    }
                    self.showAlert(withTitle: "Error!", andMessage: "Please try again or check your interner connection")
                    return;
                }
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                let me = json!["statuses"] as? [[AnyHashable:Any]]
                let oldIds :[String] = arrTweets.flatMap({$0.tweetID})
                for obj : [AnyHashable:Any] in me! {
                    let i = TWTRTweet(jsonDictionary: obj)
                    if !oldIds.contains((i?.tweetID)!) {
                        arrTweets.append(i!)
                    }else{
                        print("")
                    }
                }
                switch selected {
                case .recent:
                    self.tweets = arrTweets
                    self.tweetsRecent = arrTweets
                    break
                case .liked:
                    arrTweets.sort(by: { (t0, t1) -> Bool in
                        t0.likeCount > t1.likeCount
                    })
                    for twee in arrTweets{
                        if self.tweetsLiked.count < 10{
                            self.tweetsLiked.append(twee)
                        }else{break}
                    }
                    self.tweets = self.tweetsLiked
                    break
                case .reTweets:
                    arrTweets.sort(by: { (t0, t1) -> Bool in
                        t0.retweetCount > t1.retweetCount
                    })
                    let allIds :[String] = arrTweets.flatMap({$0.tweetID})
                    let unique = Array(Set(allIds))
                    let uniqueReTweets =  arrTweets.filter({
                        unique.contains($0.tweetID)
                    })
                    for twee in uniqueReTweets{
                        if self.tweetsRetweets.count < 10{
                            self.tweetsRetweets.append(twee)
                        }else{break}
                    }
                    self.tweets = self.tweetsRetweets
                    break
                }
                DispatchQueue.main.async {
                    self.loader.stopAnimating()
                    self.tblHomeTweets.reloadData()
                }
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
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

extension HomeVc :UITableViewDelegate,UITableViewDataSource{
    
    // MARK :-
    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve the Tweet cell.
        if currentSelected == .recent {
            if indexPath.row == tweets.count - 2{
                let t = tweets.last
                loadRecentTweets(with: (t?.tweetID)!)
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableCellReuseIdentifier, for: indexPath) as! HomeTweetCell
        
        // Assign the delegate to control events on Tweets.
        cell.tweetView.delegate = self
        
        // Retrieve the Tweet model from loaded Tweets.
        let tweet = tweets[indexPath.row]
        
        // Configure the cell with the Tweet.
        cell.configure(with: tweet)
        cell.btnBookMark.superview?.bringSubview(toFront: cell.btnBookMark)
        cell.btnBookMark.tag = indexPath.row
        cell.btnBookMark.addTarget(self, action: #selector(btnBookmarkClicked(_:)), for: .touchUpInside)

        if bookMarkedTweets.contains(tweet.tweetID) {
            cell.btnBookMark.isSelected = true
        }else{
            cell.btnBookMark.isSelected = false
        }
        
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


extension UIViewController{
    func showAlert(withTitle title:String, andMessage msg : String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }

    
}
