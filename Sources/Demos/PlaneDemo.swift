import NotcursesSwift

class PlaneDemo: Demo {
    var gr: Plane?
    var other: Plane?
    var centerAligned: Plane?

    func runDemo(in plane: Plane) {
        gr = Plane(parent: plane, y: 5, x: 5, rows: 6, columns: 30)
        gr!.gradient(y: 0, x: 0, yLen: 6, xLen: 30, egc: " ", ul: createChannels(fg: .blue), ur: createChannels(fg: .green), ll: createChannels(fg: .red), lr: createChannels(fg: .white))
        gr!.highGradient(y: 0, x: 0, yLen: 6, xLen: 30, ul: createChannel(color: .blue), ur: createChannel(color: .blue), ll: createChannel(color: .white), lr: createChannel(color: .white))
        other = Plane(parent: plane, y: 20, x: 5, rows: 6, columns: 6)
        other!.perimeterRoundedBox(color: .blue)

        centerAligned = Plane.makeAligned(parent: plane, verAlign: .center, horAlign: .center, rows: 5, columns: 25)
        centerAligned!.perimeterRoundedBox()
    }

    func stopDemo() {
        gr = nil
        other = nil
        centerAligned = nil
    }
}
