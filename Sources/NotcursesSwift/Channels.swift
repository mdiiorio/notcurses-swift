import notcurses

private let NC_BGDEFAULT_MASK: UInt32 = 0x40000000

public typealias Channels = UInt64
public extension Channels {
    init(_ fg:Color, _ bg: Color) {
        self.init(Channels(createChannel(color: fg)) << 32 + Channels(createChannel(color: bg)))
    }
}

public typealias Channel = UInt32
public extension Channel {
    init(_ color:Color) {
        self.init(color.value + NC_BGDEFAULT_MASK)
    }
}

public func createChannel(color: Color) -> Channel {
    Channel(color.value + NC_BGDEFAULT_MASK)
}

public func createChannel(color: Color, alpha: Alpha = .opaque) -> Channel {
    var channel = createChannel(color: color)
    setAlpha(forChannel: &channel, alpha)
    return channel
}

@discardableResult public func setAlpha(forChannel channel: inout Channel, _ alpha: Alpha) -> Bool {
    ncchannel_set_alpha(&channel, alpha.rawValue) != -1
}

public func createChannels(fg: Color, bg: Color) -> Channels {
    (Channels(createChannel(color: fg)) << 32) + Channels(createChannel(color: bg))
}

public func createChannels(fg: Color, fgAlpha: Alpha = .opaque, bg: Color, bgAlpha: Alpha = .opaque) -> Channels {
    (Channels(createChannel(color: fg, alpha: fgAlpha)) << 32) + Channels(createChannel(color: bg, alpha: bgAlpha))
}

public func red(fromChannel channel: Channel) -> Int {
    Int(ncchannel_r(channel))
}
public func green(fromChannel channel: Channel) -> Int {
    Int(ncchannel_g(channel))
}
public func blue(fromChannel channel: Channel) -> Int {
    Int(ncchannel_b(channel))
}

@discardableResult public func setBgAlpha(forChannels channels: inout Channels, _ alpha: Alpha) -> Int {
    Int(ncchannels_set_bg_alpha(&channels, alpha.rawValue))
}

public func bgAlpha(forChannels channels: Channels) -> Alpha {
    // TODO complain somehow on nil?
    Alpha(rawValue: ncchannels_bg_alpha(channels)) ?? .opaque
}

@discardableResult public func setFgAlpha(forChannels channels: inout Channels, _ alpha: Alpha) -> Int {
    Int(ncchannels_set_fg_alpha(&channels, alpha.rawValue))
}

public func fgAlpha(forChannels channels: Channels) -> Alpha {
    // TODO complain somehow on nil?
    Alpha(rawValue: ncchannels_fg_alpha(channels)) ?? .opaque
}

@discardableResult public func setFgRgb(forChannels channels: inout Channels, _ color: Color) -> Int {
    Int(ncchannels_set_fg_rgb(&channels, color.value))
}
@discardableResult public func setBgRgb(forChannels channels: inout Channels, _ color: Color) -> Int {
    Int(ncchannels_set_bg_rgb(&channels, color.value))
}
