
// Test controller to try layouts

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var content2: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // logAvailableFonts()
        
        // will print cell on content view
        let cell = EventCell(contentView: content, included: true)
        
        cell.activity.text = "Yoga (really really hardcore)".uppercaseString
        cell.gym.text = "Dona 10".uppercaseString
        cell.startTime.text = "11:00"
        cell.endTime.text = "12:00"
        cell.setClubName("CLUB PREMIUM")
        
        
        let cell2 = EventCell(contentView: content2, included: false)
        
        cell2.activity.text = "Yoga (really really hardcore)".uppercaseString
        cell2.gym.text = "Dona 10".uppercaseString
        cell2.startTime.text = "11:00"
        cell2.endTime.text = "12:00"
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

