
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


let icon = ViewUtil.labelWithSize(1)
icon.text = "Icon"
icon.textColor = whiteColor
icon.textAlignment = .Center
icon.backgroundColor = mainColor

let keywordPicker = ViewUtil.pickerField("Actividades", size: 20, values: values, toolbar: toolbar)
let districtPicker = ViewUtil.pickerField("Barrios", size: 20, values: values, toolbar: toolbar)
let gymPicker = ViewUtil.pickerField("Gimnasios", size: 20, values: values, toolbar: toolbar)

let selector = ViewUtil.labelWithSize(20)
selector.text = "Selector"
selector.textColor = whiteColor
selector.textAlignment = .Center
selector.backgroundColor = mainColor

let slider = ViewUtil.labelWithSize(20)
slider.text = "Slider"
slider.textColor = whiteColor
slider.textAlignment = .Center
slider.backgroundColor = mainColor

let lowerHour = ViewUtil.labelWithSize(20)
lowerHour.text = "6:00h"

let upperHour = ViewUtil.labelWithSize(20)
upperHour.text = "23:00h"

let button = ViewUtil.buttonWithSize(20)
button.title = "FILTRAR"


let lay = LayoutHelper(view:view)
    .withRandomColors(false)
    .addViews(["icon":icon, "selector":selector, "slider":slider])
    .addViews(["keywordPicker":keywordPicker, "districtPicker":districtPicker, "gymPicker":gymPicker])
    .addViews(["lowerHour":lowerHour, "upperHour":upperHour, "button":button])
    .addConstraints(["X:icon.centerX == parent.centerX"])
    .addConstraints(["H:|-[keywordPicker]-|", "H:|-[districtPicker]-|", "H:|-[gymPicker]-|"])
    .addConstraints(["H:|-[selector]-|", "H:|-[slider]-|"])
    .addConstraints(["H:|-[lowerHour]", "H:[upperHour]-|"])
    .addConstraints(["X:button.centerX == parent.centerX"])
    .addConstraints(["V:|-[icon]-[keywordPicker]-[districtPicker]-[gymPicker]-[selector]-[slider]"])
    .addConstraints(["V:[slider]-[lowerHour]-[button]", "V:[slider]-[upperHour]"])
    // these constraints won't be necessary if the views have intrinsic size
    .addConstraints(["H:[icon(50)]", "V:[icon(50)]"])
    .addConstraints(["V:[selector(40)]", "V:[slider(30)]"])

// size 1 is ViewUtil.SizeAuto
//let label = ViewUtil.labelWithSize(40)
//label.text = "This is a sample text"
//label.textColor = blackColor
//label.textAlignment = .Center
//label.backgroundColor = mainColor
//label.layer.cornerRadius = 5
//label.layer.masksToBounds = true
//label.layer.borderWidth = 20
//label.layer.borderColor = blackColor.CGColor

