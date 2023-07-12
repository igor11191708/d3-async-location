# Async/await location streamer for iOS, watchOS using new concurrency model in Swift

Async pattern using new concurrency model in **swift** that can be applied to Core Bluetooth, Core Motion and others sources streaming data asynchronously

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FThe-Igor%2Fasync-location%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/The-Igor/d3-async-location) [![![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FThe-Igor%2Fasync-location%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/The-Igor/d3-async-location)

## SwiftUI example of using package
[async-location-swift-example](https://github.com/The-Igor/async-location-swift-example)

if you are using the simulator don't forget to simulate locations

 ![simulate locations](https://github.com/The-Igor/d3-async-location/blob/main/img/image11.gif)

 ## Features
- [x] Using new concurrency swift model around CoreLocation manager
- [x] Customizable in terms of passing a custom delegate(CLLocationManagerDelegate) conforming to **ILocationDelegate** protocol
- [x] Customizable in terms of CLLocationManager properties
- [x] Streaming current location asynchronously
- [x] Different strategies - Keep and publish all stack of locations since streaming has started or the last one
- [x] Support for iOS from 14.1 and watchOS from 7.0
- [x] Errors handling (as **AsyncLocationErrors** so CoreLocation errors **CLError**)

## How to use
 
### 1. Add to info the option "Privacy - Location When In Use Usage Description" 
 ![Add to info](https://github.com/The-Igor/d3-async-location/blob/main/img/image2.png)
 
### 2. Add or inject LMViewModel into a View

```
    @EnvironmentObject var model: LMViewModel 
```

### 3. Call ViewModel method start() within async environment
If task will be canceled the streaming stops automatically. I would recommend to use .task modifier it manages cancelation on it's own. If you need to use Task and keep it in @State don't forget to cancel() when the time has come or it might course memory leaks in some cases
```
 .task{
       do{
             try await viewModel.start()
         }catch{
             self.error = error.localizedDescription
         }     
    }
```

### 4. Bake async stream of data from "locations" into a visual presentation 
```
    @ViewBuilder
    var coordinatesTpl: some View{
        List(viewModel.locations, id: \.hash) { location in
            Text("\(location.coordinate.longitude), \(location.coordinate.latitude)")
        }
    }
```

### 5. Showcase error
```   
    ///Access was denied by  user
    case accessIsNotAuthorized
    
    /// Attempt to launch streaming while it's been already started
    /// Subscribe different Views to LMViewModel.locations publisher to feed them
    case streamingProcessHasAlreadyStarted
    
    /// Stream was cancelled
    case streamCanceled

    /// Stream was terminated
    case streamUnknownTermination
    
    /// A Core Location error
    case coreLocationManagerError(CLError)
```

There's been a glitch - throwing **CLError.locationUnknown** *Error Domain=kCLErrorDomain Code=0 "(null)"* on some devices and simulator while changing locations time by time. This type of error *.locationUnknown* is excluded when it happens in the delegate method **didFailWithError**

### LMViewModel API
```
public protocol ILocationManagerViewModel: ObservableObject{
        
    /// List of locations
    @MainActor
    var locations : [CLLocation] { get }
    
    /// Strategy for publishing locations Default value is .keepLast 
    /// .keepAll is an option
    var strategy : LMViewModel.Strategy { get }
    
    /// Start streaming locations
    func start() async throws
    
    /// Stop streaming locations
    func stop()
}
```

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
|delegate| Custom delegate conforming to **ILocationDelegate**|


### Default location
1. Product > Scheme > Edit Scheme
2. Click Run .app
3. Option tab
4. Already checked Core Location > select your location
5. Press OK

 ![Default location](https://github.com/The-Igor/d3-async-location/blob/main/img/image6.png)
 
 Available for watchOS
 
 ![simulate locations](https://github.com/The-Igor/d3-async-location/blob/main/img/image5.gif)
 
## Documentation(API)
- You need to have Xcode 13 installed in order to have access to Documentation Compiler (DocC)
- Go to Product > Build Documentation or **⌃⇧⌘ D**
