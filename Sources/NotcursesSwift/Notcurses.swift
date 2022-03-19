import Foundation
import notcurses

public struct Color {
    public static let red = Color(red: 255, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 255, blue: 0)
    public static let blue = Color(red: 0, green: 0, blue: 255)

    public static let white = Color(red: 255, green: 255, blue: 255)
    public static let lightGrey = Color(red: 192, green: 192, blue: 192)
    public static let grey = Color(red: 127, green: 127, blue: 127)
    public static let darkGrey = Color(red: 64, green: 64, blue: 64)
    public static let black = Color(red: 0, green: 0, blue: 0)

    let value: UInt32

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        value = (UInt32(red) << 16) + (UInt32(green) << 8) + UInt32(blue)
    }

    public init(value: UInt32) {
        self.value = value
    }
}

public enum Align: UInt32 {
    case unaligned = 0
    case left = 1
    case center = 2
    case right = 3

    func getNativeValue() -> ncalign_e {
        ncalign_e(rawValue)
    }
}

public enum Key: UInt32 {
    case tab = 0x09
    case esc = 0x1b
    case space = 0x20

    case j = 0x6a
    case k = 0x6b
    case q = 0x71

    case invalid = 1115000
    case resize = 1115001
    case up = 1115002
    case right = 1115003
    case down = 1115004
    case left = 1115005

    case enter = 1115121

    case motion = 1115200
    case button1 = 1115201
    case button2 = 1115202
    case button3 = 1115203
    case button4 = 1115204 // scrollwheel up
    case button5 = 1115205 // scrollwheel down
    case button6 = 1115206
    case button7 = 1115207
    case button8 = 1115208
    case button9 = 1115209
    case button10 = 1115210
    case button11 = 1115211
    case button12 = 1115212
}

public struct InputEvent {
    public var key: Key { get { Key(rawValue: nativeValue.id) ?? .invalid } }
    public var x: Int { get { Int(nativeValue.x) } }
    public var y: Int { get { Int(nativeValue.y) } }
    public var utf8: (CChar, CChar, CChar, CChar, CChar) { get { nativeValue.utf8 } }
    public var alt: Bool { get { nativeValue.alt } }
    public var shift: Bool { get { nativeValue.shift } }
    public var ctrl: Bool { get { nativeValue.ctrl } }
    public var type: EventType { get { EventType(rawValue: nativeValue.evtype.rawValue) ?? .unknown} }
    public var ypx: Int { get { Int(nativeValue.ypx) } }
    public var xpx: Int { get { Int(nativeValue.xpx) } }

    let nativeValue: ncinput

    init(nativeValue: ncinput) {
        self.nativeValue = nativeValue
    }
}

public enum EventType: UInt32 {
    case unknown = 0
    case press = 1
    case _repeat = 2
    case release = 3
}

public enum Alpha: UInt32 {
    case opaque = 0x00000000
    case blend = 0x10000000
    case transparent = 0x20000000
    case highcontrast = 0x30000000
}

public enum Style: UInt16, CaseIterable {
    case none = 0x0000
    case struck = 0x0001
    case bold = 0x0002
    case undercurl = 0x0004
    case underline = 0x0008
    case italic = 0x0010
}

public enum NotcursesOptionsFlags: UInt32, CaseIterable {
    case InhibitSetlocale = 0x0001
    case NoClearBitmaps = 0x0002
    case NoWinchSighandler = 0x0004
    case NoQuitSighandlers = 0x0008
    case PreserveCursor = 0x0010
    case SuppressBanners = 0x0020
    case NoAlternateScreen = 0x0040
    case NoFontChanges = 0x0080
    case DrainInput = 0x0100
}

func makeBitMask<T: RawRepresentable>(from: [T]) -> UInt16 where T.RawValue == UInt16 {
    from.reduce(0, { m, n in m + n.rawValue })
}
func makeBitMask<T: RawRepresentable>(from: [T]) -> UInt32 where T.RawValue == UInt32 {
    from.reduce(0, { m, n in m + n.rawValue })
}
func makeBitMask<T: RawRepresentable>(from: [T]) -> UInt64 where T.RawValue == UInt64 {
    from.reduce(0, { m, n in m + n.rawValue })
}

extension CaseIterable where Self: RawRepresentable, Self.RawValue == UInt16 {
    public static func enumArrayFromBitMask(mask: UInt16) -> [Self] {
        Self.allCases.filter { mask & $0.rawValue > 0 }
    }
}
extension CaseIterable where Self: RawRepresentable, Self.RawValue == UInt32 {
    public static func enumArrayFromBitMask(mask: UInt32) -> [Self] {
        Self.allCases.filter { mask & $0.rawValue > 0 }
    }
}


public class Notcurses {
    let nc: OpaquePointer
    public lazy var stdPlane: Plane = {
        Plane(notcurses_stdplane(nc))
    }()
//    {
//        get {
//            if let plane = stdPlane {
//                return plane
//            } else {
//                stdPlane = Plane(notcurses_stdplane(nc))
//                return stdPlane!
//            }
//        }
//    }

    ///
    /// - SeeAlso: notcurses_init
    public init(flags: [NotcursesOptionsFlags]) {
        let flagsMask = makeBitMask(from: flags)
//        flagsMask = NCOPTION_NO_ALTERNATE_SCREEN | NCOPTION_PRESERVE_CURSOR | NCOPTION_SUPPRESS_BANNERS
//        flagsMask = 0
        var options = notcurses_options.init(termtype: nil, loglevel: NCLOGLEVEL_ERROR, margin_t: 0, margin_r: 0, margin_b: 0, margin_l: 0, flags: UInt64(flagsMask))
        nc = notcurses_init(&options, nil)
        notcurses_mice_enable(nc, UInt32(NCMICE_ALL_EVENTS))
    }

    ///
    /// Stop
    /// - SeeAlso: notcurses_stop
    public func stop() {
        notcurses_stop(nc)
    }

//    public func stdPlane() -> Plane {
//
//    }

//    public func stddimYx(y: inout UInt32, x: inout UInt32) -> Plane {
//        Plane(notcurses_stddim_yx(nc, &y, &x))
//    }

    ///
    /// - SeeAlso: notcurses_get_blocking
    public func getBlocking() -> UInt32 {
        notcurses_get_blocking(nc, nil)
    }

    ///
    /// - SeeAlso: notcurses_inputready_fd
    /// - Returns:
    public func inputReadyHandle() -> FileHandle {
        FileHandle(fileDescriptor: notcurses_inputready_fd(nc))
    }

    ///
    /// - SeeAlso: notcurses_get_blocking
    /// - Returns:
    public func getBlocking() -> (Key, InputEvent) {
        var ncInput = ncinput()
        let c = notcurses_get_blocking(nc, &ncInput)
        let key = Key.init(rawValue: c) ?? .invalid
        let event = InputEvent(nativeValue: ncInput)
        return (key, event)
    }

    /// - SeeAlso: notcurses_get_nblock
    public func getNonBlocking() -> (Key, InputEvent)? {
        var ncInput = ncinput()
        let c = notcurses_get_nblock(nc, &ncInput)
        guard c != 0 else { return nil }

        let key = Key.init(rawValue: c) ?? .invalid
        let event = InputEvent(nativeValue: ncInput)
        return (key, event)
    }

    ///
    /// - SeeAlso: notcurses_render
    public func render() {
        notcurses_render(nc)
    }

    public func strWidth(_ str: String) -> Int {
        Int(ncstrwidth(str, nil, nil))
    }

    ///
    /// - SeeAlso: notcurses_canopen_images
    /// - Returns:
    public func canOpenImages() -> Bool {
        notcurses_canopen_images(nc)
    }

    ///
    /// - SeeAlso: notcurses_mice_enable
    /// - Returns:
    public func miceEnable() -> Bool {
        // TODO better mask
        notcurses_mice_enable(nc, 0x7) == 0
    }

    ///
    /// - SeeAlso: notcurses_mice_disable
    /// - Returns:
    public func miceDisable() -> Bool {
        notcurses_mice_disable(nc) == 0
    }

    ///
    /// - SeeAlso: notcurses_cursor_yx
    /// - Parameters:
    ///   - y:
    ///   - x:
    public func getCursor(y: inout Int, x: inout Int) {
        // TODO return?
        // TODO no temp vars?
        var uy: Int32 = 0
        var ux: Int32 = 0
        notcurses_cursor_yx(nc, &uy, &ux)
        y = Int(uy)
        x = Int(ux)
    }

    ///
    /// - SeeAlso: notcurses_cursor_enable
    /// - Parameters:
    ///   - y:
    ///   - x:
    public func setCursor(y: Int, x: Int) {
        notcurses_cursor_enable(nc, Int32(y), Int32(x))
    }

    ///
    /// - SeeAlso: notcurses_cursor_enable
    /// - Returns:
    public func cursorEnable() -> Bool {
        var y = 0
        var x = 0
        getCursor(y: &y, x: &x)
        return notcurses_cursor_enable(nc, Int32(y), Int32(x)) == 0
    }

    ///
    /// - SeeAlso: notcurses_at_yx
    /// - Parameters:
    ///   - y:
    ///   - x:
    ///   - styles:
    ///   - channels:
    public func at(y: Int, x: Int, styles: inout [Style], channels: inout Channels) {
        var stylesInt: UInt16 = 0
        notcurses_at_yx(nc, UInt32(y), UInt32(x), &stylesInt, &channels)
        styles = Style.enumArrayFromBitMask(mask: stylesInt)
    }
}
