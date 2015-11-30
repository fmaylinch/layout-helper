
/** IQDropDownTextField with some features */

import UIKit

class CustomDropDown: IQDropDownTextField {
    
    var padding = UIEdgeInsetsZero
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return super.textRectForBounds(UIEdgeInsetsInsetRect(bounds, padding))
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return super.editingRectForBounds(UIEdgeInsetsInsetRect(bounds, padding))
    }
}
