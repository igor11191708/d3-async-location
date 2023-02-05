# Async location streamer for iOS, watchOS using new concurrency model in Swift

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FThe-Igor%2Fd3-async-location%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/The-Igor/d3-async-location) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FThe-Igor%2Fd3-async-location%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/The-Igor/d3-async-location)
 ## Features
- [x] Using new concurrency swift model around CoreLocation manager
- [x] Customizable in terms of CLLocationManager properties
- [x] Streaming current locations asynchronously
- [x] Support for iOS and watchOS
- [x] Errors handling

## How to use
 
### 1. Add to info the option "Privacy - Location When In Use Usage Description" 
 ![Add to info](https://github.com/The-Igor/d3-async-location/blob/main/img/image2.png)
 
### 2. Add or inject LMViewModel into a View

```
    @EnvironmentObject var model: LMViewModel
```

### 3. Call ViewModel method start() within async environment
If task will be canceled the streaming stops automatically. I would recomend to use .task modifire it manages cancelation on it's own. If you desided to use Task and keep it in @State don't forget to cancel() when the time has come or it might course memory leaks in some cases
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
    case streamCancelled
    
    /// Unknown termination
    case unknownTermination
```

## ViewModel API
```
public protocol ILocationManagerViewModel: ObservableObject{
        
    /// List of locations
    @MainActor
    var locations : [CLLocation] { get }
    
    /// Start streaming locations
    func start() async throws
    
    /// Stop streaming locations
    func stop()
}
```

## SwiftUI example of using package
[async-location-swift-example](https://github.com/The-Igor/async-location-swift-example)

if you are using the simulator don't forget to simulate locations

 ![simulate locations](https://github.com/The-Igor/d3-async-location/blob/main/img/image3.gif)
 
 Available on watchOs
 
 ![simulate locations](https://github.com/The-Igor/d3-async-location/blob/main/img/image5.gif)
 
## Documentation(API)
- You need to have Xcode 13 installed in order to have access to Documentation Compiler (DocC)
- Go to Product > Build Documentation or **⌃⇧⌘ D**
