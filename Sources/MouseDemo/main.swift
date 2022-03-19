import Foundation
import NotcursesSwift
import notcurses

public func debug(_ str: String) {
    fputs(str, stderr)
    fputs("\n", stderr)
}

let nc = Notcurses(flags: [])
nc.miceEnable()

//let topView = View.getTopView(nc: nc)
var mousePressed: Bool = false

let icon = Visual(file: "/Users/doo/Code/notcurses-swift/pos-icon.png")!
//let iconPlane = Plane(parent: plane, options: Plane.Options(y: 2, x: 2, rows: 12, columns: 12))
let bgp = icon.blit(nc: nc, options: Visual.Options(plane: nc.stdPlane, scaling: .scaleHiRes, blitter: .pixel, flags: [.childPlane, .blend]))
//bgp.greyscale()

var ch = createChannels(fg: .black, bg: .black)
debug("\(ch) \(String(ch, radix: 2))")
debug("\(ncchannels_bg_alpha(ch))")
debug("\(setBgAlpha(forChannels: &ch, .transparent)) \(Alpha.transparent.rawValue)")
debug("\(ncchannels_bg_alpha(ch))")
debug("\(ch) \(String(ch, radix: 2))")

let m = Plane(parent: nc.stdPlane, y: 5, x: 5, rows: 10, columns: 10)
var h = createChannels(fg: .white, bg: .black)
setFgAlpha(forChannels: &h, .blend)
setBgAlpha(forChannels: &h, .blend)
m.setBase(egc: "A", styles: [], channels: h)


let lightGreen = Color(red: 0x40, green: 0x40, blue: 0x40)
var channels = createChannels(fg: lightGreen, bg: lightGreen)
setFgAlpha(forChannels: &channels, .blend)
setBgAlpha(forChannels: &channels, .blend)
let top = Plane(parent: nc.stdPlane, y: 10, x: 10, rows: 15, columns: 40)
top.setBase(egc: "", styles: [], channels: channels)

//let paletteView = View(parent: topView)
//paletteView.setBorder(visible: true)
//paletteView.setSize(rows: 9, cols: 9)
//paletteView.move(y: 3, x: 3)
//
//paletteView.putStr("📻", y: 1, x: 1)
//paletteView.putStr("🥎", y: 1, x: 4)
//paletteView.putStr("hey", y: 3, x: 1)
//
//

func handleInput(key: Key, event: InputEvent) {
//    topView.draw(isFocused: true)

//    let (key, event) = nc.getNonBlocking()

//    if (mousePressed) {
//        topView.putStr("X", y: event.y, x: event.x)
//    }

//    fputs("\(key) \(event.x), \(event.y) \(event.type)\n", stderr)

    switch key {
    case .q:
        nc.stop()
        exit(0)
        break
    case .button1:
        mousePressed = (event.type == .press)
        break
    default:
        break
    }

    nc.render()
}

var token: NSObjectProtocol?
token = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: nil, queue: OperationQueue.main) { note in
    while let (key, event) = nc.getNonBlocking() {
        handleInput(key: key, event: event)
    }

    nc.inputReadyHandle().waitForDataInBackgroundAndNotify()
}

nc.inputReadyHandle().waitForDataInBackgroundAndNotify()

nc.render()

CFRunLoopRun()