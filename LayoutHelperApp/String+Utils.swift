
/** Some util extensions for String */

import Foundation

extension String {
    
    // http://stackoverflow.com/questions/24044851 - substring and ranges
    
    func substring(range: NSRange) -> String {
        return substring(range.location, range.location + range.length)
    }

    func substring(start:Int, _ end:Int) -> String {
        let from = getIndex(start)
        let to = getIndex(end)
        return self[from..<to]
    }
    
    private func getIndex(pos: Int) -> Index {
        return pos >= 0 ? startIndex.advancedBy(pos) : endIndex.advancedBy(pos)
    }
    
    func split(separator: String) -> [String] {
        return componentsSeparatedByString(separator)
    }
}