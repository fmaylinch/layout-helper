
/** Creating the Event cell */

import UIKit

public class EventCell /* : UITableViewCell */ {
    
    let randomColors = false
    
    let activity = ViewUtil.labelWithSize(21)
    let startTime = ViewUtil.labelWithSize(19)
    let endTime = ViewUtil.labelWithSize(19)
    let gym = ViewUtil.labelWithSize(17)
    private var club : UILabel!
    private var includedView : UIView! // display only if activity is included

    public init(contentView: UIView, included:Bool) { // TODO: UITableViewCell init
        
        let mainView = createMainView()
        
        // Not all constraints are added here, because they depend on
        // whether the includedView should be displayed or not
        let layout = LayoutHelper(view: contentView)
            .addViews(["main":mainView])
            .addConstraints(["H:|[main]", "V:|[main]|"])
        
        if included {
            includedView = createIncludedView()
            layout
                .addViews(["inc": includedView])
                .addConstraints(["H:[main][inc]|", "V:|[inc]|"])
                .setWrapContent("inc", axis: .Horizontal)
        } else {
            layout.addConstraint("H:[main]|")
        }
    }
    
    public func setClubName(name: String) {
        
        guard let club = club else { return } // should not set club name when event is not included
        
        // TODO: either I split clubName manually, or I set a fixed width for the includedView
        // http://stackoverflow.com/questions/33844586/hugging-and-resistance-so-multi-line-label-wraps-its-content
        let splitName = name.stringByReplacingOccurrencesOfString(" ", withString: "\n",
            options: .LiteralSearch, range: nil)

        club.text = splitName
    }
    
    /** Main part, with time, activity and gym */
    private func createMainView() -> UIView {
        
        let time = LayoutHelper()
            .withRandomColors(randomColors)
            .addViews(["start":startTime, "end":endTime, "sep":separatorView()])
            .addConstraints([
                "H:|[start]|", "H:|[end]|", "H:[sep(20)]",
                "V:|[start]", "V:[end]|", "V:[sep(1)]",
                "X:sep.centerX == superview.centerX", "X:sep.centerY == superview.centerY"])
            .view
        
        let details = LayoutHelper()
            .withRandomColors(randomColors)
            .addViews(["activity":activity, "gym":gym])
            .addConstraints([
                "H:|[activity]|", "H:|[gym]|",
                "V:|[activity]", "V:[gym]|"])
            .view
        
        let main = LayoutHelper()
            .withRandomColors(randomColors)
            .addViews(["t":time, "d":details, "sep":separatorView()])
            .addConstraints([
                "H:|-[t]-[sep(1)]-[d]-|",
                "V:|-[t]-|", "V:|-[sep]-|", "V:|-[d]-|"])
            .setWrapContent("t", axis: .Horizontal)
            .view
        
        return main
    }
    
    /** optional right part, indicating whether the activity is included in the club */
    private func createIncludedView() -> UIView
    {
        let includedView = UIView()
        includedView.backgroundColor = ViewUtil.MainColor
        
        let FA_Check = "\u{f00c}" // TODO remove
        let check = ViewUtil.labelAwesome(FA_Check, size:20, color:UIColor.whiteColor())
        check.textAlignment = .Center
        
        club = ViewUtil.labelWithSize(11, color: UIColor.whiteColor())
        club.numberOfLines = 0
        club.textAlignment = .Center
        
        LayoutHelper(view:includedView)
            .withRandomColors(randomColors)
            .addViews(["check":check, "club":club])
            .withMetrics(["m":5])
            .addConstraints([
                "H:|-[check]-|", "H:|-(m)-[club]-(m)-|",
                "V:|[check][club]|",
                "X:check.height == club.height"])
        
        return includedView
    }
    
    private func separatorView() -> UIView {
        let result = UIView()
        result.backgroundColor = ViewUtil.DefaultTextColor
        return result
    }
}

