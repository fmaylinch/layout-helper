
#LayoutHelperApp

This is a experimental app to play with programmatic autolayout.

You can build your layout using the supported statements (see [examples](https://github.com/fmaylinch/layout-helper/blob/master/LayoutHelperApp/layout-statement-examples.swift)).

## Utility classes

Here you will find utility classes like [LayoutHelper](https://github.com/fmaylinch/layout-helper/blob/master/LayoutHelperApp/LayoutHelper.swift). You can take it and use it in your projects like this:

    let label1 = UILabel()
    let label2 = UILabel()
    let container = UIView()

    let layout = LayoutHelper(view: container)
        .withRandomColors(true) // for debugging
        .withMetrics(["m":Margin])
        .addViews(["lbl1":label1, "lbl2":label2])
        .addConstraints([
            "H:|-[lbl1]-[lbl2]-|",
            "V:|-[lbl1]-|",
            "V:|-[lbl2]-|",
            "X:lbl1.width == parent.width / 4"
            ])

The last constraint, `"X:lbl1.width == parent.width / 4"`, is a special extended constraint supported by `LayoutHelper`. Its format is:

    X:view1.attr1 ==|<=|>= view2.attr2 *|/ multiplier +|- constant

- For the views, you can use any view key as in the usual constraints, or the reserved `parent` key to refer to the parent (container) view.
- For the attributes, you can use any [NSLayoutAttribute](https://developer.apple.com/library/ios/documentation/AppKit/Reference/NSLayoutConstraint_Class/#//apple_ref/c/tdef/NSLayoutAttribute).
- For the `multiplier` or `constant` (both optional) you can use a float or a metric key.
