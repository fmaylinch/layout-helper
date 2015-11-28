
import UIKit

public class ViewUtil {
    
    /** Use this special size to enable adjustsFontSizeToFitFrame */
    public static let SizeAuto: Float = 10000
    
    public static let DefaultFontName = "ShareTech-Regular"
    public static let SecondFont = "OpenSans-Light"
    public static let DefaultTextColor = ViewUtil.color(red: 90, green: 90, blue: 90, alpha: 1)
    public static let MainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)

    public class func color(red red:Int, green:Int, blue:Int, alpha:Float) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha))
    }
    
    /** Creates label with DefaultFontName and DefaultTextColor */
    public class func labelWithSize(size: Float) -> CustomLabel {
        return labelWithSize(size, color: DefaultTextColor)
    }

    /** Creates label using DefaultFontName */
    public class func labelWithSize(size: Float, color: UIColor) -> CustomLabel {
        return labelWithFont(fontMainWithSize(size), color: color)
    }

    /** 
     * Creates label using FontAwesome.
     * Text should include font awesome symbols like '\u{f00c}'.
     * See: http://fortawesome.github.io/Font-Awesome/cheatsheet
     */
    public class func labelAwesome(text: String, size: Float, color: UIColor) -> CustomLabel {
        let label = labelWithFont(fontAwesomeWithSize(size), color: color)
        label.text = text
        return label
    }

    /** Creates a label with given font and color */
    public class func labelWithFont(font: UIFont, color: UIColor) -> CustomLabel {
        
        let label = CustomLabel()
        label.textColor = color
        label.adjustsFontSizeToFitFrame = font.pointSize == CGFloat(SizeAuto)
        label.font = font

        return label
    }
    
    public class func fontMainWithSize(size: Float) -> UIFont {
        return font(DefaultFontName, size: size)
    }

    public class func fontSecondWithSize(size: Float) -> UIFont {
        return font(SecondFont, size: size)
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
