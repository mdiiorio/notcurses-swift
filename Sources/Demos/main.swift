import Foundation
import NotcursesSwift

var selector: NotcursesSwift.Selector?

let demos: [(String, Demo)] = [
    (desc: "Text           ", instance: TextDemo()),
    (desc: "Plane          ", instance: PlaneDemo())
]

func drawSelector() {
    var options = [NotcursesSwift.Selector.Item]()

    for (index, (desc, _)) in demos.enumerated() {
        options.append(Selector.Item(option: String(index), desc: desc))
    }

    let selectorOptions = Selector.Options(
        secondary: "[ Select Demo ]",
        items: options,
        defaultIndex: 0,
        opChannels: Channels(.darkGrey, .black),
        descChannels: Channels(.white, .black),
        boxChannels: Channels(.grey, .black))
    selector = Selector(plane: selectorPlane, options: selectorOptions)
}

func getSelectedDemoIndex() -> Int {
    if let selected = selector?.selected(),
       let index = Int(selected),
       index < demos.count {
        return index
    } else {
        return 0
    }
}

func runDemo(index: Int) {
    content.erase()
    let (_, demoInstance) = demos[index]
    demoInstance.runDemo(in: content)
}

func handleInput(key: Key, event: InputEvent) {
    switch key {
    case .q:
        nc.stop()
        exit(0)
    case .up, .k:
        let selectedIndex = getSelectedDemoIndex()
        if selectedIndex > 0 {
            selector?.prevItem()
            runDemo(index: selectedIndex - 1)
        }
    case .down, .j:
        let selectedIndex = getSelectedDemoIndex()
        if selectedIndex < demos.count - 1 {
            selector?.nextItem()
            runDemo(index: selectedIndex + 1)
        }
    default:
        break
    }

    nc.render()
}

let nc = Notcurses(flags: [])

nc.stdPlane.erase()

let screenCols = nc.stdPlane.columns
let screenRows = nc.stdPlane.rows
let borderWidth = 3

let left = " NotcursesSwift Demo"
let right = "Movement: ↑ ↓  Select: <enter>  Quit: q "
let middle = String(repeating: " ", count: screenCols - left.count - right.count)
nc.stdPlane.putStr(fg: .white, bg: .blue, y: 0, x: 0, left + middle + right)

let selectorPlane = Plane(parent: nc.stdPlane, y: borderWidth + 1, x: borderWidth, rows: 10, columns: 35)
var opaqueChan: Channels = 0
setBgAlpha(forChannels: &opaqueChan, .opaque)
setFgAlpha(forChannels: &opaqueChan, .opaque)
selectorPlane.setBase(egc: " ", styles: [], channels: opaqueChan)

let contentBorder = Plane(
    parent: nc.stdPlane,
    y: borderWidth + 1, x: selectorPlane.rightX,
    rows: screenRows - (2 * borderWidth), columns: screenCols - (selectorPlane.rightX + borderWidth) - borderWidth)
contentBorder.perimeterRoundedBox()

let content = Plane(
    parent: contentBorder,
    y: 1, x: 1,
    rows: contentBorder.rows - 2, columns: contentBorder.columns - 2)

drawSelector()

runDemo(index: 0)

nc.render()

nc.startRunLoop(inputHandler: handleInput)

