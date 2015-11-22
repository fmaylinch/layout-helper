
// Controller to preview the layout

import UIKit

class PreviewController: UIViewController {
    
    @IBOutlet weak var preview: UIView!
    var code : String!
    
    // keep the objects created in the code
    private var layouts = [String:LayoutHelper]() // by default includes "main"
    private var views = [String:UIView]()
    private var colors = [String:UIColor]()
    
    // Dirty way of avoiding throws
    private var foundError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layouts["main"] = LayoutHelper(view: preview) // we add a main layout with the preview view
        
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
    
    private func parse(line:String) {
        
        if let result = match(Regex.letView, line) {
            processLet(line, result)
        } else if let result = match(Regex.letLabel, line) {
            processLetLabel(line, result)
        } else if let result = match(Regex.letLayout, line) {
            processLetLayout(line, result)
        } else if let result = match(Regex.letColor, line) {
            processLetColor(line, result)
        } else if let result = match(Regex.addViews, line) {
            processAddViews(line, result)
        } else if let result = match(Regex.addConstraints, line) {
            processAddConstraints(line, result)
        } else if let result = match(Regex.setWrap, line) {
            processSetWrap(line, result)
        } else if let result = match(Regex.setText, line) {
            processSetText(line, result)
        } else if let result = match(Regex.setTextColor, line) {
            processSetTextColor(line, result)
        } else if let result = match(Regex.setBackgroundColor, line) {
            processSetBackgroundColor(line, result)
            
        } else if hasMatch(Regex.comment, line) {
            // Ignore comment, or read url
            if let result = match(Regex.url, line) {
                let url = line.substring(result.rangeAtIndex(1))
                parseUrl(url)
            }
            
        } else if !hasMatch(Regex.empty, line) {
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
        let main = getLayout("main")!
        main.addView(ai, key: "ai")
        main.addConstraints([
            "X:ai.centerX == superview.centerX",
            "X:ai.centerY == superview.centerY"])
        
        return ai
    }
    
    // Creates a UIView or UILabel
    private func processLet(line: String, _ result: NSTextCheckingResult) {
    
        let variable = line.substring(result.rangeAtIndex(1))
        let clazz = line.substring(result.rangeAtIndex(2))
        
        guard !views.keys.contains(variable) else {
            displayError("There's already a view with the name `\(variable)`. Line: \(line)")
            return
        }

        if clazz == "UIView" {
            print("Creating view `\(variable)`")
            views[variable] = UIView()
        } else if clazz == "UILabel" {
            print("Creating label `\(variable)`")
            views[variable] = UILabel()
        } else {
            displayError("Unsupported class \(clazz)")
        }
    }

    // Creates a UILabel usingViewUtil.labelWithSize(s)
    private func processLetLabel(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let sizeStr = line.substring(result.rangeAtIndex(2))
        let size = (sizeStr as NSString).floatValue

        guard !views.keys.contains(variable) else {
            displayError("There's already a view with the name `\(variable)`. Line: \(line)")
            return
        }

        print("Creating label `\(variable)` with size `\(size)`")
        let label = ViewUtil.labelWithSize(size)
        
        views[variable] = label
    }

    // Creates a LayoutHelper
    private func processLetLayout(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let viewName = line.substring(result.rangeAtIndex(2))
        
        // This regex part is optional
        let withRandomColors = result.rangeAtIndex(3).location != NSNotFound
            && line.substring(result.rangeAtIndex(3)) == "true"

        guard !layouts.keys.contains(variable) else {
            displayError("There's already a layout with the name `\(variable)`. Line: \(line)")
            return
        }

        if let view = views[viewName] {
            print("Creating layout `\(variable)` with view `\(viewName)`")
            layouts[variable] = LayoutHelper(view: view).withRandomColors(withRandomColors)
        } else {
            displayError("View with name `\(viewName)` not found. Did you create it? Line: \(line)")
        }
    }

    // Creates a UIColor usingViewUtil.color(...)
    private func processLetColor(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let redStr = line.substring(result.rangeAtIndex(2))
        let red = (redStr as NSString).integerValue
        let greenStr = line.substring(result.rangeAtIndex(3))
        let green = (greenStr as NSString).integerValue
        let blueStr = line.substring(result.rangeAtIndex(4))
        let blue = (blueStr as NSString).integerValue
        let alphaStr = line.substring(result.rangeAtIndex(5))
        let alpha = (alphaStr as NSString).floatValue
        
        guard !colors.keys.contains(variable) else {
            displayError("There's already a color with the name `\(variable)`. Line: \(line)")
            return
        }
        
        print("Creating color `\(variable)` with rgb(\(red),\(green),\(blue)) and alpha \(alpha)")
        let color = ViewUtil.color(red: red, green: green, blue: blue, alpha: alpha)
        
        colors[variable] = color
    }

    // Adds views to a LayoutHelper
    private func processAddViews(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let keysValues = line.substring(result.rangeAtIndex(2))
        
        print("Adding views to layout `\(variable)`")
        guard let layout = getLayout(variable) else { return }

        var viewsMap = [String:UIView]()
        
        for keyValue in keysValues.split(", ")
        {
            if let result = match(Regex.keyValue, keyValue)
            {
                let key = keyValue.substring(result.rangeAtIndex(1))
                let viewName = keyValue.substring(result.rangeAtIndex(2))
                if let view = views[viewName] {
                    print("- Adding view `\(viewName)` with key \"\(key)\"")
                    viewsMap[key] = view
                } else {
                    displayError("There's no view with the name `\(viewName)`. Pair: `\(keyValue)`. Line: \(line)")
                }
            }
        }
        
        layout.addViews(viewsMap)
    }

    // Adds constraints to a LayoutHelper
    private func processAddConstraints(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let constraints = line.substring(result.rangeAtIndex(2))
        
        print("Adding views to layout `\(variable)`")
        guard let layout = getLayout(variable) else { return }
        
        for quotedConstraint in constraints.split(", ") {
            // Get rid of surrounding quotes ""
            let constraint = quotedConstraint.substring(1, -1)
            print("- Adding constraint \"\(constraint)\"")
            layout.addConstraint(constraint)
        }
    }
 
    // Adds wrap constraints to a view
    private func processSetWrap(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let viewKey = line.substring(result.rangeAtIndex(2))
        let axisStr = line.substring(result.rangeAtIndex(3))
        
        print("Setting \(axisStr) wrap to view \"\(viewKey)\" in layout `\(variable)`")
        
        guard let layout = getLayout(variable) else { return }
        guard let view = getView(viewKey) else { return }
        
        let axis = axisStr == ".Horizontal" ?
            UILayoutConstraintAxis.Horizontal : UILayoutConstraintAxis.Vertical
        
        layout.setWrapContent(view, axis: axis)
    }

    // Sets text to a label
    private func processSetText(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let text = line.substring(result.rangeAtIndex(2))
        
        print("Setting text `\(text)` to view `\(variable)`")
        guard let label = getLabel(variable) else { return }
        label.text = text
    }

    // Sets text color to a label
    private func processSetTextColor(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let colorName = line.substring(result.rangeAtIndex(2))
        
        print("Setting text color `\(colorName)` to label `\(variable)`")
        guard let label = getLabel(variable) else { return }
        label.textColor = getColor(colorName)
    }

    // Sets background color to a view
    private func processSetBackgroundColor(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let colorName = line.substring(result.rangeAtIndex(2))
        
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
        guard let view = views[name] else {
            displayError("There's no view with the name `\(name)`")
            return nil
        }
        return view
    }

    private func getColor(name: String) -> UIColor? {
        guard let color = colors[name] else {
            displayError("There's no color with the name `\(name)`")
            return nil
        }
        return color
    }

    private func getLayout(name: String) -> LayoutHelper? {
        guard let layout = layouts[name] else {
            displayError("There's no layout with the name `\(name)`")
            return nil
        }
        return layout
    }

    
    // Regular expressions
    
    private func match(regex: NSRegularExpression, _ str: String) -> NSTextCheckingResult? {
        
        let results = regex.matchesInString(str, options: NSMatchingOptions(), range: NSMakeRange(0, str.characters.count))
        if results.count == 1 {
            return results[0]
        } else if results.count == 0 {
            return nil
        } else {
            displayError("Unexpected result count \(results.count) for: \(str)")
            return nil
        }
    }
    
    private func hasMatch(regex: NSRegularExpression, _ str: String) -> Bool {
        return match(regex, str) != nil
    }
    
    private class Regex {
        
        // identifier pattern (variable, method, class, etc.)
        static let Id: String = "[_a-zA-Z][_a-zA-Z0-9]+"
        // float number pattern e.g. "12", "12.", "2.56"
        static let Number: String = "\\d+\\.?\\d*"

        // example: let v1 = UIView()
        static let letView = Regex.parse("^ *let +(\(Id)) *= *(\(Id))\\(\\) *$")
        // example: let label = ViewUtil.labelWithSize(20)
        static let letLabel = Regex.parse("^ *let +(\(Id)) *= *ViewUtil\\.labelWithSize\\((\(Number))\\) *$")
        // example: let lay = LayoutHelper(view: v1)
        static let letLayout = Regex.parse("^ *let +(\(Id)) *= *LayoutHelper\\(view: *(\(Id))\\)(?:\\.withRandomColors\\((true|false)\\))? *$")
        // example: let color = ViewUtil.color(red: 255, green: 0, blue: 150, alpha: 0.7)
        static var letColor = Regex.parse("^ *let +(\(Id)) *= *ViewUtil\\.color\\(red: *(\(Number)), *green: *(\(Number)), *blue: *(\(Number)), *alpha: (\(Number))\\) *$")
        
        // example: lay.addViews(["t1":t1, "t2":t2]) -- array content must be treated later
        static var addViews = Regex.parse("^ *(\(Id))\\.addViews\\(\\[(.+)\\]\\) *$")
        // example: "t1":t1
        static var keyValue = Regex.parse("\"(\(Id))\" *: *(\(Id))")
        // example: lay.addConstraints(["H:|[t1]|", "V:|[t1]|"]) -- array content must be treated later
        static var addConstraints = Regex.parse("(\(Id))\\.addConstraints\\(\\[(.+)\\]\\) *$")
        // example: lay.setWrapContent("t2", axis: .Horizontal)
        static var setWrap = Regex.parse("^ *(\(Id))\\.setWrapContent\\(\"(\(Id))\", *axis: *(\\.(Horizontal)|(Vertical))\\) *$")
        
        // example: label.text = "hello"
        static var setText = Regex.parse("^ *(\(Id))\\.text *= *\"(.*)\" *$")
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
        
        let main = getLayout("main")!
       
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
