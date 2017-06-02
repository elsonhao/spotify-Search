//
//  ViewController.swift
//  spot
//
//  Created by 黃毓皓 on 2017/5/16.
//  Copyright © 2017年 ice elson. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import GoogleMobileAds

//不同的viewController也可以呼叫這個player
var player = AVAudioPlayer()


class TableViewController: UITableViewController , UISearchBarDelegate,GADBannerViewDelegate{
    
    lazy var adBannerView:GADBannerView = {
       let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-2285514931101689/9277270259"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        return adBannerView
    }()
    
    var searchURL = String()
    
    @IBOutlet weak var searchBar: UISearchBar!
  
    struct Post {
        var imageData:UIImage!
        var title:String!
        var MyPreviewURL:String!
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        Posts = []
        tableView.reloadData()
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keywords = searchBar.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with:"+")
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&type=track"
        callAlmo(url: searchURL)
        self.view.endEditing(true)
        
        //查詢完將post陣列清空
        Posts = []
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }

    
    
    typealias JsonStandard = [String:AnyObject]
    
    
    var Posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        adBannerView.load(GADRequest())
    }
    
    func callAlmo(url:String){
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer BQDPhuaAhr13Tn-UNX3tNeyo7yzDSJjo2gdCGxMOCijnmy5CjiHjTsOlaLVRSdCxytvCDZaeqatjKtPlW2xZ_B0FDw-PHhzRUfMKIV5JwHQeyeWKpJLq9fB4drbnOUHF4EsSQnOLpSmgeQb6tZlyxSJxXk2BeA8tEKNDDd7ycgujjz9jLx6xAP3i0nYoXBDbtvEasc_ldfU3",
            "Accept": "application/json"
        ]
        
        Alamofire.request(url, headers: headers).responseJSON { response in
            self.parseData(jsonData: response.data!)
        }
        
    }
//    func callAlmo(url:String){
//        
//        Alamofire.request(url).responseJSON { (response) in
//            self.parseData(jsonData: response.data!)
//        }
//        
//    }
    
    //在tableView header 設定廣告
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("ad load successfully")
        tableView.tableFooterView?.frame = bannerView.frame
        tableView.tableFooterView = bannerView
    }
    
    func parseData(jsonData:Data){
        do {
          let readableJson =  try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? JsonStandard
            if let tracks =  readableJson?["tracks"] as? [String:Any]{
                if let itemArray =  tracks["items"] as? [[String:Any]]  {
                    for itemInfo in itemArray{
                     let name =  itemInfo["name"] as! String
                        let previewURL = itemInfo["preview_url"] as? String ?? ""
                        
                        
                    
                        if  let album = itemInfo["album"] as? JsonStandard {
                            if let albumArray =  album["images"] as? [JsonStandard]{
                                if let albumArrayUrl =   albumArray[0]["url"] as? String{
                                    let url = URL(string: albumArrayUrl)
                                    DispatchQueue.global().async {
                                    do{
                                        
                                        let imageData =  try Data(contentsOf: url!)
                                        let mainImage = UIImage(data: imageData)
                                        
                                        let post = Post(imageData: mainImage, title: name, MyPreviewURL: previewURL)
                                        
                                        self.Posts.append(post)
                                        DispatchQueue.main.async {
                                             self.tableView.reloadData()
                                        }
                                       
                                    }
                                    catch{
                                        
                                    }
                                    }
                                }
                            }
                        }
    
                   
                    }
                }
            }
        } catch  {
            
        }
    }
 
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let mainImageView = cell.viewWithTag(2) as! UIImageView
        
        mainImageView.image = Posts[indexPath.row].imageData
        let mainLabel  = cell.viewWithTag(1) as! UILabel
        mainLabel.text = Posts[indexPath.row].title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return Posts.count
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let Nowindexpath = tableView.indexPathForSelectedRow?.row
        
        let vc = segue.destination as! AudioVC
        vc.thisUIImage = Posts[Nowindexpath!].imageData
        vc.mainSongTitle = Posts[Nowindexpath!].title
        vc.mainPreviewURL = Posts[Nowindexpath!].MyPreviewURL
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

