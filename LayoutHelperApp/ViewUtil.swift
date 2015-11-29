
import UIKit

public class ViewUtil {
    
    /** Use this special size to enable adjustsFontSizeToFitFrame. */
    public static let SizeAuto: Float = 1
    
    public static let DefaultFontName = "ShareTech-Regular"
    public static let SecondFont = "OpenSans-Light"
    
    public static let DefaultTextColor = ViewUtil.color(red: 90, green: 90, blue: 90, alpha: 1)
    public static let GrayColor = ViewUtil.color(red: 180, green: 180, blue: 180, alpha: 1)
    public static let MainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)
    public static let MainDarkColor = ViewUtil.color(red:205, green:90, blue:97, alpha: 1)

    // Color
    
    public class func color(red red:Int, green:Int, blue:Int, alpha:Float) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha))
    }
    
    public class func colorRgb(rgb: UInt) -> UIColor {
        return colorRgba(rgb | 0xFF000000)
    }
    
    public class func colorRgba(rgba: UInt) -> UIColor {
        // inspired from http://stackoverflow.com/a/24074509/1121497
        return UIColor(
            red:   CGFloat((rgba & 0x00FF0000) >> 16) / 255.0,
            green: CGFloat((rgba & 0x0000FF00) >> 8)  / 255.0,
            blue:  CGFloat( rgba & 0x000000FF)        / 255.0,
            alpha: CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        )
    }
    
    // Label
    
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
    
    // Button
    
    /** Creates button with default colors and font */
    public class func buttonWithSize(size: Float) -> CustomButton {
        
        let button = CustomButton()
        button.titleLabel?.font = ViewUtil.fontMainWithSize(size)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColorWhenNotHighlighted = MainColor
        button.backgroundColorWhenHighlighted = MainDarkColor
        button.layer.cornerRadius = 5
        let pad : CGFloat = CGFloat(size) / 3 // relative padding to font size
        button.contentEdgeInsets = UIEdgeInsets(top: pad, left: pad*2, bottom: pad, right: pad*2)
        return button
    }
   
    // Picker
        
    public class func pickerField(placeholder:String, size: Float, values:[String!], toolbar:UIToolbar) -> IQDropDownTextField
    {
        let field = IQDropDownTextField()
        field.placeholder = placeholder
        field.textColor = DefaultTextColor
        field.backgroundColor = UIColor.whiteColor()
        field.layer.borderColor = ViewUtil.GrayColor.CGColor
        field.layer.borderWidth = 1.0
        field.layer.cornerRadius = 5
        field.borderStyle = UITextBorderStyle.RoundedRect
        field.font = ViewUtil.fontMainWithSize(size)
        
        field.optionalItemText = placeholder
        field.isOptionalDropDown = true
        field.itemList = values
        field.inputAccessoryView = toolbar
        
        return field
    }
    
    public class func pickerToolbar(target: AnyObject, doneAction: Selector) -> UIToolbar
    {
        let toolbar = UIToolbar()
        // toolbar.barStyle = .Default
        toolbar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .Done, target: target, action: doneAction)
        toolbar.items = [space, done]
        return toolbar
    }
    
    // Font
    
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
