# IIDadata

[![Version](https://img.shields.io/cocoapods/v/IIDadata.svg?style=flat)](https://cocoapods.org/pods/IIDadata)
[![License](https://img.shields.io/cocoapods/l/IIDadata.svg?style=flat)](https://cocoapods.org/pods/IIDadata)
[![Platform](https://img.shields.io/cocoapods/p/IIDadata.svg?style=flat)](https://cocoapods.org/pods/IIDadata)

This package provides access to Dadata address suggestions and reverce geocoding APIs. 

Basic usage.
```
try! DadataSuggestions
    .shared(
        apiKey: "<# Dadata API token #>"
).suggestAddress(
        "Пенза"
        completion: { r in
            switch r{
            case .success(let v):
                print(v)
            case .failure(let e):
                print(e)
            }
    }
)
```
However more elaborate queries could be made.
```
var constraint = AddressQueryLimitation()
constraint.region = "Приморский"
constraint.city = "Владивосток"
constraint.country_iso_code = "RU"
constraint.region_iso_code = "RU-PRI"

try! DadataSuggestions
    .shared(
        apiKey: "<# Dadata API token #>"
).suggestAddress(
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
Reverse geocoding also available.
```
let dadata = DadataSuggestions(apiKey: "<# Dadata API token #>")
try! dadata.reverseGeocode(query: "52.2620898, 104.3203629",
                 delimeter: ",",
                 resultsCount: 1,
                 language:"ru",
                 searchRadius: 100){ r in
                    switch r {
                    case .success(let v):
                        print(v)
                        return
                    case .failure(let e):
                        print(e)
                        return
                    }
```

You may store API key in Info.plist under `IIDadataAPIToken` key and just call `try! DadataSuggestions.shared(apiKey: nil)`.


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
.package(url: "https://github.com/illabo/IIDadata.git, from "0.1.0")
```

## License

IIDadata is available under the MIT license. See the LICENSE file for more info.
