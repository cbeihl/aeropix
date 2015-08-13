//
//  FlightLogger.swift
//  AeroPix
//
//  Created by Chris on 8/6/15.
//  Copyright (c) 2015 Chris. All rights reserved.
//

import Foundation

class FlightLogger {
    
    var filename = "flightlog.txt"
    var docTxtPath: String? = nil
    var logFile: NSFileHandle? = nil
    
    init(filename: String, firstLine: String) {
        self.filename = filename
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir: String = paths[0] as! String
        docTxtPath = docDir.stringByAppendingPathComponent(filename)
        let txtHeader = "\(firstLine)\n"
        txtHeader.writeToFile(docTxtPath!, atomically: false, encoding: NSUTF8StringEncoding)
    }

    func writeLog(logEntry:String) {
        if (logFile == nil) {
            logFile = NSFileHandle.init(forWritingAtPath: docTxtPath!)
        }
        
        logFile?.seekToEndOfFile()
        var logEntryLine = logEntry.stringByAppendingString("\n")
        logFile?.writeData(logEntryLine.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    deinit {
        logFile?.closeFile()
    }
}