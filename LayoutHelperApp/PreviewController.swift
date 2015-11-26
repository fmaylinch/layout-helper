
/**
 * Controller to preview the layout
 *
 * TODO: allow preview view resizing
 * http://stackoverflow.com/questions/16819396/drag-separator-to-resize-uiviews
 * https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIPanGestureRecognizer_Class/
 *
 * TODO: more properties like:
 *
 * label.layer.borderColor = UIColor.whiteColor().CGColor
 * label.layer.borderWidth = 1
 * label.layer.cornerRadius = 7
 * label.layer.masksToBounds = true
 */

import UIKit

class PreviewController: UIViewController, UIGestureRecognizerDelegate {
    
    let MainLayoutName = "mainLayout"
    let MainViewName = "mainView"

    // This is where views can be added in the code
    @IBOutlet weak var mainView: UIView!
    
    // Constraints for the container view, so they can be changed using dragView

    @IBOutlet weak var containerTrailing: NSLayoutConstraint!
    @IBOutlet weak var containerBottom: NSLayoutConstraint!
    @IBOutlet weak var dragView: UIView!
    @IBOutlet weak var dragLabel: UILabel!
    private var currentX: CGFloat = 0
    private var currentY: CGFloat = 0
    
    var code : String!
    
    var mainLayout : LayoutHelper!
    
    // keep the objects created in the code
    private var objects = [String:AnyObject]()

    // Last variable declared with let, to allow chaining
    private var previousVariable : String?

    // Dirty way of avoiding throws
    private var foundError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLayout = LayoutHelper(view: mainView)
        setupDragView()
        resetView()
    }
    
    /** When dragView is dragged, the container view will be resized through the constraints */
    private func setupDragView()
    {
        storeCurrentConstraintConstants()
        
        dragLabel.text = "\u{f0b2}"
        dragLabel.font = ViewUtil.fontAwesomeWithSize(30)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: Selector("drag:"))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.delegate = self
        dragView.addGestureRecognizer(panRecognizer)
    }
    
    func drag(panRecognizer: UIPanGestureRecognizer) {
        
        let point = panRecognizer.translationInView(dragView)
        
        let x = min(currentX + point.x, 0)
        let y = min(currentY + point.y, 0)
        
        containerTrailing.constant = x
        containerBottom.constant = y
        
        self.view.setNeedsUpdateConstraints()
        
        if panRecognizer.state == .Ended {
            storeCurrentConstraintConstants()
        }
    }
    
    func storeCurrentConstraintConstants() {
        currentX = containerTrailing.constant
        currentY = containerBottom.constant
        print("Current margins: {\(currentX), \(currentY)}")
    }
    
    @IBAction func reloadCode(sender: AnyObject) {
        print("Reset view")
        resetView()
    }
    
    private func resetView() {
        
        objects.removeAll()
        
        for view in mainView.subviews {
            view.removeFromSuperview()
        }
        
        objects[MainLayoutName] = mainLayout
        objects[MainViewName] = mainLayout.view
        
        // hardcodedTest()
        parseText(code)
    }
    
    private func parseText(text: String) {
        
        let lines = text.split("\n")
        
        for line in lines {
            
            guard !foundError else { return }
            
            print("  >> \(line)")
            parse(line)
        }
    }
    
    // It's strange but we need to use `PreviewController` first (probably to send the `self`)
    // See below wen calling `function(self)(result)`
    private let regexToFuncs : [NSRegularExpression : PreviewController -> RegexResult -> Void] = [
        
        Regex.letView : processLet,
        Regex.letLabel : processLetLabel,
        Regex.letLayout : processLetLayout,
        Regex.letColor : processLetColor,
        
        Regex.withRandomColors : processWithRandomColors,
        Regex.addViews : processAddViews,
        Regex.addConstraints : processAddConstraints,
        Regex.setWrap : processSetWrap,
        
        Regex.setText : processSetText,
        Regex.setNumberOfLines : processSetNumberOfLines,
        Regex.setTextAlignment : processSetTextAlignment,
        Regex.setTextColor : processSetTextColor,
        Regex.setBackgroundColor : processSetBackgroundColor,

        Regex.comment : processComment
    ]
    
    private func parse(line:String) {
        
        for (regex, function) in regexToFuncs {
            if let result = match(regex, line) {
                function(self)(result) // here we pass `self` to get the function
                return
            }
        }
        
        if match(Regex.empty, line) == nil {
            displayError("Unknown sentence: \(line)")
        }
    }
    
    private func parseUrl(urlStr: String) {
        
        print("Reading content from url: \(urlStr)")
        
        let url = NSURL(string: urlStr)
        
        let ai = displayActivityIndicator()
        
        // let request = NSURLRequest(URL: url!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 20)
        let session = NSURLSession.sharedSession()
        
        // NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
        let task = session.dataTaskWithURL(url!) {(data, response, error) in

            dispatch_async(dispatch_get_main_queue(),{
                ai.removeFromSuperview()
            })

            if error == nil {
                
                let result = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                print("Received result from request")
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.parseText(result as String)
                })
                
            } else {
                self.displayError("Error reading url `\(urlStr)`: \(error)")
            }
        }
        
        task.resume()
    }
    
    private func displayActivityIndicator() -> UIActivityIndicatorView {
        
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        ai.startAnimating()
        mainLayout
            .addView(ai, key: "ai")
            .addConstraints([
                "X:ai.centerX == parent.centerX",
                "X:ai.centerY == parent.centerY"])
        
        return ai
    }
    
    // Ignores comment, or reads url if comment has a http url
    private func processComment(result: RegexResult) {
        
        if let result = match(Regex.url, result.str) {
            let url = result.group(1)!
            parseUrl(url)
        }
    }

    // Creates a UIView or UILabel
    func processLet(result: RegexResult) {
    
        let variable = result.group(1)!
        let clazz = result.group(2)!
        
        guard letVarAvailable(variable) else { return }
        
        if clazz == "UIView" {
            print("Creating view `\(variable)`")
            objects[variable] = UIView()
        } else if clazz == "UILabel" {
            print("Creating label `\(variable)`")
            objects[variable] = UILabel()
        } else {
            displayError("Unsupported class \(clazz)")
        }
    }
    
    // Creates a UILabel usingViewUtil.labelWithSize(s)
    private func processLetLabel(result: RegexResult) {
        
        let variable = result.group(1)!
        let size = result.groupAsFloat(2)!

        guard letVarAvailable(variable) else { return }

        print("Creating label `\(variable)` with size `\(size)`")
        let label = ViewUtil.labelWithSize(size)
        
        objects[variable] = label
    }

    // Creates a LayoutHelper
    private func processLetLayout(result: RegexResult) {
        
        let variable = result.group(1)!
        let viewName = result.group(2)!
        
        guard letVarAvailable(variable) else { return }

        if let view = getView(viewName) {
            print("Creating layout `\(variable)` with view `\(viewName)`")
            objects[variable] = LayoutHelper(view: view)
        } else {
            displayError("View with name `\(viewName)` not found. Did you create it? Line: \(result.str)")
        }
    }

    // Creates a UIColor usingViewUtil.color(...)
    private func processLetColor(result: RegexResult) {
        
        let variable = result.group(1)!
        let red = result.groupAsInt(2)!
        let green = result.groupAsInt(3)!
        let blue = result.groupAsInt(4)!
        let alpha = result.groupAsFloat(5)!
        
        guard letVarAvailable(variable) else { return }

        print("Creating color `\(variable)` with rgba(\(red), \(green), \(blue), \(alpha)")
        let color = ViewUtil.color(red: red, green: green, blue: blue, alpha: alpha)
        
        objects[variable] = color
    }
    
    private func letVarAvailable(variable: String) -> Bool {
        
        previousVariable = variable // keep last let variable
        
        if objects.keys.contains(variable) {
            displayError("There's already a variable with the name `\(variable)`.")
            return false
        } else {
            return true
        }
    }
    
    // Adds wrap constraints to a view
    private func processWithRandomColors(result: RegexResult) {
        
        let layoutName = getVariableName(result.group(1))
        let withRandomColors = result.group(2)! == "true"
        
        print("\(withRandomColors ? "Enabling" : "Disabling") random colors in layout `\(layoutName)`")
        
        guard let layout = getLayout(layoutName) else { return }
        
        layout.withRandomColors(withRandomColors)
    }
    
    // Adds views to a LayoutHelper
    private func processAddViews(result: RegexResult) {
        
        let layoutName = getVariableName(result.group(1))
        let keysValues = result.group(2)!
        
        print("Adding views to layout `\(layoutName)`")
        guard let layout = getLayout(layoutName) else { return }

        var viewsMap = [String:UIView]()
        
        for keyValue in keysValues.split(", ")
        {
            if let result = match(Regex.keyValue, keyValue)
            {
                let key = result.group(1)!
                let viewName = result.group(2)!
                if let view = getView(viewName) {
                    print("- Adding view `\(viewName)` with key \"\(key)\"")
                    viewsMap[key] = view
                } else {
                    displayError("There's no view with the name `\(viewName)`. Pair: `\(keyValue)`. Line: \(result.str)")
                }
            }
        }
        
        layout.addViews(viewsMap)
    }

    // Adds constraints to a LayoutHelper
    private func processAddConstraints(result: RegexResult) {
        
        let layoutName = getVariableName(result.group(1))
        let constraints = result.group(2)!
        
        print("Adding views to layout `\(layoutName)`")
        guard let layout = getLayout(layoutName) else { return }
        
        for quotedConstraint in constraints.split(", ") {
            // Get rid of surrounding quotes ""
            let constraint = quotedConstraint.substring(1, -1)
            print("- Adding constraint \"\(constraint)\"")
            layout.addConstraint(constraint)
        }
    }
 
    // Adds wrap constraints to a view
    private func processSetWrap(result: RegexResult) {
        
        let layoutName = getVariableName(result.group(1))
        let viewKey = result.group(2)!
        let axisStr = result.group(3)!
        
        print("Setting \(axisStr) wrap to view \"\(viewKey)\" in layout `\(layoutName)`")
        
        guard let layout = getLayout(layoutName) else { return }
        
        let axis = axisStr == ".Horizontal" ?
            UILayoutConstraintAxis.Horizontal : UILayoutConstraintAxis.Vertical
        
        layout.setWrapContent(viewKey, axis: axis)
    }

    // Sets text to a label
    private func processSetText(result: RegexResult) {
        
        let variable = result.group(1)!
        let text = result.group(2)!
            .stringByReplacingOccurrencesOfString("\\n", withString: "\n") // dirty replacing
        
        print("Setting text `\(text)` to view `\(variable)`")
        guard let label = getLabel(variable) else { return }
        label.text = text
    }

    // Sets numberOfLines to a label
    private func processSetNumberOfLines(result: RegexResult) {
        
        let variable = result.group(1)!
        let numberOfLines = result.groupAsInt(2)!
        
        print("Setting `\(numberOfLines)` number of lines to label `\(variable)`")
        guard let label = getLabel(variable) else { return }
        label.numberOfLines = numberOfLines
    }
 
    // Sets alignment to a label
    private func processSetTextAlignment(result: RegexResult) {
        
        let variable = result.group(1)!
        let alignStr = result.group(2)!
        
        func getAlignment(str: String) -> NSTextAlignment {
            switch (str) {
            case ".Center":    return .Center
            case ".Left":      return .Left
            case ".Right":     return .Right
            case ".Justified": return .Justified
            case ".Natural":   return .Natural
            default: fatalError("Unexpected alignment `\(str)`")
            }
        }
        
        print("Setting alignment `\(alignStr)` to label `\(variable)`")
        guard let label = getLabel(variable) else { return }
        label.textAlignment = getAlignment(alignStr)
    }
    
    // Sets text color to a label
    private func processSetTextColor(result: RegexResult) {
        
        let variable = result.group(1)!
        let colorName = result.group(2)!
        
        print("Setting text color `\(colorName)` to label `\(variable)`")
        guard let label = getLabel(variable) else { return }
        label.textColor = getColor(colorName)
    }

    // Sets background color to a view
    private func processSetBackgroundColor(result: RegexResult) {
        
        let variable = result.group(1)!
        let colorName = result.group(2)!
        
        print("Setting background color `\(colorName)` to view `\(variable)`")
        guard let view = getView(variable) else { return }
        view.backgroundColor = getColor(colorName)
    }


    private func getLabel(name: String) -> UILabel? {
        let view = getView(name)
        if view is UILabel {
            return view as? UILabel
        } else {
            displayError("View `\(name)` is not a label")
            return nil
        }
    }

    private func getView(name: String) -> UIView? {
        
        return getObject(name, clazz: UIView.self)
    }

    private func getColor(name: String) -> UIColor? {
        
        return getObject(name, clazz: UIColor.self)
    }
    
    private func getVariableName(name: String?) -> String {

        guard let resolvedName = name ?? previousVariable else {
            displayError("Unexpected chained expression, can't tell the object you want to access")
            return "(unknown)"
        }

        return resolvedName
    }
    
    private func getLayout(name: String) -> LayoutHelper? {
        
        return getObject(name, clazz: LayoutHelper.self)
    }

    private func getObject<T:AnyObject>(name: String, clazz: T.Type) -> T?
    {
        guard let object = objects[name] else {
            displayError("There's no object with the name `\(name)`")
            return nil
        }
        
        guard let typedObject = object as? T else {
            displayError("Object with name `\(name)` is not of type \(clazz), it is a \(object.dynamicType)")
            return nil
        }
        
        return typedObject
    }
    
    
    // Regular expressions
    
    private func match(regex: NSRegularExpression, _ str: String) -> RegexResult? {
        
        let results = regex.matchesInString(str, options: NSMatchingOptions(), range: NSMakeRange(0, str.characters.count))

        if results.count == 1 {
            return RegexResult(str: str, result: results[0])
        }
        
        if results.count > 1 {
            displayError("Unexpected result count \(results.count) for: \(str)")
        }
        
        return nil
    }

    private class Regex {
        
        // identifier pattern (variable, method, class, etc.)
        static let Id: String = "[_a-zA-Z][_a-zA-Z0-9]+"
        // float number pattern e.g. "12", "12.", "2.56"
        static let FloatNum: String = "\\d+\\.?\\d*"
        // integer number pattern e.g. "1", "75", "200"
        static let IntNum: String = "0|[1-9]\\d*"

        // example: let v1 = UIView()
        static let letView = Regex.parse("^ *let +(\(Id)) *= *(\(Id))\\(\\) *$")
        // example: let label = ViewUtil.labelWithSize(20)
        static let letLabel = Regex.parse("^ *let +(\(Id)) *= *ViewUtil\\.labelWithSize\\((\(FloatNum))\\) *$")
        // example: let lay = LayoutHelper(view: v1)
        static let letLayout = Regex.parse("^ *let +(\(Id)) *= *LayoutHelper\\(view: *(\(Id))\\) *$")
        // example: let color = ViewUtil.color(red: 255, green: 0, blue: 150, alpha: 0.7)
        static var letColor = Regex.parse("^ *let +(\(Id)) *= *ViewUtil\\.color\\(red: *(\(IntNum)), *green: *(\(IntNum)), *blue: *(\(IntNum)), *alpha: (\(FloatNum))\\) *$")
        
        // example: lay.withRandomColors(true)
        static var withRandomColors = Regex.parse("^ *(\(Id))?\\.withRandomColors\\((true|false)\\)")
        // example: lay.addViews(["t1":t1, "t2":t2]) -- array content must be treated later
        static var addViews = Regex.parse("^ *(\(Id))?\\.addViews\\(\\[(.+)\\]\\) *$")
        // example: "t1":t1
        static var keyValue = Regex.parse("\"(\(Id))\" *: *(\(Id))")
        // example: lay.addConstraints(["H:|[t1]|", "V:|[t1]|"]) -- array content must be treated later
        static var addConstraints = Regex.parse("^ *(\(Id))?\\.addConstraints\\(\\[(.+)\\]\\) *$")
        // example: lay.setWrapContent("t2", axis: .Horizontal)
        static var setWrap = Regex.parse("^ *(\(Id))?\\.setWrapContent\\(\"(\(Id))\", *axis: *((\\.Horizontal)|(\\.Vertical))\\) *$")
        
        // example: label.text = "hello"
        static var setText = Regex.parse("^ *(\(Id))\\.text *= *\"(.*)\" *$")
        // example: label.numberOfLines = 2
        static var setNumberOfLines = Regex.parse("^ *(\(Id))\\.numberOfLines *= *(\(IntNum)) *$")
        // example: label.textAlignment = .Center
        static var setTextAlignment = Regex.parse("^ *(\(Id))\\.textAlignment *= *(\\.\(Id)) *$")
        // example: label.textColor = color
        static var setTextColor = Regex.parse("^ *(\(Id))\\.textColor *= *(\(Id)) *$")
        // example: view.backgroundColor = color
        static var setBackgroundColor = Regex.parse("^ *(\(Id))\\.backgroundColor *= *(\(Id)) *$")
        
        static var comment = Regex.parse("^ *//")
        static var url = Regex.parse("^ *// *(http[^ ]+)")
        static var empty = Regex.parse("^ *$")
        
        static func parse(pattern: String) -> NSRegularExpression {
            print("Peparing regex: \(pattern)")
            return try! NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions())
        }
    }

    private func displayError(message: String) {
        
        foundError = true

        let alert = UIAlertController(title: "error", message: message, preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: {action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // Tests, not used in the program

    private func reflectionTests() {

        let UIViewClass = NSClassFromString("UIView") as! UIView.Type // This creates an UIView
        let v = UIViewClass.init() // Should now give you a new object
        // let method = UIViewClass.methodForSelector(Selector("backgroundColor"))
        v.performSelector(Selector(""), withObject: "")
    }
    
    
    private func hardcodedTest() {
        
        print("Running hardcoded test")
        
        let main = getLayout(MainLayoutName)!
       
        // from here is parseable code
        
        let color = ViewUtil.color(red: 255, green: 0, blue: 150, alpha: 0.5)
        let color2 = ViewUtil.color(red: 20, green: 150, blue: 150, alpha: 0.5)

        let t1 = ViewUtil.labelWithSize(20)
        t1.text = "wrapped color"
        t1.textColor = color
        
        let t2 = ViewUtil.labelWithSize(20)
        t2.text = "FILL colored"
        t2.backgroundColor = color
        
        let v1 = UIView()
        v1.backgroundColor = color2
        let lay = LayoutHelper(view: v1)
        
        lay.addViews(["t1":t1, "t2":t2])
        lay.addConstraints(["H:|-[t1]-[t2]-|", "V:|-[t1]-|", "V:|-[t2]-|"])
        lay.setWrapContent("t1", axis: .Horizontal)
        
        main.addViews(["v1": v1])
        main.addConstraints(["H:|-[v1]-|", "V:|-[v1]"])

        // not supported yet
        // lay.setHugging("t2", priority: 750, axis: .Horizontal)
        // lay.setResistance("t2", priority: 1000, axis: .Horizontal)
    }
}
