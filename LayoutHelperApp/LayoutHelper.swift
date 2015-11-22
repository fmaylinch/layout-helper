
/** Helper class for creating layouts */

import UIKit

public class LayoutHelper {
    
    public static let XtConstraintPrefix = "X"
    public static let DefaultPriority: UILayoutPriority = 0
    
    public let view: UIView
    private var subviews = [String:UIView]()
    public var metrics = [String:CGFloat]()
    
    public var displayRandomColors = false
    
    
    public init(view: UIView) {
        self.view = view
    }
    
    public convenience init() {
        self.init(view: UIView())
    }
    
    // Add views
    
    public func fillWithView(view: UIView) -> LayoutHelper {
        return addView(view, key: "v").addConstraints(["H:|[v]|", "V:|[v]|"])
    }

    public func fillWithView(view: UIView, margins:UIEdgeInsets) -> LayoutHelper {
        return addView(view, key: "v")
            .withMetrics(["l":margins.left, "t":margins.top, "r":margins.right, "b":margins.bottom])
            .addConstraints(["H:|-(l)-[v]-(r)-|", "V:|-(t)-[v]-(b)-|"])
    }

    public func addViews(views: [String:UIView]) -> LayoutHelper {
        return addViews(views, addToParent:true)
    }
    
    public func addViews(views: [String:UIView], addToParent:Bool) -> LayoutHelper {
        for (key,view) in views {
            addView(view, key:key, addToParent:addToParent)
        }
        return self
    }
    
    public func addView(view:UIView, key:String) -> LayoutHelper {
        return addView(view, key: key, addToParent:true)
    }
        
    public func addView(view:UIView, key:String, addToParent:Bool) -> LayoutHelper {

        subviews[key] = view
        
        if !addToParent { return self }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        
        if displayRandomColors {
            view.backgroundColor = getRandomColorWithAlpha(0.4)
        }
        
        return self
    }

    // Various
    
    public func withRandomColors(displayRandomColors: Bool) -> LayoutHelper {
        self.displayRandomColors = displayRandomColors
        return self
    }

    public func withMetrics(metrics: [String:CGFloat]) -> LayoutHelper {
        self.metrics = metrics
        return self
    }
    
    // Hugging and compression - http://stackoverflow.com/questions/33842797
    
    /** Tries to simulate Android's wrap_content by setting hugging and compression to view */
    public func setWrapContent(viewKey:String, axis: UILayoutConstraintAxis) -> LayoutHelper {
        
        let view = findViewFromKey(viewKey)
        return setWrapContent(view, axis: axis)
    }

    /** Tries to simulate Android's wrap_content by setting hugging and compression to view */
    public func setWrapContent(view:UIView, axis: UILayoutConstraintAxis) -> LayoutHelper {
        
        setHugging(view, priority: UILayoutPriorityDefaultHigh, axis: axis)
        setResistance(view, priority: UILayoutPriorityRequired, axis: axis)
        return self
    }

    /** Sets hugging priority to view with given key and all its subviews. */
    public func setHugging(viewKey:String, priority:UILayoutPriority, axis: UILayoutConstraintAxis) -> LayoutHelper {
        
        let view = findViewFromKey(viewKey)
        return setHugging(view, priority: priority, axis: axis)
    }

    /** Sets hugging priority to view and all its subviews. */
    public func setHugging(view:UIView, priority:UILayoutPriority, axis: UILayoutConstraintAxis) -> LayoutHelper {
        
        view.setContentHuggingPriority(priority, forAxis: axis)
        for v in view.subviews {
            setHugging(v, priority: priority, axis: axis) // recursive
        }
        return self
    }

    /** Sets compression resistance priority to view with given key and all its subviews. */
    public func setResistance(viewKey:String, priority:UILayoutPriority, axis: UILayoutConstraintAxis) -> LayoutHelper {
        
        let view = findViewFromKey(viewKey)
        return setResistance(view, priority: priority, axis: axis)
    }
    
    /** Sets compression resistance priority to view and all its subviews. */
    public func setResistance(view:UIView, priority:UILayoutPriority, axis: UILayoutConstraintAxis) -> LayoutHelper {
        
        view.setContentCompressionResistancePriority(priority, forAxis: axis)
        for v in view.subviews {
            setResistance(v, priority: priority, axis: axis) // recursive
        }
        return self
    }
    

    // Constraints
    
    public func addConstraints(cs:[String]) -> LayoutHelper {
        return addConstraints(cs, priority: LayoutHelper.DefaultPriority)
    }

    public func addConstraints(cs:[String], priority:UILayoutPriority) -> LayoutHelper {
        for c in cs {
            addConstraint(c, priority: priority)
        }
        return self
    }

    public func addConstraint(c:String) -> LayoutHelper {
        return addConstraint(c, priority:LayoutHelper.DefaultPriority)
    }
    
    public func addConstraint(c:String, priority:UILayoutPriority) -> LayoutHelper {
        
        // print("Parsing constraint: \(c)")
        
        let realConstraints = parseConstraint(c)
        
        if priority != LayoutHelper.DefaultPriority {
            for realConstraint in realConstraints {
                realConstraint.priority = priority;
            }
        }
        
        self.view.addConstraints(realConstraints)
        
        return self
    }
    
    
    /** Parses a constraint, either a normal Visual Format constraint (H,V) or an extended (X) constraint */
    private func parseConstraint(c:String) -> [NSLayoutConstraint] {
        
        if c.hasPrefix(LayoutHelper.XtConstraintPrefix) {
            return parseXtConstraint(c)
        }
        else {
            return NSLayoutConstraint.constraintsWithVisualFormat(c,
                options: NSLayoutFormatOptions(), metrics: metrics, views: subviews)
        }
    }
    
    /** Parses an extended (X) constraint */
    private func parseXtConstraint(constraint: String) -> [NSLayoutConstraint]
    {
        let results = LayoutHelper.xtConstraintRegex.matchesInString(constraint,
            options: NSMatchingOptions(), range: NSMakeRange(0, constraint.characters.count))
        
        if results.count != 1 {
            fatalError("Invalid constraint: \(constraint)")
        }
        
        let match: NSTextCheckingResult = results[0]
        if match.numberOfRanges != 10 {
            dumpMatch(match, forString: constraint)
            fatalError("Invalid constraint: \(constraint)")
        }
        let item1Key: String = constraint.substring(match.rangeAtIndex(1))
        let attr1Str: String = constraint.substring(match.rangeAtIndex(2))
        let relationStr: String = constraint.substring(match.rangeAtIndex(3))
        let item2Key: String = constraint.substring(match.rangeAtIndex(4))
        let attr2Str: String = constraint.substring(match.rangeAtIndex(5))
        let item1: AnyObject = findViewFromKey(item1Key)
        let item2: AnyObject = findViewFromKey(item2Key)
        let attr1: NSLayoutAttribute = parseAttribute(attr1Str)
        let attr2: NSLayoutAttribute = parseAttribute(attr2Str)
        let relation: NSLayoutRelation = parseRelation(relationStr)
        var multiplier: CGFloat = 1
        if match.rangeAtIndex(6).location != NSNotFound {
            let operation: String = constraint.substring(match.rangeAtIndex(6))
            let multiplierValue: String = constraint.substring(match.rangeAtIndex(7))
            multiplier = getFloatFromValue(multiplierValue)
            if (operation == "/") {
                multiplier = 1 / multiplier
            }
        }
        var constant: CGFloat = 0
        if match.rangeAtIndex(8).location != NSNotFound {
            let operation: String = constraint.substring(match.rangeAtIndex(8))
            let constantValue: String = constraint.substring(match.rangeAtIndex(9))
            constant = getFloatFromValue(constantValue)
            if (operation == "-") {
                constant = -constant
            }
        }
        let c: NSLayoutConstraint = NSLayoutConstraint(
            item: item1, attribute: attr1, relatedBy: relation,
            toItem: item2, attribute: attr2, multiplier: multiplier, constant: constant)
        
        return [c]
    }
    
    /** `value` may be the name of a metric, or a literal float value */
    private func getFloatFromValue(value: String) -> CGFloat
    {
        if stringIsIdentifier(value) {
            if let metric = metrics[value] {
                return metric
            }
            else {
                let reason = "Metric `\(value)` was not provided"
                fatalError(reason)
            }
        }
        else {
            return CGFloat((value as NSString).floatValue)
        }
    }
    
    /** Returns true if `value` starts with a valid identifier character */
    private func stringIsIdentifier(value: String) -> Bool {
        let c = value[value.startIndex] // gets first char of string
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_"
    }
    
    private func findViewFromKey(key: String) -> UIView
    {
        if (key == "superview") {
            return self.view
        }
        else {
            if let view = subviews[key] {
                return view
            }
            else {
                let reason = "No view was added with key `\(key)`"
                fatalError(reason)
            }
        }
    }
    
    private static let attributes : [String:NSLayoutAttribute] = [
        "left": .Left, "right": .Right, "top": .Top, "bottom": .Bottom,
        "leading": .Leading, "trailing": .Trailing,
        "width": .Width, "height": .Height,
        "centerX": .CenterX, "centerY": .CenterY,
        "baseline": .Baseline]
    
    private func parseAttribute(attrStr: String) -> NSLayoutAttribute
    {
        if let value = LayoutHelper.attributes[attrStr] {
            return value
        }
        else {
            let reason = "Attribute `\(attrStr)` is not valid. Use one of: \(LayoutHelper.attributes.keys)"
            fatalError(reason)
        }
    }
 
    private static let relations : [String:NSLayoutRelation] = [
        "==": .Equal, ">=": .GreaterThanOrEqual, "<=": .LessThanOrEqual]

    private func parseRelation(relationStr: String) -> NSLayoutRelation
    {
        if let value = LayoutHelper.relations[relationStr] {
            return value
        }
        else {
            let reason = "Relation `\(relationStr)` is not valid. Use one of: \(LayoutHelper.relations.keys)"
            fatalError(reason)
        }
    }
    
    private static var xtConstraintRegex = LayoutHelper.prepareRegex()

    private static func prepareRegex() -> NSRegularExpression {
        
        // C identifier
        let identifier: String = "[_a-zA-Z][_a-zA-Z0-9]{0,30}"
        // VIEW_KEY.ATTR or (use "superview" as VIEW_KEY to refer to superview)
        let attr: String = "(\(identifier))\\.(\(identifier))"
        // Relations taken from NSLayoutRelation
        let relation: String = "([=><]+)"
        // float number e.g. "12", "12.", "2.56"
        let number: String = "\\d+\\.?\\d*"
        // Value (indentifier or number)
        let value: String = "(?:(?:\(identifier))|(?:\(number)))"
        // e.g. "*5" or "/ 27.3" or "* 200"
        let multiplier: String = "([*/]) *(\(value))"
        // e.g. "+ 2." or "- 56" or "-7.5"
        let constant: String = "([+-]) *(\(value))"
        let pattern: String = "^\(XtConstraintPrefix): *\(attr) *\(relation) *\(attr) *(?:\(multiplier))? *(?:\(constant))?$"
        
        return try! NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
    }

    private func getRandomColorWithAlpha(alpha: CGFloat) -> UIColor
    {
        let red = arc4random_uniform(256)
        let green = arc4random_uniform(256)
        let blue = arc4random_uniform(256)
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    private func dumpMatch(match: NSTextCheckingResult, forString str: String)
    {
        for i in 0 ..< match.numberOfRanges {
            
            let range = match.rangeAtIndex(i)
            
            if range.location != NSNotFound {
                let part = str.substring(range)
                print("Range \(i): \(part)")
            }
            else {
                print("Range \(i)  NOT FOUND")
            }
        }
    }
}