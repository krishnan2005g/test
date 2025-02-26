import UIKit

class Fonts{
    
    static let zohoPuviMediumFont = UIFont(name: "ZohoPuvi-Medium", size: 20)
    static let zohoPuviBoldFont = UIFont(name: "ZohoPuvi-Bold", size: 20)
    
    static func getPuviFont(_ type:String, _ size:Int = 20) -> UIFont {
        return UIFont(name: "ZohoPuvi-\(type.capitalized)", size: CGFloat(size))
            ?? .boldSystemFont(ofSize: CGFloat(size))
    }

}

extension UIColor{
    static let greyBackgroundDarkMode = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1.0) //rgb(30, 30, 30)
    static let greyButtonDarkMode = UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1.0) //rgb(54, 54, 54)
    
}
