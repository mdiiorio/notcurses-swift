import Foundation
import notcurses

public class Visual {
    public enum Blitter: Int {
        case _default = 0
        case _1x1
        case _2x1
        case _2x2
        case _3x2
        case braille
        case pixel
        case _4x1
        case _8x1
    }

    public enum Scale: Int {
        case none = 0
        case scale
        case stretch
        case noneHiRes
        case scaleHiRes
    }

    public enum OptionFlag: UInt64, CaseIterable {
        case noDegrade = 0x01
        case blend = 0x02
        case horAligned = 0x04
        case verAligned = 0x08
        case addAlpha = 0x10
        case childPlane = 0x20
        case noInterpolate = 0x40
    }

    public struct Options {
        var plane: Plane?
        var scaling: Scale
        var y, x: Int
        var beginY, beginX: Int
        var lengthY, lengthX: Int
        var blitter: Blitter
        var flags: [OptionFlag]
        var transColor: Int
        var pxOffy, pxOffx: Int

        public init(plane: Plane? = nil, scaling: Scale = .none, y: Int = 0, x: Int = 0, beginY: Int = 0, beginX: Int = 0, lengthY: Int = 0, lengthX: Int = 0, blitter: Blitter = ._default,
                    flags: [OptionFlag] = [], transColor: Int = 0, pxOffy: Int = 0, pxOffx: Int = 0) {
            self.plane = plane
            self.scaling = scaling
            self.y = y
            self.x = x
            self.beginY = beginY
            self.beginX = beginX
            self.lengthY = lengthY
            self.lengthX = lengthX
            self.blitter = blitter
            self.flags = flags
            self.transColor = transColor
            self.pxOffy = pxOffy
            self.pxOffx = pxOffx
        }

        func getNativeValue() -> ncvisual_options {
            ncvisual_options(n: plane?.ncPlane ?? nil,
                scaling: ncscale_e(UInt32(scaling.rawValue)),
                y: Int32(y), x: Int32(x),
                begy: UInt32(beginY), begx: UInt32(beginX),
                leny: UInt32(lengthY), lenx: UInt32(lengthX),
                blitter: ncblitter_e(UInt32(blitter.rawValue)),
                flags: makeBitMask(from: flags),
                transcolor: UInt32(transColor),
                pxoffy: UInt32(pxOffy), pxoffx: UInt32(pxOffx))
        }
    }

    let ncVisual: OpaquePointer

    public init?(file: String) {
        if let ncVisual = ncvisual_from_file(file) {
            self.ncVisual = ncVisual
        } else {
            return nil
        }
    }

    public func blit(nc: Notcurses, options: Visual.Options) -> Plane {
        var nativeValue = options.getNativeValue()
        return Plane.getCachedPlane(ncPlane: ncvisual_blit(nc.nc, ncVisual, &nativeValue))
    }
}
