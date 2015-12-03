
// --- LAYOUT EXAMPLES ---

// Create views (examples below) and add them to mainLayout
mainLayout.addViews(["v": view])
mainLayout.addConstraints(["H:|[v]|", "V:|[v]|"])

// You can also configure the mainView
mainView.backgroundColor = whiteColor


// Statements supported for creating views:

// Colors - must be created like this and then use the variable name
let mainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)

// Views
let view = UIView()
view.backgroundColor = mainColor

// Labels - set size 1 for ViewUtil.SizeAuto
let label = ViewUtil.labelWithSize(20)
label.text = "Message in a label"
label.textColor = blackColor
label.textAlignment = .Center
label.layer.cornerRadius = 5
label.layer.masksToBounds = true
label.layer.borderWidth = 20
label.layer.borderColor = blackColor.CGColor

// Buttons
let button = ViewUtil.buttonWithSize(22)
// convenience property in CustomButton
button.title = "PURCHASE"

// Images - image file must exist, of course
let icon = UIImageView(image: UIImage(named: "events-filter"))

// Pickers - values and toolbar are ignored
let picker = ViewUtil.pickerField("Things", size: 25, values: values, toolbar: toolbar)

// Create layoutHelper
let lay = LayoutHelper(view:view)
    .withRandomColors(false)
    .addViews(["label":label, "picker":picker])
    .addConstraints(["H:|-[picker]-|", "H:|-[label]-|", "V:|-[label]-[picker]"])

