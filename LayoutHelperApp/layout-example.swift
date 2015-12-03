
// This file is ignored in the project.
// Put the contents of this file in the CodeController text view
// or load this file via http url.

let mainColor = ViewUtil.color(red: 229, green: 105, blue: 108, alpha: 1)
let whiteColor = ViewUtil.color(red: 255, green: 255, blue: 255, alpha: 1)
let blackColor = ViewUtil.color(red: 0, green: 0, blue: 0, alpha: 1)
let lightGreyColor = ViewUtil.color(red: 230, green: 230, blue: 230, alpha: 1)


// --- Event detail layout ---


// -- header --

let date = ViewUtil.labelWithSize(17)
date.text = "NOV 2015"
date.textColor = whiteColor

let calendarDay = UIView()
calendarDay.backgroundColor = mainColor

let activity = ViewUtil.labelWithSize(25)
activity.text = "MUGENDO"
activity.textColor = whiteColor

let desc = ViewUtil.labelWithSize(17)
// TODO: If empty put a space to reserve space
desc.text = "Tonificación"
desc.textColor = whiteColor
desc.adjustsFontSizeToFitWidth = true

let time = ViewUtil.labelWithSize(20)
time.text = "11:00 - 12:00"
time.textColor = whiteColor

let sep = UIView()
sep.backgroundColor = whiteColor

// TODO: may create implicitly with LayoutHelper()
let header = UIView()
header.backgroundColor = blackColor

// TODO: some margins (15) maybe will be default when aligning to controller view
let headerLayout = LayoutHelper(view:header)
    .withRandomColors(true)
    .addViews(["date":date, "day":calendarDay, "time":time, "activity":activity, "desc":desc, "sep":sep])
    .addConstraints(["H:|-(15)-[date]-[sep(1)]-[activity]-(15)-|"])
    .addConstraints(["H:|-(15)-[day(50)]"])
    .addConstraints(["H:[sep]-[desc]-(15)-|"])
    .addConstraints(["H:[sep]-[time]"])
    .addConstraints(["V:|-(15)-[date]-[day(40)]-(15)-|"])
    .addConstraints(["V:|-(15)-[sep]-(15)-|"])
    .addConstraints(["V:|-(15)-[activity]"])
    .addConstraints(["X:desc.top == activity.baseline + 4"])
    .addConstraints(["X:time.baseline == parent.bottom - 15"])
    .setWrapContent("date", axis: .Horizontal)


// place

let gymName = ViewUtil.labelWithSize(25)
gymName.text = "CEM PUTXET"

let address = ViewUtil.labelWithSize(17)
address.text = "Marqués de Argentera, 18 · 08003 Barcelona"
address.numberOfLines = 2
//address.adjustsFontSizeToFitWidth = true

let pin = UIImageView(image: UIImage(named: "gym_map_pin_pink"))

let map = UIView()
map.backgroundColor = mainColor

// TODO: may create implicitly with LayoutHelper()
let place = UIView()

let placeLayout = LayoutHelper(view:place)
    .withRandomColors(false)
    .addViews(["gym":gymName, "address":address, "pin":pin, "map":map])
    .addConstraints(["H:|-[gym]-|", "H:|-[pin(25)]-[address]-|", "H:|[map]|"])
    .addConstraints(["V:|-[gym]-[pin(40)]-(15)-[map]-|"])
    .addConstraints(["X:address.centerY == pin.centerY"])

// button

let button = ViewUtil.buttonWithSize(25)
button.title = "COMPRAR"



// main layout

mainView.backgroundColor = whiteColor
mainLayout.addViews(["header": header, "place":place, "button":button])
mainLayout.addConstraints(["H:|[header]|", "H:|[place]|", "H:|-(40)-[button]-(40)-|"])
mainLayout.addConstraints(["V:|[header]-[place]-[button]-(20)-|"])


