
// Test controller to try layouts

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // logAvailableFonts()

        // Do things here
    }
    
    // http://codewithchris.com/common-mistakes-with-adding-custom-fonts-to-your-ios-app/
    private func logAvailableFonts()
    {
        for family: String in UIFont.familyNames()
        {
            print("\(family)")
            for names: String in UIFont.fontNamesForFamilyName(family)
            {
                print("== \(names)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

