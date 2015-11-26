
// This file is ignored in the project.
// Load the contents of this file in the CodeController, either directly or via url.

let mainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)
let whiteColor = ViewUtil.color(red: 255, green: 255, blue: 255, alpha: 1)
let blackColor = ViewUtil.color(red: 0, green: 0, blue: 0, alpha: 1)

let container = UIView()
container.backgroundColor = whiteColor

let includedView = UIView()
includedView.backgroundColor = mainColor

let check = ViewUtil.labelWithSize(18)
check.text = "V"
check.textColor = whiteColor
check.textAlignment = .Center

let club = ViewUtil.labelWithSize(11)
club.text = "CLUB\nPREMIUM"
club.textColor = whiteColor
club.textAlignment = .Center
club.numberOfLines = 0

let incLay = LayoutHelper(view:includedView)
    .withRandomColors(false)
    .addViews(["check":check, "club":club])
    .addConstraints(["H:|-[check]-|", "H:|-[club]-|"])
    .addConstraints(["V:|-(5)-[check][club]-(5)-|"])
    .setWrapContent("check", axis: .Vertical)

let dummy = ViewUtil.labelWithSize(20)
dummy.text = "dummy2"

let lay = LayoutHelper(view: container)
    .withRandomColors(false)
    .addViews(["dummy":dummy, "inc":includedView])
    .addConstraints(["H:|[dummy][inc]|", "V:|[dummy]|", "V:|[inc]|"])
    .setWrapContent("inc", axis: .Horizontal)

mainView.backgroundColor = blackColor
mainLayout.addViews(["container": container])
mainLayout.addConstraints(["H:|[container]|", "V:|-[container(60)]"])
