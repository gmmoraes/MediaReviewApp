//
//  PlayerViewController.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 30/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit
import YouTubePlayer

class PlayerViewController:UIViewController{
    
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    private var videoPlayer: YouTubePlayerView!
    var videoID:String = ""
    private var currentPlayerState: YouTubePlayerState? {
        didSet {
            if let oldValue = oldValue, oldValue == .Buffering, let currentPlayerState = currentPlayerState, currentPlayerState == .Unstarted {
                loadingWheel.stopAnimating()
                showAlert()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        videoID = "nfWlot6h_JM"
        videoPlayer = YouTubePlayerView(frame: self.view.frame)
        configureConstraints()
        videoPlayer.loadVideoID(videoID)
        videoPlayer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingWheel.startAnimating()
    }
    
    private func configureConstraints() {
        videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(videoPlayer)
        videoPlayer.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        videoPlayer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        videoPlayer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        videoPlayer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Error", message: "There was a problem with your video, please try again.", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Return", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

extension PlayerViewController:YouTubePlayerDelegate{
    
    func playerReady(_ videoPlayer: YouTubePlayerView){
        if videoPlayer.ready {
            loadingWheel.stopAnimating()
            videoPlayer.play()
        }
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
         currentPlayerState = playerState
    }
    
}
