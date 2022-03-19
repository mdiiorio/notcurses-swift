import Foundation
import notcurses

public class Cell {

//    public var gCluster: UInt32
//    public var gClusterBackstop: UInt8
//    public var width: UInt8
//    public var styles: [Style]
//    public var channels: Channels
//    // A spilled EGC is indicated by the value 0x01XXXXXX. This cannot alias a
//    // true supra-ASCII EGC, because UTF-8 only encodes bytes <= 0x80 when they
//    // are single-byte ASCII-derived values. The XXXXXX is interpreted as a 24-bit
//    // index into the egcpool. These pools may thus be up to 16MB.
//    //
//    // The cost of this scheme is that the character 0x01 (SOH) cannot be encoded
//    // in a nccell, which we want anyway. It must not be allowed through the API,
//    // or havoc will result.
//    public var gcluster: UInt32 // 4B → 4B little endian EGC
//
//    public var gcluster_backstop: UInt8 // 1B → 5B (8 bits of zero)
//
//    // we store the column width in this field. for a multicolumn EGC of N
//    // columns, there will be N nccells, and each has a width of N...for now.
//    // eventually, such an EGC will set more than one subsequent cell to
//    // WIDE_RIGHT, and this won't be necessary. it can then be used as a
//    // bytecount. see #1203. FIXME iff width >= 2, the cell is part of a
//    // multicolumn glyph. whether a cell is the left or right side of the glyph
//    // can be determined by checking whether ->gcluster is zero.
//    public var width: UInt8 // 1B → 6B (8 bits of EGC column width)
//
//    public var stylemask: UInt16 // 2B → 8B (16 bits of NCSTYLE_* attributes)
//
//    // (channels & 0x8000000000000000ull): blitted to upper-left quadrant
//    // (channels & 0x4000000000000000ull): foreground is *not* "default color"
//    // (channels & 0x3000000000000000ull): foreground alpha (2 bits)
//    // (channels & 0x0800000000000000ull): foreground uses palette index
//    // (channels & 0x0400000000000000ull): blitted to upper-right quadrant
//    // (channels & 0x0200000000000000ull): blitted to lower-left quadrant
//    // (channels & 0x0100000000000000ull): blitted to lower-right quadrant
//    // (channels & 0x00ffffff00000000ull): foreground in 3x8 RGB (rrggbb) / pindex
//    // (channels & 0x0000000080000000ull): reserved, must be 0
//    // (channels & 0x0000000040000000ull): background is *not* "default color"
//    // (channels & 0x0000000030000000ull): background alpha (2 bits)
//    // (channels & 0x0000000008000000ull): background uses palette index
//    // (channels & 0x0000000007000000ull): reserved, must be 0
//    // (channels & 0x0000000000ffffffull): background in 3x8 RGB (rrggbb) / pindex
//    // At render time, these 24-bit values are quantized down to terminal
//    // capabilities, if necessary. There's a clear path to 10-bit support should
//    // we one day need it, but keep things cagey for now. "default color" is
//    // best explained by color(3NCURSES). ours is the same concept. until the
//    // "not default color" bit is set, any color you load will be ignored.
//    public var channels: UInt64 // + 8B == 16B
//
//    public init()
//
//    public init(gcluster: UInt32, gcluster_backstop: UInt8, width: UInt8, stylemask: UInt16, channels: UInt64)

    var ncCell: UnsafeMutablePointer<nccell>

    //#define NCCELL_TRIVIAL_INITIALIZER { .gcluster = 0, .gcluster_backstop = 0,\
    //  .width = 1, .stylemask = 0, .channels = 0, }
    public init() {
        ncCell = UnsafeMutablePointer<nccell>.allocate(capacity: 1)
        ncCell.pointee.gcluster = 0
        ncCell.pointee.gcluster_backstop = 0
        ncCell.pointee.width = 1
        ncCell.pointee.stylemask = 0
        ncCell.pointee.channels = 0
    }

//#define NCCELL_INITIALIZER(c, s, chan) { .gcluster = (htole(c)), .gcluster_backstop = 0,\
//  .width = (uint8_t)((wcwidth(c) < 0 || !c) ? 1 : wcwidth(c)), .stylemask = (s), .channels = (chan), }
//

    //#define NCCELL_CHAR_INITIALIZER(c) { .gcluster = (htole(c)), .gcluster_backstop = 0,\
    //  .width = (uint8_t)((wcwidth(c) < 0 || !c) ? 1 : wcwidth(c)), .stylemask = 0, .channels = 0, }
    public convenience init(fromChar character: Character) {
        self.init()

        let scalars = character.unicodeScalars
        let value = scalars[scalars.startIndex].value
        ncCell.pointee.gcluster = CFSwapInt32HostToLittle(value)
        ncCell.pointee.gcluster_backstop = 0
        // TODO ncstrwidth_valid?
        ncCell.pointee.width = UInt8(((wcwidth(wchar_t(value)) < 0 || value == 0)) ? 1 : wcwidth(wchar_t(value)))
        ncCell.pointee.stylemask = 0
        ncCell.pointee.channels = 0
    }

    public var fgAlpha: Alpha {
        get { Alpha(rawValue: nccell_fg_alpha(ncCell)) ?? .opaque }
        set { _ = setFgAlpha(newValue) }
    }
    public func setFgAlpha(_ alpha: Alpha) -> Bool {
        nccell_set_fg_alpha(ncCell, UInt32(alpha.rawValue)) == 0
    }

    public var bgAlpha: Alpha {
        get { Alpha(rawValue: nccell_bg_alpha(ncCell)) ?? .opaque }
        set { _ = setBgAlpha(newValue) }
    }
    public func setBgAlpha(_ alpha: Alpha) -> Bool {
        nccell_set_bg_alpha(ncCell, UInt32(alpha.rawValue)) == 0
    }

    public var fgRgb: Color {
        get { Color(value: nccell_fg_rgb(ncCell)) }
        set { _ = setFgRgb(newValue) }
    }
    public func setFgRgb(_ color: Color) -> Bool {
        nccell_set_fg_rgb(ncCell, color.value) == 0
    }

    public var bgRgb: Color {
        get { Color(value: nccell_bg_rgb(ncCell)) }
        set { _ = setBgRgb(newValue) }
    }
    public func setBgRgb(_ color: Color) -> Bool {
        nccell_set_bg_rgb(ncCell, color.value) == 0
    }
}

