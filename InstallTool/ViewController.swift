//
//  ViewController.swift
//  InstallTool
//
//  Created by cc x on 2019/8/22.
//  Copyright © 2019 cillyfly. All rights reserved.
//

import Cocoa
import ADragDropView

class ViewController: NSViewController {
    
    @IBOutlet weak var dropView: ADragDropView!
    @IBOutlet var deviceMenuButton: NSPopUpButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceMenuButton.removeAllItems()
        deviceMenuButton.addItems(withTitles: getInstrumens())
        
        dropView.acceptedFileExtensions = ["app"]
        dropView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBAction func doIt(_ sender: Any) {
       startInstrumens(device: deviceMenuButton.titleOfSelectedItem!)
    }
    
    

    func startInstrumens(device:String){
        let path = "/usr/bin/xcrun"
        let arguments = ["instruments", "-w",device]
        let task = Process.launchedProcess(launchPath: path, arguments: arguments)
        task.waitUntilExit()
    }
    
    func getInstrumens() -> [String] {
        let path = "/usr/bin/xcrun"
        let arguments = ["simctl", "list"]
        let task = Process()
        task.launchPath = path
        task.arguments = arguments
        let pipe = Pipe()
        task.standardOutput = pipe

        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        let regex = try! NSRegularExpression(pattern: "iphone .+? \\(\\w+-\\w+-\\w+-\\w+-\\w+\\)", options: [.caseInsensitive])
        let rr = output.split(usingRegex: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.count > 0 && !$0.contains("unavailable") && regex.matches(in: $0, options: [], range: NSRange(location: 0, length: $0.count)).count != 0 }
        return rr
    }
    
    func installIpa(filePath:String){
        let path = "/usr/bin/xcrun"
        let arguments = ["simctl", "install","booted",filePath]
        let task = Process.launchedProcess(launchPath: path, arguments: arguments)
        task.waitUntilExit()
    }
}

extension ViewController:ADragDropViewDelegate{
    func dragDropView(_ dragDropView: ADragDropView, droppedFileWithURL URL: URL) {
        
        // action to do when the file is dropped
        print(URL)
        installIpa(filePath: URL.absoluteString)
    }
    
    // when multiple files are dropped
    func dragDropView(_ dragDropView: ADragDropView, droppedFilesWithURLs URLs: [URL]) {
        
        // action to do when the files are dropped
        print(URLs)
    }
}

extension String {
    func split(usingRegex pattern: String) -> [String] {
        // ### Crashes when you pass invalid `pattern`
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
        let ranges = [startIndex..<startIndex] + matches.map { Range($0.range, in: self)! } + [endIndex..<endIndex]
        return (0...matches.count).map { String(self[ranges[$0].upperBound..<ranges[$0 + 1].lowerBound]) }
    }
}
