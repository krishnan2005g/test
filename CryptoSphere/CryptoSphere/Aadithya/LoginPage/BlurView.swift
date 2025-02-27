//
//  BlurView.swift
//  CS_LoginPage
//
//  Created by Aadithya K S on 16/02/25.
//
//Embeds a UIKit blur effect (UIVisualEffectView) inside SwiftUI

import SwiftUI

struct BlurView: UIViewRepresentable {
    
    var style : UIBlurEffect.Style  //determines the type of blur effect and allows dynamic customization
    
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }  //returns a view with UIBlurEffect which will be displayed in SwiftUI View

    func updateUIView(_ uiView: UIViewType, context: Context) { }

}
