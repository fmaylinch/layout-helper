
// This file is ignored in the project.
// Load the contents of this file in the CodeController, either directly or via url.

let mainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)
let whiteColor = ViewUtil.color(red: 255, green: 255, blue: 255, alpha: 1)
let blackColor = ViewUtil.color(red: 0, green: 0, blue: 0, alpha: 1)
let lightGreyColor = ViewUtil.color(red: 230, green: 230, blue: 230, alpha: 1)

let view = UIView()
view.backgroundColor = lightGreyColor

mainView.backgroundColor = blackColor
mainLayout.addViews(["container": view])
mainLayout.addConstraints(["H:|[container]|", "V:|[container]|"])

let icon = UIView()
icon.backgroundColor = mainColor

let selector = UIView()
selector.backgroundColor = mainColor

let slider = UIView()
slider.backgroundColor = mainColor

let keywordPicker = ViewUtil.labelWithSize(20)
keywordPicker.text = "Todas las actividades"
keywordPicker.backgroundColor = whiteColor
keywordPicker.layer.cornerRadius = 5
keywordPicker.layer.masksToBounds = true

let lay = LayoutHelper(view:view)
    .withRandomColors(false)
    .addViews(["icon":icon, "keywordPicker":keywordPicker, "selector":selector, "slider":slider])
    .addConstraints(["X:icon.centerX == parent.centerX"])
    .addConstraints(["H:|-[keywordPicker]-|", "H:|-[selector]-|", "H:|-[slider]-|"])
    .addConstraints(["V:|-[icon]-[keywordPicker]-[selector]-[slider]"])
    // these constraints won't be necessary if the views have intrinsic size
    .addConstraints(["V:[keywordPicker(40)]"])
    .addConstraints(["H:[icon(50)]", "V:[icon(50)]"])
    .addConstraints(["V:[selector(40)]", "V:[slider(40)]"])

// 10000 is ViewUtil.SizeAuto
//let label = ViewUtil.labelWithSize(40)
//label.text = "This is a sample text"
//label.textColor = blackColor
//label.textAlignment = .Center
//label.backgroundColor = mainColor
//label.layer.cornerRadius = 5
//label.layer.masksToBounds = true
//label.layer.borderWidth = 20
//label.layer.borderColor = blackColor.CGColor

