import Foundation
import notcurses

public class Plane {
    class WeakPlaneRef {
        weak var plane: Plane?
    }

    static var planeMap = [OpaquePointer: WeakPlaneRef]()

    static let InvalidPlaneMarker = OpaquePointer(UnsafeMutablePointer<Int>.allocate(capacity: 1))

    var _ncPlane: OpaquePointer?
    var ncPlane: OpaquePointer! {
        get {
            if _ncPlane == nil {
                fatalError("Tried to access an unset ncPlane")
            } else if _ncPlane == Plane.InvalidPlaneMarker {
                fatalError("Tried to access an invalidated ncPlane")
            } else {
                return _ncPlane!
            }
        }
        set {
            if _ncPlane != nil && newValue != Plane.InvalidPlaneMarker {
                fatalError("Tried to set an already assigned ncPlane")
            } else {
                _ncPlane = newValue
            }
        }
    }

    private var ownerOfNcPlane: Bool = true

    func relinquishPlaneOwnership() {
        ownerOfNcPlane = false
    }

    var isNativePlaneValid: Bool {
        _ncPlane != nil && _ncPlane != Plane.InvalidPlaneMarker
    }

    public var absY: Int {
        get { Int(ncplane_abs_y(ncPlane)) }
    }
    public var absX: Int {
        get { Int(ncplane_abs_x(ncPlane)) }
    }

    public func contains(y: Int, x: Int) -> Bool {
        false
    }

    public func absContains(y: Int, x: Int) -> Bool {
        var planeAbsY: Int32 = 0
        var planeAbsX: Int32 = 0
        ncplane_abs_yx(ncPlane, &planeAbsY, &planeAbsX)
        var planeDimY: UInt32 = 0
        var planeDimX: UInt32 = 0
        ncplane_dim_yx(ncPlane, &planeDimY, &planeDimX)
        return y >= planeAbsY && y < planeAbsY + Int32(planeDimY) && x >= planeAbsX && x < planeAbsX + Int32(planeDimX)
    }

    public var y: Int {
        get { Int(ncplane_y(ncPlane)) }
    }
    public var x: Int {
        get { Int(ncplane_x(ncPlane)) }
    }

    // TODO do these make sense? parent x/y or our x/y?
    public var bottomY: Int {
        get { y + rows - 1 }
    }
    public var rightX: Int {
        get { x + columns - 1 }
    }

    public var cursorX: Int {
        get {
            var x: UInt32 = 0
            ncplane_cursor_yx(ncPlane, nil, &x)
            return Int(x)
        }
    }
    public var cursorY: Int {
        get {
            var y: UInt32 = 0
            ncplane_cursor_yx(ncPlane, &y, nil)
            return Int(y)
        }
    }

    public var channels: Channels {
        get {
            ncplane_channels(ncPlane)
        }
        set {
            ncplane_set_channels(ncPlane, newValue)
        }
    }

    public var scrolling: Bool {
        get { ncplane_scrolling_p(ncPlane) }
        set { ncplane_set_scrolling(ncPlane, newValue ? 1 : 0) }
    }

    public var rows: Int {
        get { Int(ncplane_dim_y(ncPlane)) }
    }
    public var columns: Int {
        get { Int(ncplane_dim_x(ncPlane)) }
    }

    init(_ ncPlane: OpaquePointer!) {
        self.ncPlane = ncPlane
        let weakRef = WeakPlaneRef()
        weakRef.plane = self
        Plane.planeMap[ncPlane] = weakRef
    }

    deinit {
        guard isNativePlaneValid && ownerOfNcPlane else { return }
        ncplane_destroy(ncPlane)
    }

    public required init(parent: Plane, options: Plane.Options = Plane.Options()) {
        var nativeOptions = options.nativeValue
        ncPlane = ncplane_create(parent.ncPlane, &nativeOptions)
        let weakRef = WeakPlaneRef()
        weakRef.plane = self
        Plane.planeMap[ncPlane] = weakRef
    }

    public convenience init(parent: Plane, y: Int, x: Int, rows: Int, columns: Int) {
        let options = Plane.Options(y: y, x: x, rows: rows, columns: columns)
        self.init(parent: parent, options: options)
    }

    public static func makeMarginalized(
        parent: Plane,
        top: Int = 0,
        left: Int = 0,
        bottom: Int = 0,
        right: Int = 0,
        flags: [Flag] = [])
    {
        let newFlags = flags + [Flag.marginalized]

        let options = Plane.Options(
            y: top,
            x: left,
            rows: 0,
            columns: 0,
            flags: newFlags,
            marginBottom: bottom,
            marginRight: right
        )
        self.init(parent: parent, options: options)
    }

    static func getCachedPlane(ncPlane: OpaquePointer) -> Plane {
        // TODO not sure there could be a reference in the map with a null'ed out weak ref? But handle it for now by
        // making a new Plane.
        if let cached = planeMap[ncPlane], let plane = cached.plane {
            return plane
        } else {
            return Plane(ncPlane)
        }
    }

    public func invalidateNativePlane() {
        Plane.planeMap[ncPlane] = nil
        ncPlane = Plane.InvalidPlaneMarker
    }

    public func cursorMove(y: Int, x: Int) {
        ncplane_cursor_move_yx(ncPlane, Int32(y), Int32(x))
    }

    public func move(y: Int, x: Int) {
        ncplane_move_yx(ncPlane, Int32(y), Int32(x))
    }

    public func moveTop() {
        ncplane_move_top(ncPlane)
    }

    public func moveBottom() {
        ncplane_move_bottom(ncPlane)
    }

    public func resize(rows: Int, cols: Int) {
        ncplane_resize_simple(ncPlane, UInt32(rows), UInt32(cols))
    }

    public func erase() {
        ncplane_erase(ncPlane)
    }

    public func eraseRegion(y: Int, x: Int, height: Int, length: Int) {
        ncplane_erase_region(ncPlane, Int32(y), Int32(x), Int32(height), Int32(length))
    }

    public func box(yStop: Int, xStop: Int) {
        var channels: UInt64 = 0
        ncchannels_set_fg_rgb8(&channels, 255, 255, 255)
        ncplane_rounded_box(ncPlane, 0, channels, UInt32(yStop), UInt32(xStop), 0)
    }

    public func roundedBox(styles: [Style], channels: Channels, yStop: Int, xStop: Int, ctlWord: Int) {
        ncplane_rounded_box(ncPlane, makeBitMask(from: styles), channels, UInt32(yStop), UInt32(xStop), UInt32(ctlWord))
    }

    public func perimeterRoundedBox(color: Color = .white) {
        var channels: UInt64 = 0
        ncchannels_set_fg_rgb(&channels, color.value)
        cursorMove(y: 0, x: 0)
        var rows: UInt32 = 0
        var cols: UInt32 = 0
        ncplane_dim_yx(ncPlane, &rows, &cols)
        ncplane_rounded_box(ncPlane, 0, channels, rows - 1, cols - 1, 0)
    }

    public func scrollUp(times: Int = 1) {
        ncplane_scrollup(ncPlane, Int32(times))
    }

    @discardableResult public func putStr(_ str: String) -> Int {
        Int(ncplane_putstr(ncPlane, str))
    }

    @discardableResult public func putStr(y: Int, x: Int, _ str: String) -> Int {
        Int(ncplane_putstr_yx(ncPlane, Int32(y), Int32(x), str))
    }

    @discardableResult public func putStr(styles: [Style] = [], fg: Color? = nil, bg: Color? = nil, y: Int = -1, x: Int = -1, _ str: String) -> Int {
        let currentChannels = channels
        let currentStyles = self.styles()

        if let fg = fg {
            fgRgb = fg
        }
        if let bg = bg {
            bgRgb = bg
        }

        setStyles(styles)

        defer {
            setChannels(currentChannels)
            setStyles(currentStyles)
        }

        return Int(ncplane_putstr_yx(ncPlane, Int32(y), Int32(x), str))
    }

    public func putStrAligned(y: Int?, align: Align, _ str: String) {
        ncplane_putstr_aligned(ncPlane, Int32(y ?? -1), align.nativeValue, str)
    }

    public func putStrAligned(_ str: String) {
        ncplane_putstr_stained(ncPlane, str)
    }

    public var fgRgb: Color {
        get { Color(value: ncplane_fg_rgb(ncPlane)) }
        set { ncplane_set_fg_rgb(ncPlane, newValue.value) }
    }
    public func setFgRgb(color: Color) -> Bool {
        ncplane_set_fg_rgb(ncPlane, color.value) != -1
    }
    public func setFgRgb(value: UInt32) -> Bool {
        ncplane_set_fg_rgb(ncPlane, value) != -1
    }

    public var bgRgb: Color {
        get { Color(value: ncplane_bg_rgb(ncPlane)) }
        set { ncplane_set_bg_rgb(ncPlane, newValue.value) }
    }
    public func setBgRgb(color: Color) -> Bool {
        ncplane_set_bg_rgb(ncPlane, color.value) != -1
    }
    public func setBgRgb(value: UInt32) -> Bool {
        ncplane_set_bg_rgb(ncPlane, value) != -1
    }

    public func setForegroundAlpha(alpha: Alpha) {
        ncplane_set_fg_alpha(ncPlane, Int32(alpha.rawValue))
    }

    public func greyscale() {
        ncplane_greyscale(ncPlane)
    }

    public func setStyles(_ styles: [Style]) {
        ncplane_set_styles(ncPlane, UInt32(makeBitMask(from: styles)))
    }

    public func styles() -> [Style] {
        Style.enumArrayFromBitMask(mask: UInt16(ncplane_styles(ncPlane)))
    }

    public func resizeMarginalized() {
        ncplane_resize_marginalized(ncPlane)
    }

    public func setChannels(_ channels: Channels) {
        ncplane_set_channels(ncPlane, channels)
    }

    public func reverseChannels() {
        ncplane_set_channels(ncPlane, ncchannels_reverse(ncplane_channels(ncPlane)))
    }

    @discardableResult public func setBase(egc: String = "\u{0}", styles: [Style] = [], channels: Channels) -> Bool {
        ncplane_set_base(ncPlane, strdup(egc), UInt16(makeBitMask(from: styles)), channels) != -1
    }

    @discardableResult public func setBaseCell(_ cell: Cell) -> Bool {
        ncplane_set_base_cell(ncPlane, cell.ncCell) != -1
    }

    public func gradient(y: Int, x: Int, yLen: Int, xLen: Int, egc: String = "\u{0}", styles: [Style] = [], ul: Channels, ur: Channels, ll: Channels, lr: Channels) {
        ncplane_gradient(ncPlane, Int32(x), Int32(y), UInt32(yLen), UInt32(xLen), strdup(egc), UInt16(makeBitMask(from: styles)), ul, ur, ll, lr)
    }

    public func highGradient(y: Int, x: Int, yLen: Int, xLen: Int, egc: String = "\u{0}", styles: [Style] = [], ul: Channel, ur: Channel, ll: Channel, lr: Channel) {
        ncplane_gradient2x1(ncPlane, Int32(x), Int32(y), UInt32(yLen), UInt32(xLen), ul, ur, ll, lr)
    }
}


extension Plane {
    public enum Flag: UInt32 {
        case horAligned = 0x0001
        case verAligned = 0x0002
        case marginalized = 0x0004
        case fixed = 0x0008
        case autogrow = 0x0010
        case vscroll = 0x0020
    }

    public struct Options {
        var y: Int
        var x: Int
        var rows: Int
        var columns: Int
        // userptr
        var name: String?
        // resizecb
        var flags: [Flag]
        var marginBottom: Int
        var marginRight: Int

        public init(y: Int, x: Int, rows: Int, columns: Int, name: String? = nil, flags: [Flag] = [], marginBottom: Int = 0, marginRight: Int = 0) {
            self.y = y
            self.x = x
            self.rows = rows
            self.columns = columns
            self.name = name
            self.flags = flags
            self.marginBottom = marginBottom
            self.marginRight = marginRight
        }

        var nativeValue: ncplane_options {
            ncplane_options(
                    y: Int32(y),
                    x: Int32(x),
                    rows: UInt32(rows),
                    cols: UInt32(columns),
                    userptr: nil,
                    name: name == nil ? nil : strdup(name),
                    resizecb: nil,
                    flags: UInt64(makeBitMask(from: flags)),
                    margin_b: UInt32(marginBottom),
                    margin_r: UInt32(marginRight))
        }
    }
}