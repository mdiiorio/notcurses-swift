//
// Created by Matt Di Iorio on 12/22/21.
//

import Foundation

//fputs("\n\nStarting...\n", stderr)
//
//var token: NSObjectProtocol?
//token = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: nil, queue: OperationQueue.main) { note in
//            fputs("notification \(note)\n", stderr)
//
//    while true {
//        let (key, _) = nc.getNonBlocking()
//        fputs("key \(key)\n", stderr)
//        if key != .invalid {
//            logView.print("\(key)")
//        } else {
//            break
//        }
//
//        switch key {
//        case .q:
//            nc.stop()
//            exit(0)
//            break
//        default:
//            topView.handleInput(input: key)
//            break
//        }
//    }
//
//    nc.inputReadyHandle().waitForDataInBackgroundAndNotify()
//
//    topView.draw()
//    nc.render()
//
//}

//nc.inputReadyHandle().waitForDataInBackgroundAndNotify()
//fputs("fh \(nc.inputReadyHandle().fileDescriptor)", stderr)
//
//CFRunLoopRun()




//DispatchQueue.global().async {
//    let outPipe = Pipe()
//    let outHandle = outPipe.fileHandleForReading
//
//    let simulatorList = Process()
//    simulatorList.launchPath = "/usr/bin/xcrun"
//    simulatorList.arguments = ["simctl", "list"]
//    simulatorList.standardOutput = outPipe
//    simulatorList.launch()
//
//    let output = outHandle.readDataToEndOfFile()
//    let str = String(data: output, encoding: .utf8)!
//
//    logView.print(str)
//}