
// This file is ignored in the project.
// Load the contents of this file in the CodeController, either directly or via url.

let mainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)
let whiteColor = ViewUtil.color(red: 255, green: 255, blue: 255, alpha: 1)
let blackColor = ViewUtil.color(red: 0, green: 0, blue: 0, alpha: 1)

let container = UIView()
container.backgroundColor = whiteColor

// 10000 is ViewUtil.SizeAuto
let label = ViewUtil.labelWithSize(10000)
label.text = "20"
label.textColor = blackColor
label.textAlignment = .Center
label.backgroundColor = mainColor
//label.layer.cornerRadius = 5
//label.layer.masksToBounds = true
//label.layer.borderWidth = 20
//label.layer.borderColor = blackColor.CGColor

let lay = LayoutHelper(view:container)
    .withRandomColors(false)
    .addViews(["label":label])
    .addConstraints(["H:|-[label(150)]-|", "V:|-[label(250)]-|"])

mainView.backgroundColor = blackColor
mainLayout.addViews(["container": container])
mainLayout.addConstraints(["H:|[container]", "V:|-[container]"])
