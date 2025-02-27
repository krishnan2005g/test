//
//  CustomCorner.swift
//  CS_LoginPage
//
//  Created by Aadithya K S on 16/02/25.
//
//Defines a custom corner radius shape in SwiftUI

import SwiftUI

struct CustomCorner: Shape {
    //creates a custom shape
    
    var corners : UIRectCorner  //determines which corner
    var radius : CGFloat
    
    func path(in rect: CGRect) -> Path {  //required method for Shape protocol
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        return Path(path.cgPath)  //converts UIBezierPath to Path which SwiftUI understands
    }
}
