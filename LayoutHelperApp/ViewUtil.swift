
import UIKit

class ViewUtil {
    
    /** Use this special size to enable adjustsFontSizeToFitFrame. */
    static let SizeAuto: Float = 1
    
    static let DefaultFontName = "ShareTech-Regular"
    static let SecondFont = "OpenSans-Light"
    
    // stylish black ;)
    static let SpaceBlack = ViewUtil.color(red: 40, green: 40, blue: 40, alpha: 1)
    static let DefaultTextColor = SpaceBlack
    static let DarkGreyColor = ViewUtil.color(red: 90, green: 90, blue: 90, alpha: 1)
    static let GrayColor = ViewUtil.color(red: 180, green: 180, blue: 180, alpha: 1)
    static let MainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)
    static let MainDarkColor = ViewUtil.color(red:205, green:90, blue:97, alpha: 1)
    
    // Color
    
    class func color(red red:UInt, green:UInt, blue:UInt, alpha:Float) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha))
    }
    
    /** Color in alpha/red/green/blue, similar to Android. Black would be 0xff000000. */
    class func color(argb argb: UInt) -> UIColor {
        // inspired from http://stackoverflow.com/a/24074509/1121497
        return ViewUtil.color(
            red:   (argb & 0x00FF0000) >> 16,
            green: (argb & 0x0000FF00) >> 8,
            blue:  (argb & 0x000000FF),
            alpha: Float((argb & 0xFF000000) >> 24) / 255.0)
    }
    
    // Label
    
    /** Creates label with DefaultFontName and DefaultTextColor */
    class func labelWithSize(size: Float) -> CustomLabel {
        return labelWithSize(size, color: DefaultTextColor)
    }
    
    /** Creates label using DefaultFontName */
    class func labelWithSize(size: Float, color: UIColor) -> CustomLabel {
        return labelWithFont(fontMainWithSize(size), color: color)
    }
    
    /**
     * Creates label using FontAwesome.
     * Text should include font awesome symbols like '\u{f00c}'.
     * See: http://fortawesome.github.io/Font-Awesome/cheatsheet
     */
    class func labelAwesome(text: String, size: Float, color: UIColor) -> CustomLabel {
        let label = labelWithFont(fontAwesomeWithSize(size), color: color)
        label.text = text
        return label
    }
    
    /** Creates a label with given font and color */
    class func labelWithFont(font: UIFont, color: UIColor) -> CustomLabel {
        
        let label = CustomLabel()
        label.textColor = color
        label.adjustsFontSizeToFitFrame = font.pointSize == CGFloat(SizeAuto)
        label.font = font
        
        return label
    }
    
    // Button
    
    /** Creates button with default colors and font */
    class func buttonWithSize(size: Float) -> CustomButton {
        
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
    
    class func pickerField(placeholder:String, size: Float, values:[String!], toolbar:UIToolbar) -> CustomDropDown
    {
        let field = CustomDropDown()
        field.placeholder = placeholder
        field.textColor = DefaultTextColor
        field.backgroundColor = UIColor.whiteColor()
        field.layer.borderColor = ViewUtil.GrayColor.CGColor
        field.layer.borderWidth = 1.0
        field.layer.cornerRadius = 5
        field.font = ViewUtil.fontMainWithSize(size)
        
        let pad : CGFloat = CGFloat(size) / 4 // relative padding to font size
        field.padding = UIEdgeInsets(top: pad, left: pad*2, bottom: pad, right: 0)
        
        field.optionalItemText = placeholder
        field.isOptionalDropDown = true
        field.itemList = values
        field.inputAccessoryView = toolbar
        
        return field
    }
    
    class func pickerToolbar(target: AnyObject, doneAction: Selector) -> UIToolbar
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
    
    class func fontMainWithSize(size: Float) -> UIFont {
        return font(DefaultFontName, size: size)
    }
    
    class func fontSecondWithSize(size: Float) -> UIFont {
        return font(SecondFont, size: size)
    }
    
    class func fontAwesomeWithSize(size: Float) -> UIFont {
        return font("FontAwesome", size: size)
    }
    
    private class func font(name: String, size: Float) -> UIFont {
        if let font = UIFont(name: name, size: CGFloat(size)) {
            return font
        } else {
            fatalError("Could not load font `\(name)`")
        }
    }
    
    // Screen
    
    class func screenSize() -> CGSize {
        return UIScreen.mainScreen().bounds.size
    }
}
