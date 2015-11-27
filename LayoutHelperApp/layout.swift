
// This file is ignored in the project.
// Load the contents of this file in the CodeController, either directly or via url.

let mainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)
let whiteColor = ViewUtil.color(red: 255, green: 255, blue: 255, alpha: 1)
let blackColor = ViewUtil.color(red: 0, green: 0, blue: 0, alpha: 1)

let container = UIView()
container.backgroundColor = whiteColor

let label = ViewUtil.labelWithSize(0)
label.text = "Some text"
label.textColor = whiteColor
label.textAlignment = .Center
label.backgroundColor = blackColor
//label.layer.cornerRadius = 10
//label.layer.masksToBounds = true
label.layer.borderWidth = 30
label.layer.borderColor = mainColor.CGColor

let lay = LayoutHelper(view:container)
    .withRandomColors(false)
    .addViews(["label":label])
    .addConstraints(["H:|-[label(300)]-|", "V:|-[label(150)]-|"])

mainView.backgroundColor = blackColor
mainLayout.addViews(["container": container])
mainLayout.addConstraints(["H:|[container]", "V:|-[container]"])
