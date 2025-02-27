//
//  IntroPlayerWrapper.swift
//  CS_LoginPage
//
//  Created by Aadithya K S on 16/02/25.
//
//Acts as a wrapper for IntroPlayerView

//This file bridges UIKit(IntroPlayerView (AVKit)) with SwiftUI, allowing you to use IntroPlayerView inside a SwiftUI view.

import SwiftUI

struct IntroPlayerWrapper: UIViewRepresentable {
    //UIViewRepresentable: protocol that embeds UIKit views inside SwiftUI
    
    func makeUIView(context: Context) -> IntroPlayerView {
        let playerView = IntroPlayerView()
        return playerView
    }//It creates an instance of IntroPlayerView and blend it with SwiftUI View

    func updateUIView(_ uiView: IntroPlayerView, context: Context) { }
    //This method is called whenever SwiftUI updates the view
    
}

#Preview {
    IntroPlayerWrapper()
}
