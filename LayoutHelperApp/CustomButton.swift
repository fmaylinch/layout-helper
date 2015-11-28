
/** UIButton with extra features like background color for highlighted states */

import UIKit

public class CustomButton : UIButton {
    
    // convenience to set button.title = "xxx"
    public var title : String? {
        get {
            return titleForState(.Normal)
        }
        set {
            self.setTitle(newValue, forState: .Normal)
        }
    }
    
    public var backgroundColorWhenHighlighted : UIColor?
    public var backgroundColorWhenNotHighlighted : UIColor? {
        didSet {
            backgroundColor = backgroundColorWhenNotHighlighted
        }
    }

    // Changes background color - http://stackoverflow.com/a/29186375/1121497
    override public var highlighted : Bool {
        didSet {
            if highlighted {
                backgroundColor = backgroundColorWhenHighlighted
            } else {
                backgroundColor = backgroundColorWhenNotHighlighted
            }
        }
    }
    
    // Fix in case you set titleEdgeInsets - http://stackoverflow.com/a/17806333/1121497
    override public func intrinsicContentSize() -> CGSize {
        
        let s = super.intrinsicContentSize()
        
        return CGSize(
            width: s.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
            height: s.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom)
    }
}