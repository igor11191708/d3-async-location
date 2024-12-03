# Async/await location streamer for iOS, watchOS using new concurrency model in Swift

Async pattern using new concurrency model in **swift** that can be applied to Core Bluetooth, Core Motion and others sources streaming data asynchronously

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftuiux%2Fd3-async-location%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swiftuiux/d3-async-location)

## SwiftUI example of using package
[async-location-swift-example](https://github.com/swiftuiux/corelocation-manager-tracker-swift-apple-maps-example)

if you are using the simulator don't forget to simulate locations

 ![simulate locations](https://github.com/swiftuiux/d3-async-location/blob/main/img/image11.gif)

 ## Features
- [x] Using new concurrency swift model around CoreLocation manager
- [x] Customizable in terms of passing a preconfigured CLLocationManager
- [x] Customizable in terms of CLLocationManager properties
- [x] Streaming current location asynchronously
- [x] Different strategies - Keep and publish all stack of locations since streaming has started or the last one
- [x] Support for iOS from 14.1 and watchOS from 7.0
- [x] Errors handling (as **AsyncLocationErrors** so CoreLocation errors **CLError**)

## How to use
 
### 1. Add to info the option "Privacy - Location When In Use Usage Description" 
 ![Add to info](https://github.com/swiftuiux/d3-async-location/blob/main/img/image2.png)
 
### 2. Add or inject LMViewModel into a View

```
    @EnvironmentObject var model: LMViewModel 
```

### 3. Call ViewModel method start() within async environment or check SwiftUI example


### LMViewModel Parameters

|Param|Description|
| --- | --- |
|strategy| Strategy for publishing locations Default value is **.keepLast** The other option is **.keepAll** |
|accuracy| The accuracy of a geographical coordinate.|
|activityType|Constants indicating the type of activity associated with location updates.|
|distanceFilter|A distance in meters from an existing location.|
|backgroundUpdates|A Boolean value that indicates whether the app receives location updates when running in the background|

or

|Param|Description|
| --- | --- |
|strategy| Strategy for publishing locations Default value is **.keepLast** The other option is **.keepAll** |
|locationManager| Preconfigured CLLocationManager |


### Default location
1. Product > Scheme > Edit Scheme
2. Click Run .app
3. Option tab
4. Already checked Core Location > select your location
5. Press OK

 ![Default location](https://github.com/swiftuiux/d3-async-location/blob/main/img/image6.png)
 
 Available for watchOS
 
 ![simulate locations](https://github.com/swiftuiux/d3-async-location/blob/main/img/image5.gif)
 
## Documentation(API)
- You need to have Xcode 13 installed in order to have access to Documentation Compiler (DocC)
- Go to Product > Build Documentation or **⌃⇧⌘ D**
