
// Controller to preview the layout

import UIKit

class PreviewController: UIViewController {
    
    @IBOutlet weak var preview: UIView!
    var code : String!
    
    // keep the objects created in the code
    private var layouts = [String:LayoutHelper]() // by default includes "main"
    private var views = [String:UIView]()
    private var colors = [String:UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layouts["main"] = LayoutHelper(view: preview) // we add a main layout with the preview view
        
        // hardcodedTest()
        parseText(code)
    }
    
    private func parseText(text: String) {
        
        let lines = text.split("\n")
        
        for line in lines {
            print("parsing line: \(line)")
            parse(line)
        }
    }
    
    private func parse(line:String) {
        
        if let result = match(PreviewController.letRegex, str: line) {
            processLet(line, result)
        } else if let result = match(PreviewController.letLabelRegex, str: line) {
            processLetLabel(line, result)
        } else if let result = match(PreviewController.letLayoutRegex, str: line) {
            processLetLayout(line, result)
        } else if let result = match(PreviewController.letColorRegex, str: line) {
            processLetColor(line, result)
        } else if let result = match(PreviewController.addViewsRegex, str: line) {
            processAddViews(line, result)
        } else if let result = match(PreviewController.addConstraintsRegex, str: line) {
            processAddConstraints(line, result)
        } else if let result = match(PreviewController.setWrapRegex, str: line) {
            processSetWrap(line, result)
        } else if let result = match(PreviewController.setTextRegex, str: line) {
            processSetText(line, result)
        } else if let result = match(PreviewController.setTextColorRegex, str: line) {
            processSetTextColor(line, result)
        } else if let result = match(PreviewController.setBackgroundColorRegex, str: line) {
            processSetBackgroundColor(line, result)
            
        } else if line.hasPrefix("//") {
            // Ignore comment, or read url
            if line.hasPrefix("// http") {
                let url = line.substring(3, line.characters.count)
                parseUrl(url)
            }
        } else {
            // Ignore line if empty (TODO: ignore comment)
            let cleaned = line.stringByReplacingOccurrencesOfString(" ", withString: "")
            if cleaned.characters.count > 0 {
                fatalError("Unknown sentence: \(line)")
            }
        }
    }
    
    private func parseUrl(urlStr: String) {
        
        print("Reading content from url: \(urlStr)")
        
        let url = NSURL(string: urlStr)
        
        // Add activity indicator in the middle
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        ai.startAnimating()
        let main = getLayout("main")
        main.addView(ai, key: "ai")
        main.addConstraints([
            "X:ai.centerX == superview.centerX",
            "X:ai.centerY == superview.centerY"])
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in

            dispatch_async(dispatch_get_main_queue(),{
                ai.removeFromSuperview()
            })

            if error != nil {
                print("Error reading url `\(urlStr)`: \(error)")
            } else {
                
                let result = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                print("Got result from request: \(result)")
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.parseText(result as String)
                })
            }
        }
        
        task.resume()
    }
    
    // Creates a UIView or UILabel
    private func processLet(line: String, _ result: NSTextCheckingResult) {
    
        let variable = line.substring(result.rangeAtIndex(1))
        let clazz = line.substring(result.rangeAtIndex(2))
        
        guard !views.keys.contains(variable) else {
            fatalError("There's already a view with the name `\(variable)`. Line: \(line)")
        }

        if clazz == "UIView" {
            print("Creating view `\(variable)`")
            views[variable] = UIView()
        } else if clazz == "UILabel" {
            print("Creating label `\(variable)`")
            views[variable] = UILabel()
        } else {
            fatalError("Unsupported class \(clazz)")
        }
    }

    // Creates a UILabel usingViewUtil.labelWithSize(s)
    private func processLetLabel(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let sizeStr = line.substring(result.rangeAtIndex(2))
        let size = (sizeStr as NSString).floatValue

        guard !views.keys.contains(variable) else {
            fatalError("There's already a view with the name `\(variable)`. Line: \(line)")
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
            fatalError("There's already a layout with the name `\(variable)`. Line: \(line)")
        }

        if let view = views[viewName] {
            print("Creating layout `\(variable)` with view `\(viewName)`")
            layouts[variable] = LayoutHelper(view: view).withRandomColors(withRandomColors)
        } else {
            fatalError("View with name `\(viewName)` not found. Did you create it? Line: \(line)")
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
            fatalError("There's already a color with the name `\(variable)`. Line: \(line)")
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
        let layout = getLayout(variable)

        var viewsMap = [String:UIView]()
        
        for keyValue in keysValues.split(", ") {
            if let result = match(PreviewController.keyValueRegex, str: keyValue) {
                let key = keyValue.substring(result.rangeAtIndex(1))
                let viewName = keyValue.substring(result.rangeAtIndex(2))
                if let view = views[viewName] {
                    print("- Adding view `\(viewName)` with key \"\(key)\"")
                    viewsMap[key] = view
                } else {
                    fatalError("There's no view with the name `\(viewName)`. Pair: `\(keyValue)`. Line: \(line)")
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
        let layout = getLayout(variable)
        
        for quotedConstraint in constraints.split(", ") {
            // Get rid of surrounding quotes ""
            let constraint = quotedConstraint.substring(1, -1)
            print("- Adding constraint `\(constraint)` (cleaned from `\(quotedConstraint)`)")
            layout.addConstraint(constraint)
        }
    }
 
    // Adds wrap constraints to a view
    private func processSetWrap(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let viewKey = line.substring(result.rangeAtIndex(2))
        let axisStr = line.substring(result.rangeAtIndex(3))
        
        print("Setting \(axisStr) wrap to view \"\(viewKey)\" in layout `\(variable)`")
        let layout = getLayout(variable)
        
        let view = getView(viewKey)
        
        let axis = axisStr == ".Horizontal" ?
            UILayoutConstraintAxis.Horizontal : UILayoutConstraintAxis.Vertical
        
        layout.setWrapContent(view, axis: axis)
    }

    // Sets text to a label
    private func processSetText(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let text = line.substring(result.rangeAtIndex(2))
        
        let label = getLabel(variable)
        label.text = text
    }

    // Sets text color to a label
    private func processSetTextColor(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let colorName = line.substring(result.rangeAtIndex(2))
        
        let label = getLabel(variable)
        
        label.textColor = getColor(colorName)
    }

    // Sets background color to a view
    private func processSetBackgroundColor(line: String, _ result: NSTextCheckingResult) {
        
        let variable = line.substring(result.rangeAtIndex(1))
        let colorName = line.substring(result.rangeAtIndex(2))
        
        let view = getView(variable)
        
        view.backgroundColor = getColor(colorName)
    }


    private func getLabel(name: String) -> UILabel {
        let view = getView(name)
        if view is UILabel {
            return view as! UILabel
        } else {
            fatalError("View `\(name)` is not a label")
        }
    }

    private func getView(name: String) -> UIView {
        guard let view = views[name] else { fatalError("There's no view with the name `\(name)`") }
        return view
    }

    private func getColor(name: String) -> UIColor {
        guard let color = colors[name] else { fatalError("There's no color with the name `\(name)`") }
        return color
    }

    private func getLayout(name: String) -> LayoutHelper {
        guard let layout = layouts[name] else { fatalError("There's no layout with the name `\(name)`") }
        return layout
    }

    
    // Regular expressions
    
    private func match(regex: NSRegularExpression, str: String) -> NSTextCheckingResult? {
        let results = regex.matchesInString(str, options: NSMatchingOptions(), range: NSMakeRange(0, str.characters.count))
        if results.count == 1 {
            return results[0]
        } else if results.count == 0 {
            return nil
        } else {
            fatalError("Unexpected result count \(results.count) for: \(str)")
        }
    }

    // example: let v1 = UIView()
    private static var letRegex = PreviewController.regex("let +(\(Id)) *= *(\(Id))\\(\\)")
    // example: let label = ViewUtil.labelWithSize(20)
    private static var letLabelRegex = PreviewController.regex("let +(\(Id)) *= *ViewUtil\\.labelWithSize\\((\(Number))\\)")
    // example: let lay = LayoutHelper(view: v1)
    private static var letLayoutRegex = PreviewController.regex("let +(\(Id)) *= *LayoutHelper\\(view: *(\(Id))\\)(?:\\.withRandomColors\\((true|false)\\))?")
    // example: let color = ViewUtil.color(red: 255, green: 0, blue: 150, alpha: 0.7)
    private static var letColorRegex = PreviewController.regex("let +(\(Id)) *= *ViewUtil\\.color\\(red: *(\(Number)), *green: *(\(Number)), *blue: *(\(Number)), *alpha: (\(Number))\\)")
    
    // example: lay.addViews(["t1":t1, "t2":t2]) -- array content must be treated later
    private static var addViewsRegex = PreviewController.regex("(\(Id))\\.addViews\\(\\[(.+)\\]\\)")
    // example: "t1":t1
    private static var keyValueRegex = PreviewController.regex("\"(\(Id))\" *: *(\(Id))")
    // example: lay.addConstraints(["H:|[t1]|", "V:|[t1]|"]) -- array content must be treated later
    private static var addConstraintsRegex = PreviewController.regex("(\(Id))\\.addConstraints\\(\\[(.+)\\]\\)")
    // example: lay.setWrapContent("t2", axis: .Horizontal)
    private static var setWrapRegex = PreviewController.regex("(\(Id))\\.setWrapContent\\(\"(\(Id))\", *axis: *(\\.(Horizontal)|(Vertical))\\)")

    // example: label.text = "hello"
    private static var setTextRegex = PreviewController.regex("(\(Id))\\.text *= *\"(.*)\"")
    // example: label.textColor = color
    private static var setTextColorRegex = PreviewController.regex("(\(Id))\\.textColor *= *(\(Id))")
    // example: view.backgroundColor = color
    private static var setBackgroundColorRegex = PreviewController.regex("(\(Id))\\.backgroundColor *= *(\(Id))")

    
    // identifier pattern (variable, method, class, etc.)
    private static let Id: String = "[_a-zA-Z][_a-zA-Z0-9]+"
    // float number pattern e.g. "12", "12.", "2.56"
    private static let Number: String = "\\d+\\.?\\d*"

    
    private static func regex(pattern: String) -> NSRegularExpression {
        print("Peparing regex: \(pattern)")
        return try! NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions())
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
        
        let main = getLayout("main")
       
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
