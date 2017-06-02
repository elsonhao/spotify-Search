//
//  AudioVCViewController.swift
//  spot
//
//  Created by 黃毓皓 on 2017/5/18.
//  Copyright © 2017年 ice elson. All rights reserved.
//

import UIKit
import AVFoundation

class AudioVC: UIViewController {
    
    var thisUIImage = UIImage()
    var mainSongTitle = String()
    var mainPreviewURL = String()
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseButton.isHidden = true
        mainImageView.image = thisUIImage
        songTitle.text = mainSongTitle
        background.image = thisUIImage
        
        
        if mainPreviewURL != "" {
            pauseButton.setTitle("Pause", for: .normal)
            downloadFileFromUrl(url: URL(string: mainPreviewURL)!)
        }else{
            pauseButton.isHidden = false
            pauseButton.isEnabled = false
            pauseButton.setTitle("此曲無試聽", for: .normal)
        }
        
        
        
       
        
        // Do any additional setup after loading the view.
    }

    func downloadFileFromUrl(url:URL){
        let task = URLSession.shared.downloadTask(with: url) { (getUrl, response, error) in
            if error != nil{
                print(error?.localizedDescription)
            }
            self.play(url: getUrl!)
            
        }
        task.resume()
    }
    
    func play(url:URL){
        do{
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            DispatchQueue.main.async {
               self.pauseButton.isHidden = false 
            }
            
        }
        catch{
            print(error)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         player.pause()
    }
    
    @IBAction func pauseButton(_ sender: UIButton) {
        if player.isPlaying{
          player.pause()
            pauseButton.setTitle("play", for: .normal)
        }else{
            if mainPreviewURL != "" {
                player.play()
                pauseButton.setTitle("Pause", for: .normal)
            }
        }
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
