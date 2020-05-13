# IIDadata

[![Version](https://img.shields.io/cocoapods/v/IIDadata.svg?style=flat)](https://cocoapods.org/pods/IIDadata)
[![License](https://img.shields.io/cocoapods/l/IIDadata.svg?style=flat)](https://cocoapods.org/pods/IIDadata)
[![Platform](https://img.shields.io/cocoapods/p/IIDadata.svg?style=flat)](https://cocoapods.org/pods/IIDadata)

This package provides access to Dadata address suggestions and reverse geocoding APIs. 

### Basic usage.
```swift
try! DadataSuggestions
    .shared(
        apiKey: "<# Dadata API token #>"
).suggestAddress(
        "Пенза"
        completion: { r in
            switch r {
            case .success(let v):
                print(v)
            case .failure(let e):
                print(e)
            }
    }
)
```
---
### There are a bunch of additional init options
Ranging from init with explicit API token.
```swift
let dadata = DadataSuggestions(apiKey: "<# Dadata API token #>")
```

Through init with an API token from Info.plist. But may throw if it's missing.
```swift
let dadata = try? DadataSuggestions()
```
Even to init with check on connectivity.
However this init should not be called on main thread as it may take up long time as it makes request to server in a blocking manner.
Throws if connection is impossible or request is timed out.
```swift
DispatchQueue.global(qos: .background).async {
    let dadata = try? DadataSuggestions(apiKey: "<# Dadata API token #>", checkWithTimeout: 15)
}
```
___
### Regardless of the way you init theris more to do with this library
Basic address suggestions request to only search in FIAS database: less matches, state provided address data only.
```swift
dadata?.suggestAddressFromFIAS("Тверская обл, Пеновский р-н, деревня Москва"){ print( try? $0.get().suggestions ) }
```
---
Basic address suggestions request takes KLADR or FIAS ID as a qury parameter to lookup additional data.
```swift
dadata?.suggestByKLADRFIAS("9120b43f-2fae-4838-a144-85e43c2bfb29"){ print( try? $0.get().suggestions ) }
```
---
However more elaborate queries could be made by providing constraints and/or setting filtering.
```swift
var constraint = AddressQueryConstraint()
constraint.region = "Приморский"
constraint.city = "Владивосток"
constraint.country_iso_code = "RU"
constraint.region_iso_code = "RU-PRI"

dadata?.suggestAddress(
    "Gogolya 9",
    resultsCount: 5,
    language: .en,
    constraints: [constraint],
    regionPriority: nil,
    upperScaleLimit: .street,
    lowerScaleLimit: .house,
    trimRegionResult: false,
    completion: completion
)
```
Or building `AddressSuggestionQuery` manually. Note in this example it is a query made with FIAS ID instead of free-form text.
```swift
let q = AddressSuggestionQuery("9120b43f-2fae-4838-a144-85e43c2bfb29", ofType: .findByID)
q.resultsCount = 1
q.language = .en

dadata?.suggestAddress(q){ try? $0.get().suggestions?.forEach{ print($0) } }
```
---
Also reverse geocoding is available.
```swift
try? dadata?.reverseGeocode(query: "52.2620898, 104.3203629",
                            delimeter: ",",
                            resultsCount: 1,
                            language:"ru",
                            searchRadius: 100){ r in
                                let v = try? r.get()
                                if let s = v?.suggestions, s.count > 0{
                                    print("\(s[0].value!): LAT#\(s[0].data!.geoLat!) @ LON#\(s[0].data!.geoLon!)")
                                }
}
```
## Documentation
Project [documentation is available here]( https://illabo.github.io/IIDadata/).


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

IIDadata is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IIDadata'
```

Or use Swift PM. Add the following line to your Package.swift file in the dependencies section:
```
.package(url: "https://github.com/illabo/IIDadata.git, from: "0.1.0")
```

## License

IIDadata is available under the MIT license. See the LICENSE file for more info.
