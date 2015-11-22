
import UIKit

class CodeController : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var codeTextView: UITextView!
    
    private var barButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        codeTextView.delegate = self
        
        self.barButton =
            UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("dismissKeyboard"))
    }
    
    
    // UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        print("text did begin editing")
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("text did end editing")
        self.navigationItem.rightBarButtonItem = nil
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Going to \(segue.identifier!)")
        let controller = segue.destinationViewController as! PreviewController
        controller.code = codeTextView.text
    }
    
    func dismissKeyboard() {
        print("dismiss keyboard")
        codeTextView.resignFirstResponder()
    }
}
