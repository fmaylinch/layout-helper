
// This file is ignored in the project
// Load this file in the CodeController, either directly or via url

let color = ViewUtil.color(red: 255, green: 0, blue: 150, alpha: 0.5)
let color2 = ViewUtil.color(red: 20, green: 150, blue: 150, alpha: 0.5)

let t1 = ViewUtil.labelWithSize(20)
t1.text = "wrapped"
t1.textColor = color

let t2 = ViewUtil.labelWithSize(20)
t2.text = "FILL"
t2.backgroundColor = color

let v1 = UIView()
v1.backgroundColor = color2
let lay = LayoutHelper(view: v1)
// .withRandomColors(true)

lay.addViews(["t1":t1, "t2":t2])
lay.addConstraints(["H:|-[t1]-[t2]-|", "V:|-[t1]-|", "V:|-[t2]-|"])
lay.setWrapContent("t1", axis: .Horizontal)

main.addViews(["v1": v1])
main.addConstraints(["H:|-[v1]-|", "V:|-[v1]"])
