# SwCLI

## Overview

SwCLI is CLI interface minimum module.

## Requirements

* Swift 3.0

## Usage

### runWithRead

```swift
let ret = try! SwCLI().runWithRead(["echo", "abc"])
// -> abc
```

### passes

```swift
if SwCLI().passes(["cd", "Sources"]) {
    // -> changed directory
}
```

### contains

```swift
if SwCLI().contains(["git"]) {
    // -> can use git command
}
```

### fail

```swift
fail("forced termination")
```

## Installation

* Add `SwCLI` to your `Package.swift`

```
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/moaible/SwCLI.git", majorVersion: 0, minor: 2),
    ]
)
```
