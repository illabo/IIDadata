import XCTest
import IIDadata

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    private var apiToken: String {
        // Switch this return to your <# API token #>.
        DadataAPIConstants.token
    }
    
    #warning("TODO: make separate test cases with assertions.")
    func testAllCasesJustDoSomething(){
        DadataSuggestions(apiKey: apiToken)
            .suggestAddress(
                "9120b43f-2fae-4838-a144-85e43c2bfb29",
                queryType: .findByID,
                resultsCount: 5,
                language: nil,
                constraints: ["{\"region\":\"Приморский\"}"],
                regionPriority: nil,
                upperScaleLimit: "street",
                lowerScaleLimit: nil,
                trimRegionResult: false
            ){ try? $0.get().suggestions?.forEach{ print($0) } }
        
        var constraint = AddressQueryConstraint()
        constraint.region = "Приморский"
        constraint.city = "Владивосток"
        constraint.country_iso_code = "RU"
        constraint.region_iso_code = "RU-PRI"
        try! DadataSuggestions.shared(
            apiKey: apiToken
        ).suggestAddress(
            "г Владивосток, Русский остров, поселок Аякс, д 1",
            resultsCount: 1,
            language: .ru,
            constraints: [constraint],
            regionPriority: nil,
            upperScaleLimit: .street,
            lowerScaleLimit: .house,
            trimRegionResult: false
        ){ try? $0.get().suggestions?.forEach{ print("\(String(describing: $0.value)) \(String(describing: $0.data?.geoLat)) \(String(describing: $0.data?.geoLon))") } }
        
        try! DadataSuggestions.shared(
            apiKey: apiToken
        ).reverseGeocode(query: "43.026661, 131.8951698",
                         delimeter: ",",
                         resultsCount: 1,
                         language:"ru",
                         searchRadius: 100){ try? $0.get().suggestions?.forEach{ print("\(String(describing: $0.value)) \(String(describing: $0.data?.geoLat)) \(String(describing: $0.data?.geoLon))") } }
        
        
        
        let q = AddressSuggestionQuery("9120b43f-2fae-4838-a144-85e43c2bfb29", ofType: .findByID)
        q.resultsCount = 1
        q.language = .en
        DadataSuggestions(apiKey: apiToken)
            .suggestAddress(q){ try? $0.get().suggestions?.forEach{ print($0) } }
        
        let dadata = try? DadataSuggestions
            .shared(
                apiKey: apiToken
            )
        
        dadata?.suggestAddressFromFIAS("Тверская обл, Пеновский р-н, деревня Москва"){ print( (try? $0.get().suggestions) ?? "Nothing" ) }
        
        dadata?.suggestAddressFromFIAS("Эрхирик"){ print( (try? $0.get().suggestions) ?? "Nothing" ) }
        
        dadata?.suggestAddress("Эрхирик трактовая 15", resultsCount: 1, constraints: [""]){r in
            let v = try? r.get()
            if let s = v?.suggestions, s.count > 0{
                print("\(s[0].value!): LAT \(s[0].data!.geoLat!) @ LON \(s[0].data!.geoLon!)")
            }
        }
        
        dadata?.suggestByKLADRFIAS("9120b43f-2fae-4838-a144-85e43c2bfb29"){ print( (try? $0.get().suggestions) ?? "Nothing" ) }
        
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
        
        dadata?.reverseGeocode(latitude: 51.5346,
                               longitude: 107.4937,
                               resultsCount: 1,
                               language: .ru,
                               searchRadius: 1000){ r in
            let v = try? r.get()
            if let s = v?.suggestions, s.count > 0{
                print("\(s[0].value!): LAT#\(s[0].data!.geoLat!) @ LON#\(s[0].data!.geoLon!)")
            }
        }
        
        
        dadata?.suggestAddress(
            "Пенза московская 1",
            resultsCount: 1,
            language: "en",
            completion: { r in
                switch r{
                case .success(let v):
                    print(v.suggestions?[0].value as Any)
                    try! dadata?.reverseGeocode(
                        query: "\(v.suggestions![0].data!.geoLat!), \(v.suggestions![0].data!.geoLon!)",
                        language: "en",
                        searchRadius: 100){ r in
                        switch r {
                        case .success(let v):
                            print(v.suggestions?[0].unrestrictedValue as Any)
                            return
                        case .failure(let e):
                            print(e)
                            return
                        }
                    }
                    return
                case .failure(let e):
                    print(e)
                    return
                }
            }
        )
        
        try! dadata?.reverseGeocode(query: "52.2620898, 104.3203629",
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
        }
        
        do{
            _ = try DadataSuggestions(apiKey: "some-garbage-token", checkWithTimeout: 15)
        } catch let e {
            print(e)
        }
    }
    
}
