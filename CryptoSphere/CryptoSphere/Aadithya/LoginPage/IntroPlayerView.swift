//
//  IntroPlayerView.swift
//  CS_LoginPage
//
//  Created by Aadithya K S on 16/02/25.
//
//A custom UIView that plays a video using AVPlayer

import AVKit

class IntroPlayerView: UIView {
    var player : AVPlayer?  //video player
    var playerLayer = AVPlayerLayer()  //player that displays the video
    
    //MARK: Initializing the View
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //MARK: -Setting up the player
        
        guard let introURL = URL(string: "https://github.com/Aadithya-Git/Demo/raw/refs/heads/main/IntroAnimationFC.mov") else { return }
        //introURL points to an online video file
        
        player = AVPlayer(url: introURL)  //loads the video
        player?.isMuted = true
        
        //MARK: -Adding the player layer
        
        playerLayer.player = player //initializing the playerLayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        player?.play()
    }
    
    //MARK: -Adjusting the Layout
    
    override func layoutSubviews() {  //ensures the video fills the entire view
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
