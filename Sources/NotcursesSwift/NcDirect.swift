import Foundation
import notcurses

public class NcDirect {
    let ncDirect: OpaquePointer

    public init() {
        ncDirect = ncdirect_init(nil, nil, 0)
    }

    @discardableResult public func stop() -> Bool {
        ncdirect_stop(ncDirect) != -1
    }

    @discardableResult public func setFg(r: UInt8, g: UInt8, b: UInt8) -> Bool {
        ncdirect_set_fg_rgb8(ncDirect, UInt32(r), UInt32(g), UInt32(b)) != -1
    }
    @discardableResult public func setBg(r: UInt8, g: UInt8, b: UInt8) -> Bool {
        ncdirect_set_bg_rgb8(ncDirect, UInt32(r), UInt32(g), UInt32(b)) != -1
    }

    @discardableResult public func setFg(color: Color) -> Bool {
        ncdirect_set_fg_rgb(ncDirect, color.value) != -1
    }
    @discardableResult public func setBg(color: Color) -> Bool {
        ncdirect_set_bg_rgb(ncDirect, color.value) != -1
    }

    @discardableResult public func setFg(rgb: UInt32) -> Bool {
        ncdirect_set_fg_rgb(ncDirect, rgb) != -1
    }
    @discardableResult public func setBg(rgb: UInt32) -> Bool {
        ncdirect_set_bg_rgb(ncDirect, rgb) != -1
    }

    @discardableResult public func putStr(channels: Channels, _ str: String) -> Bool {
        ncdirect_putstr(ncDirect, channels, str) >= 0
    }

    @discardableResult public func putStr(styles: [Style] = [], fg: Color? = nil, bg: Color? = nil, y: Int = -1, x: Int = -1, _ str: String) -> Bool {
        if y != -1 || x != -1 {
            guard cursorMove(y: y, x: x) else { return false }
        }

        let currentStyles = self.styles
        defer {
            self.styles = currentStyles
        }
        self.styles = styles

        return fputs(str, stdout) >= 0
    }
    
    @discardableResult public func cursorMove(y: Int = -1, x: Int = -1) -> Bool {
        ncdirect_cursor_move_yx(ncDirect, Int32(y), Int32(x)) != -1
    }

    public var cursorY: Int {
        get {
            var y: UInt32 = 0
            ncdirect_cursor_yx(ncDirect, &y, nil)
            return Int(y)
        }
    }
    public var cursorX: Int {
        get {
            var x: UInt32 = 0
            ncdirect_cursor_yx(ncDirect, nil, &x)
            return Int(x)
        }
    }

    public var dimY: Int { get { Int(ncdirect_dim_y(ncDirect)) } }
    public var dimX: Int { get { Int(ncdirect_dim_x(ncDirect)) } }

    public var rows: Int { get { dimY } }
    public var columns: Int { get { dimX } }

    @discardableResult public func cursor(y: inout Int, x: inout Int) -> Bool {
        var uy: UInt32 = 0
        var ux: UInt32 = 0
        let returnValue = ncdirect_cursor_yx(ncDirect, &uy, &ux) != -1
        y = Int(uy)
        x = Int(ux)
        return returnValue
    }

    @discardableResult public func cursorUp(times: Int = 1) -> Bool {
        ncdirect_cursor_up(ncDirect, Int32(times)) != -1
    }

    @discardableResult public func cursorDown(times: Int = 1) -> Bool {
        ncdirect_cursor_down(ncDirect, Int32(times)) != -1
    }

    @discardableResult public func cursorLeft(times: Int = 1) -> Bool {
        ncdirect_cursor_left(ncDirect, Int32(times)) != -1
    }

    @discardableResult public func cursorRight(times: Int = 1) -> Bool {
        ncdirect_cursor_right(ncDirect, Int32(times)) != -1
    }

    @discardableResult public func flush() -> Bool {
        ncdirect_flush(ncDirect) != -1
    }

    @discardableResult public func cursorDisable() -> Bool {
        ncdirect_cursor_disable(ncDirect) != -1
    }

    @discardableResult public func cursorEnable() -> Bool {
        ncdirect_cursor_enable(ncDirect) != -1
    }

    public var styles: [Style] {
        get { getStyles() }
        set { _ = setStyles(newValue) }
    }

    public func setStyles(_ styles: [Style]) -> Bool {
        ncdirect_set_styles(ncDirect, UInt32(makeBitMask(from: styles))) != -1
    }

    public func getStyles() -> [Style] {
        Style.enumArrayFromBitMask(mask: ncdirect_styles(ncDirect))
    }
}