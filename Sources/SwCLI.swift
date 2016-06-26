//
//  SwCLI.swift
//  SwCLI
//
//  Created by Hiromi Motodera on 6/24/16.
//  Copyright © 2016 Hiromi Motodera. All rights reserved.
//

#if os(OSX)
    import Darwin
#else
    import Glibc
#endif

import Foundation

struct SwCLI {
    
    enum Error: ErrorProtocol { // Errors pertaining to running commands
        case system(Int32, String?)
        case cancelled
        case terminalSize
    }
    
    struct Result {
        let status: Int32
        let outputPipe: Pipe
        let errorPipe: Pipe
    }
    
    static func shell(
        _ args: [String],
        input: AnyObject? = nil,
        errorHandler: AnyObject? = nil,
        inDirectory: String? = nil,
        waitUntilExit: Bool = true) -> Result
    {
        let task = Task()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        let errorPipe = Pipe()
        task.standardError = errorPipe
        if let input = input {
            task.standardInput = input
        }
        if let inDirectory = inDirectory {
            task.currentDirectoryPath = inDirectory
        }
        task.launch()
        if waitUntilExit {
            task.waitUntilExit()
        }
        
        return Result(status: task.terminationStatus, outputPipe: outputPipe, errorPipe: errorPipe)
    }
    
    static func run(_ args: [String]) throws {
        let result = self.shell(args)
        try self.assertResult(result)
    }
    
    static func runWithRead(_ args: [String]) throws -> String {
        let result = self.shell(args)
        try self.assertResult(result)
        let readData = result.outputPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: readData, encoding: .utf8) ?? ""
    }
    
    static func passes(_ args: [String]) -> Bool {
        let ret = self.shell(args)
        if let errorLog = String.init(data: ret.errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
            print(errorLog)
        }
        return ret.status == 0
    }
    
    static func contains(command: String) -> Bool {
        return self.passes(["hash", command])
    }
    
    static func assertResult(_ result: Result) throws {
        if result.status == 2 {
            throw Error.cancelled
        } else if result.status != 0 {
            let errorData = result.errorPipe.fileHandleForReading.readDataToEndOfFile()
            throw Error.system(result.status, String(data: errorData, encoding: .utf8))
        }
    }
    
    static func receivedCommand() -> String {
        return readLine(strippingNewline: true) ?? ""
    }
}
