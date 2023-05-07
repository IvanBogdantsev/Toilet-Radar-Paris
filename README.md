# Toilet Radar Paris  <img src="https://user-images.githubusercontent.com/117449167/236677934-3000cbeb-c384-4f79-8dfb-8d1066c5aac3.png" height="45"/> 
*iOS 13.0+*

### Link to App Store

https://apps.apple.com/fr/app/toilet-radar-paris/id6448686615

### General concept
*Toilet Radar Paris* is an application that provides tourists and locals with a convenient way to find public toilets in Paris. The application
features easy-to-use functionality including creating routes on the map, calculating time and distance from the user to the point and then changing this data
as the user approaches their destination, as well as showing the details in an intuitive way. 
The application is fully localized to 9 most common languages spoken in Paris including Italian, Spanish and simplified Chinese. 

### How it looks? 
*Idle*     

<img src="https://user-images.githubusercontent.com/117449167/236676818-241d9a56-5185-4213-9af3-3be8d204d917.jpg" height="500"/>     

*Map view with constructed route*    

<img src="https://user-images.githubusercontent.com/117449167/236676828-164f34c0-0bc5-4720-9a9a-bb7f55db3001.jpg" height="500"/>   

*Details revealed in the bottom sheet*     

<img src="https://user-images.githubusercontent.com/117449167/236676837-beef2c48-f2e3-4ea6-ac3c-ea12283aa5a1.jpg" height="500"/> 
   
*Prompting user to enable location services*

<img src="https://user-images.githubusercontent.com/117449167/236677664-3ae21bfc-1957-4f93-b014-e208f7d2690f.jpeg" height="500"/> 

*Typical user flow*

![Screen_Recording_2023-05-07_at_15_53_40_AdobeExpress-2](https://user-images.githubusercontent.com/117449167/236682254-e501cd3c-13dc-4b37-8587-336cf4db92fa.gif)

### Technical Notes
Toilet Radar is a MVVM application that uses RxSwift as a reactive backbone of the MVVM pattern. RxSwift operators and traits are extensively used 
in the application.    
The map SDK of my choice is [MapboxMaps](https://github.com/mapbox/mapbox-maps-ios). I used some techniques that are not covered in SDK documentation 
such as displaying device orientation and wrapping Mapbox classes in reactive API.     
The application uses [Mapbox Directions](https://github.com/mapbox/mapbox-directions-swift) for polyline constructing and getting calculated distance and time. 
Distance and time are dynamically recalculated with each location update.     
The app demonstrates conformance to SOLID principles, good View-ViewModel coupling and uses a rich arsenal of tools that come with the Swift language.     
*Feel free to benchmark any practices used in this app in your own projects.*

### 3rd Party Libraries
* RxSwift - [RxSwift](https://github.com/ReactiveX/RxSwift) is used to make reactive bindings between View and ViewModel
* Alamofire - [Alamofire](https://github.com/Alamofire/Alamofire) is used to make API calls 
* MapboxMaps - [MapboxMaps SDK](https://github.com/mapbox/mapbox-maps-ios) is the engine used for displaying map
* MapboxDirections - [Mapbox Directions](https://github.com/mapbox/mapbox-directions-swift) is a powerful navigation SDK for routing and working with
locations, polylines, route legs, routes etc.





