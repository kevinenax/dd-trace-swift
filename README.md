# DDSwiftTracer

A DataDog OpenTracing Tracer written in Swift.

[![Actions Status](https://github.com/kevinenax/dd-trace-swift/workflows/Swift/badge.svg)](https://github.com/kevinenax/dd-trace-swift/actions) [![codecov](https://codecov.io/gh/kevinenax/dd-trace-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/kevinenax/dd-trace-swift)


## Installation

To install using Swift Package Manager, simply include the following line in your `Package.swift` file under dependencies. Then add the dependency `"DDSwiftTracer"` to any targets that require it.

``` swift
.package(url: "https://github.com/kevinenax/dd-swift-trace.git", from: "0.1.0"),
```

Then simply add the following import statement to your source files.

``` swift
import DDSwiftTracer
```

## Usage

Since the library uses the official [OpenTracing](https://github.com/opentracing/opentracing-swift) spec, simply create an instance of the `DDSwiftTracer` class and assign it as the global tracer. Then continue using the OpenTracing api.

``` swift
import OpenTracing

let agent = DDAgentService(agentHost: "localhost")
Global.sharedTracer = DDTracer(serviceName: "myService", agentService: agent)
```

The library also defines a number of constants to be used as tags on span objects. Setting any of these will ensure that data ends up in DataDog and in the correct place. See [`DDSpan.Tags`](Sources/DDSwiftTracer/DDSpan.swift)
