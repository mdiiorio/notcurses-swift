import Foundation
import notcurses

public class Selector {
    public typealias Option = String

    let ncSelector: OpaquePointer!

    public private(set) var plane: Plane

    ///
    ///
    /// - Parameters:
    ///   - plane: A plane to be used by the selector. Will be invalidated by this call.
    ///   - options:
    public init?(plane: Plane, options: Selector.Options) {
        var nativeValue = options.getNativeValue()
        ncSelector = ncselector_create(plane.ncPlane, &nativeValue)

        // Hold on to the plane so it doesn't get collected
        self.plane = plane

        guard ncSelector != nil else {
            plane.invalidateNativePlane()
            return nil
        }

        self.plane.relinquishPlaneOwnership()

        // Probably need a better way to handle this
        nativeValue.items.deallocate()
    }

    deinit {
        ncselector_destroy(ncSelector, nil)
    }

    public var plane: Plane {
        get {
            Plane.getCachedPlane(ncPlane: ncselector_plane(ncSelector))
        }
    }

    public func addItem(item: Selector.Item) {
        var nativeItem = ncselector_item()
        item.copyInto(nativeValue: &nativeItem)
        ncselector_additem(ncSelector, &nativeItem)
    }
    
    public func deleteItem(option: Selector.Option) {
        ncselector_delitem(ncSelector, option)
    }

    @discardableResult public func offerInput(input: InputEvent) -> Bool {
        var eventCopy = input.nativeValue
        return ncselector_offer_input(ncSelector, &eventCopy)
    }

    @discardableResult public func prevItem() -> Option {
        Selector.Option(cString: ncselector_previtem(ncSelector))
    }

    @discardableResult public func nextItem() -> Option {
        Selector.Option(cString: ncselector_nextitem(ncSelector))
    }

    public func selected() -> Option? {
        guard let selected = ncselector_selected(ncSelector) else { return nil }
        return Option(cString: selected)
    }
}

extension Selector {
    public struct Item {
        public var option: Option
        public var desc: String?

        func copyInto(nativeValue: inout ncselector_item) {
            nativeValue.option = UnsafePointer(strdup(option))
            nativeValue.desc = (desc != nil ? UnsafePointer(strdup(desc)) : nil)
        }

        public init(option: Option, desc: String?) {
            self.option = option
            self.desc = desc
        }
    }

    public struct Options {
        public var title: String?
        public var secondary: String?
        public var footer: String?
        public var items: [Selector.Item]
        public var defaultIndex: Int
        public var maxDisplay: Int
        public var opChannels: Channels
        public var descChannels: Channels
        public var titleChannels: Channels
        public var footerChannels: Channels
        public var boxChannels: Channels
        public var flags: Int

        public init(title: String? = nil, secondary: String? = nil, footer: String? = nil, items: [Selector.Item] = [],
            defaultIndex: Int = 0, maxDisplay: Int = 0, opChannels: Channels = 0,
            descChannels: Channels = 0, titleChannels: Channels = 0, footerChannels: Channels = 0,
            boxChannels: Channels = 0, flags: Int = 0) {
            self.title = title
            self.secondary = secondary
            self.footer = footer
            self.items = items
            self.defaultIndex = defaultIndex
            self.maxDisplay = maxDisplay
            self.opChannels = opChannels
            self.descChannels = descChannels
            self.titleChannels = titleChannels
            self.footerChannels = footerChannels
            self.boxChannels = boxChannels
            self.flags = 0
        }

        func getNativeValue() -> ncselector_options {
            let p = UnsafeMutableBufferPointer<ncselector_item>.allocate(capacity: items.count + 1)
            for (i, item) in items.enumerated() {
                item.copyInto(nativeValue: &p[i])
            }
            p[items.count].option = nil
            p[items.count].desc = nil

            return ncselector_options(
                title: title == nil ? nil : strdup(title!),
                secondary: secondary == nil ? nil : strdup(secondary!),
                footer: footer == nil ? nil : strdup(footer!),
                items: p.baseAddress,
                defidx: UInt32(defaultIndex),
                maxdisplay: UInt32(maxDisplay),
                opchannels: opChannels,
                descchannels: descChannels,
                titlechannels: titleChannels,
                footchannels: footerChannels,
                boxchannels: boxChannels,
                flags: UInt64(flags))
        }
    }
}