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

public struct SwCLI {
    
    var launchPath: String
    
    var inDirectory: String?
    
    var waitUntilExit: Bool
    
    public enum Error: ErrorProtocol {
        case system(Int32, String?)
        case cancelled
    }
    
    public struct Result {
        let status: Int32
        let outputPipe: Pipe
        let errorPipe: Pipe
    }
    
    public init(launchPath: String = "/usr/bin/env", inDirectory: String? = nil, waitUntilExit: Bool = true) {
        self.launchPath = launchPath
        self.inDirectory = inDirectory
        self.waitUntilExit = waitUntilExit
    }
    
    public func shell(_ args: [String], input: AnyObject? = nil, errorReceiver: AnyObject? = nil) -> Result {
        let task = Task()
        task.launchPath = self.launchPath
        task.arguments = args
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        let errorPipe = Pipe()
        task.standardError = errorPipe
        if let input = input {
            task.standardInput = input
        }
        if let inDirectory = self.inDirectory {
            task.currentDirectoryPath = inDirectory
        }
        task.launch()
        if self.waitUntilExit {
            task.waitUntilExit()
        }
        return Result(status: task.terminationStatus, outputPipe: outputPipe, errorPipe: errorPipe)
    }
    
    public func run(_ args: [String]) throws {
        let result = self.shell(args)
        try self.assertResult(result)
    }
    
    public func runWithRead(_ args: [String]) throws -> String? {
        return String(data: try self.runWithReadData(args), encoding: .utf8)
    }
    
    public func runWithReadData(_ args: [String]) throws -> Data {
        let result = self.shell(args)
        try self.assertResult(result)
        let readData = result.outputPipe.fileHandleForReading.readDataToEndOfFile()
        return readData
    }
    
    public func passes(_ args: [String]) -> Bool {
        let ret = self.shell(args)
        if let errorLog = String.init(data: ret.errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
            print(errorLog)
        }
        return ret.status == 0
    }
    
    public func fail(_ message: String) {
        print()
        print("Error: \(message)")
        exit(1)
    }
    
    public func contains(command: String) -> Bool {
        return self.passes(["hash", command])
    }
    
    public func assertResult(_ result: Result) throws {
        if result.status == 2 {
            throw Error.cancelled
        } else if result.status != 0 {
            let errorData = result.errorPipe.fileHandleForReading.readDataToEndOfFile()
            throw Error.system(result.status, String(data: errorData, encoding: .utf8))
        }
    }
    
    public func receivedCommand() -> String {
        return readLine(strippingNewline: true) ?? ""
    }
}
