import NotcursesSwift

struct TextDemo: Demo {
    func runDemo(in plane: Plane) {
        plane.putStr(y: 0, x: 0, "Hey babe")
        plane.putStr(y: 1, x: 0, "You say you wanna go out")
        plane.putStr(y: 2, x: 0, "And have yourself a little fun")
    }

    func stopDemo() {
    }
}
