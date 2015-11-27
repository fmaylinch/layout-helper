
import UIKit

/**
 * UILabel with extra features like adjustsFontSizeToFitFrame and insets
 *
 * Take care with adjustsFontSizeToFitFrame because it's not perfect.
 * Different characters have different heights (like 'p' or 'd') and they sometimes
 * end up outside the frame if you don't leave some padding (you can use insets or
 * put the label inside a view with some margin).
 */
public class CustomLabel: UILabel {
    
    /** If set to YES:
     * - The font size is adjusted (up or down) to fit the frame.
     * - The frame size must be decided (either explicitly or with constraints).
     * - numberOfLines is set to 0 because the number of lines can't be specified.
     */
    public var adjustsFontSizeToFitFrame = false {
        didSet {
            if adjustsFontSizeToFitFrame {
                numberOfLines = 0
            }
        }
    }
    
    // Overrides default insets (padding)
    public var insets: UIEdgeInsets
    
    // To avoid recursion, because adjustFontSizeToFrame will trigger layoutSubviews again
    private var fontSizeAdjusted = false
    
    override init(frame: CGRect) {
        insets = UIEdgeInsetsZero
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if adjustsFontSizeToFitFrame && !fontSizeAdjusted {
            fontSizeAdjusted = true
            CustomLabel.adjustFontSizeToFrame(self, insets:insets)
        }
    }

    private static let DELTA: CGFloat = 0.5

    /**
     * Adjusts font size so it fits inside the label frame
     * Based on http://stackoverflow.com/a/3005113
     */
    public class func adjustFontSizeToFrame(label: UILabel) {
        adjustFontSizeToFrame(label, insets: UIEdgeInsetsZero)
    }

    /**
     * Adjusts font size so it fits inside the label frame, minus insets
     * Based on http://stackoverflow.com/a/3005113
     */
    public class func adjustFontSizeToFrame(label: UILabel, insets: UIEdgeInsets) {
        
        guard let text = label.text where text.characters.count > 0 else {
            print("No font adjustment is needed for label with no text")
            return
        }
        
        let singleChar: Bool = text.characters.count == 1
        
        // Find available size
        let labelSize: CGSize = label.frame.size
        let availableSize = CGSize(
            width: labelSize.width - insets.left - insets.right - label.layer.borderWidth * 2,
            height: labelSize.height - insets.top - insets.bottom - label.layer.borderWidth * 2)
        
        print("Adjusting label with text: \(text)")
        print("Label size     : \(NSStringFromCGSize(labelSize))")
        print("Available size : \(NSStringFromCGSize(availableSize))")
        
        // Fit label width-wise (but no constraint for singleChar)
        let constraintSize: CGSize = CGSizeMake(singleChar ? CGFloat.max : availableSize.width, CGFloat.max)
        
        // Look for best font size from largest to smallest
        var maxFontSize: CGFloat = 300
        var minFontSize: CGFloat = 5
        var font: UIFont = label.font
        
        while true
        {
            // Binary search between min and max
            let fontSize: CGFloat = (maxFontSize + minFontSize) / 2
            
            // Exit if approached minFontSize enough
            if fontSize - minFontSize < DELTA / 2 {
                font = UIFont(name: font.fontName, size: minFontSize)!
                // Exit because we reached the biggest font size that fits
                break
            }
            else {
                font = UIFont(name: font.fontName, size: fontSize)!
            }
            
            // Find label size for current font size
            let currentSize: CGSize = text.boundingRectWithSize(constraintSize,
                options: [.UsesDeviceMetrics, .UsesLineFragmentOrigin], // Not sure about which NSStringDrawingOptions to use...
                attributes: [NSFontAttributeName: font],
                context: nil).size
            
            // Now we discard a half
            // Sometimes it is necessary to check width too (for singleChar texts, because we don't constraint width)
            if currentSize.height <= availableSize.height && (!singleChar || currentSize.width <= availableSize.width) {
                minFontSize = fontSize
                // the best size is in the bigger half
                print("  Current size \(fontSize) too small : \(NSStringFromCGSize(currentSize))")
            }
            else {
                maxFontSize = fontSize
                // the best size is in the smaller half
                print("  Current size \(fontSize) too big   : \(NSStringFromCGSize(currentSize))")
            }
        }
        
        label.font = font
    }
}