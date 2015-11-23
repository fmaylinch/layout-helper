
import UIKit

public class ViewUtil {
    
    public static let SizeAuto: CGFloat = -1
    
    public static let DefaultTextColor = ViewUtil.color(red: 90, green: 90, blue: 90, alpha: 1)
    public static let MainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)

    public class func color(red red:Int, green:Int, blue:Int, alpha:Float) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha))
    }
    
    public class func labelWithSize(size: Float) -> UILabel {
        return labelWithSize(size, color: DefaultTextColor)
    }

    public class func labelWithSize(size: Float, color: UIColor) -> UILabel {
        return labelWithFont(fontMainWithSize(size), color: color)
    }

    public class func labelAwesome(text: String, size: Float, color: UIColor) -> UILabel {
        let label = labelWithFont(fontAwesomeWithSize(size), color: color)
        label.text = text
        return label
    }

    public class func labelWithFont(font: UIFont, color: UIColor) -> UILabel {
        
        let label = UILabel()
        label.textColor = color
        // label.adjustsFontSizeToFitFrame = font.pointSize == SizeAuto
        
        if font.pointSize == SizeAuto {
            label.font = UIFont(name: font.familyName, size: 20)
        } else {
            label.font = font
        }

        return label
    }
    
    public class func fontMainWithSize(size: Float) -> UIFont {
        return font("ShareTech-Regular", size: size)
    }

    public class func fontSecondWithSize(size: Float) -> UIFont {
        return font("OpenSans-Light", size: size)
    }

    public class func fontAwesomeWithSize(size: Float) -> UIFont {
        return font("FontAwesome", size: size)
    }
    
    private class func font(name: String, size: Float) -> UIFont {
        if let font = UIFont(name: name, size: CGFloat(size)) {
            return font
        } else {
            fatalError("Could not load font `\(name)`")
        }
    }
}
