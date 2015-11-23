
/** Result of a regex matching */

import Foundation

class RegexResult {
    
    let result : NSTextCheckingResult
    let str : String
    
    init(str: String, result: NSTextCheckingResult) {
        self.str = str
        self.result = result
    }
    
    func group(num: Int) -> String? {
        
        let range = result.rangeAtIndex(num)
        if range.location != NSNotFound {
            return str.substring(range)
        } else {
            return nil
        }
    }
    
    func groupAsInt(num: Int) -> Int? {
        if let g = group(num) {
            return (g as NSString).integerValue
        } else {
            return nil
        }
    }

    func groupAsFloat(num: Int) -> Float? {
        if let g = group(num) {
            return (g as NSString).floatValue
        } else {
            return nil
        }
    }
}
