import Foundation

///DadataSuggestions performs all the interactions with Dadata API.
public class DadataSuggestions {
    private let apiKey: String
    private var suggestionsAPIURL: URL
    private static var sharedInstance: DadataSuggestions?
    
    ///New instance of DadataSuggestions.
    ///
    ///
    ///Required API key is read from Info.plist. Each init creates new instance using same token.
    ///If DadataSuggestions is used havily consider `DadataSuggestions.shared()` instead.
    ///- Precondition: Token set with "IIDadataAPIToken"  key in Info.plist.
    ///- Throws: Call may throw if there isn't a value for key "IIDadataAPIToken" set in Info.plist.
    public convenience init() throws {
        let key = try DadataSuggestions.readAPIKeyFromPlist()
        self.init(apiKey: key)
    }
    
    ///This init checks connectivity once the class instance is set.
    ///
    ///This init should not be called on main thread as it may take up long time as it makes request to server in a blocking manner.
    ///Throws if connection is impossible or request is timed out.
    ///```
    ///DispatchQueue.global(qos: .background).async {
    ///    let dadata = try DadataSuggestions(apiKey: "<# Dadata API token #>", checkWithTimeout: 15)
    ///}
    ///```
    ///- Parameter apiKey: Dadata API token. Check it in account settings at dadata.ru.
    ///- Parameter checkWithTimeout: Time in seconds to wait for response.
    ///
    ///- Throws: May throw on connectivity problems, missing or wrong API token, limits exeeded, wrong endpoint.
    ///May throw if request is timed out.
    public convenience init(apiKey: String, checkWithTimeout timeout: Int) throws {
        self.init(apiKey: apiKey)
        try checkAPIConnectivity(timeout: timeout)
    }
    
    ///New instance of DadataSuggestions.
    ///- Parameter apiKey: Dadata API token. Check it in account settings at dadata.ru.
    public convenience required init(apiKey: String) {
        self.init(apiKey: apiKey, url: Constants.suggestionsAPIURL)
    }
    
    private init(apiKey: String, url: String) {
        self.apiKey = apiKey
        self.suggestionsAPIURL = URL(string: url)!
    }
    
    ///Get shared instance of DadataSuggestions class.
    ///
    ///Call may throw if neither apiKey parameter is provided
    ///nor a value for key "IIDadataAPIToken" is set in Info.plist
    ///whenever shared instance weren't instantiated earlier.
    ///If another apiKey provided new shared instance of DadataSuggestions recreated with the provided API token.
    ///- Parameter apiKey: Dadata API token. Check it in account settings at dadata.ru.
    public static func shared(apiKey: String? = nil) throws -> DadataSuggestions {
        if let instance = sharedInstance, instance.apiKey == apiKey || apiKey == nil { return instance }
        
        
        if let key = apiKey { sharedInstance = DadataSuggestions(apiKey: key); return sharedInstance! }
        
        let key = try readAPIKeyFromPlist()
        sharedInstance = DadataSuggestions(apiKey: key)
        return sharedInstance!
    }
    
    private static func readAPIKeyFromPlist() throws -> String {
        var dictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            dictionary = NSDictionary(contentsOfFile: path)
        }
        guard let key = dictionary?.value(forKey: Constants.infoPlistTokenKey) as? String else {
            throw NSError(domain: "Dadata API key missing in Info.plist", code: 1, userInfo: nil )
        }
        return key
    }
    
    private func checkAPIConnectivity(timeout: Int) throws {
        var request = createRequest(url:suggestionsAPIURL.appendingPathComponent(Constants.addressEndpoint))
        request.timeoutInterval = TimeInterval(timeout)
        
        let semaphore = DispatchSemaphore.init(value: 0)
        var errorValue: Error?
        
        let session = URLSession.shared
        session.dataTask(with: request){[weak self] data,response,error in
            defer { semaphore.signal() }
            if error != nil { errorValue = error; return }
            if let response = (response as? HTTPURLResponse), (200...299 ~= response.statusCode) == false {
                errorValue = self?.nonOKResponseToError(response: response, body: data)
                return
            }
        }.resume()
        
        semaphore.wait()
        
        if let e = errorValue{
            throw e
        }
    }
    
    private func createRequest(url: URL)->URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Token " + apiKey, forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func nonOKResponseToError(response: HTTPURLResponse, body data: Data?)->Error{
        let code = response.statusCode
        var info: [String: Any] = [:]
        response.allHeaderFields.forEach{ if let k = $0.key as? String { info[k] = $0.value } }
        if let data = data {
            let object = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
            object?.forEach{ if let k = $0.key as? String { info[k] = $0.value } }
        }
        return NSError(domain: "HTTP Status \(HTTPURLResponse.localizedString(forStatusCode: code))", code: code, userInfo: info)
    }
    
    ///Basic address suggestions request with only rquired data.
    ///
    ///- Parameter query: Query string to send to API. String of a free-form e.g. address part.
    ///- Parameter completion: Result handler.
    ///- Parameter result: result of address suggestion query.
    public func suggestAddress(_ query: String, completion: @escaping (_ result: Result<AddressSuggestionResponse, Error>)->Void){
        suggestAddress(AddressSuggestionQuery(query), completion: completion)
    }
    
    ///Address suggestions request.
    ///
    ///Limitations, filters and constraints may be applied to query.
    ///
    ///- Parameter query: Query string to send to API. String of a free-form e.g. address part.
    ///- Parameter queryType: Lets select whether the request type. There are 3 query types available:
    ///`address` — standart address suggestion query;
    ///`fiasOnly` — query to only search in FIAS database: less matches, state provided address data only;
    ///`findByID` — takes KLADR or FIAS ID as a query parameter to lookup additional data.
    ///- Parameter resultsCount: How many suggestions to return. `1` provides more data on a single object
    ///including latitude and longitude. `20` is a maximum value.
    ///- Parameter language: Suggested results may be in Russian or English.
    ///- Parameter constraints: List of `AddressQueryConstraint` objects to filter results.
    ///- Parameter regionPriority: List of RegionPriority objects to prefer in lookup.
    ///- Parameter upperScaleLimit: Bigger `ScaleLevel` object in pair of scale limits.
    ///- Parameter lowerScaleLimit: Smaller `ScaleLevel` object in pair of scale limits.
    ///- Parameter trimRegionResult: Remove region and city names from suggestion top level.
    ///- Parameter completion: Result handler.
    ///- Parameter result: result of address suggestion query.
    public func suggestAddress(_ query: String,
                        queryType: AddressQueryType = .address,
                        resultsCount: Int? = 10,
                        language: QueryResultLanguage? = nil,
                        constraints: [AddressQueryConstraint]? = nil,
                        regionPriority: [RegionPriority]? = nil,
                        upperScaleLimit: ScaleLevel? = nil,
                        lowerScaleLimit: ScaleLevel? = nil,
                        trimRegionResult: Bool = false,
                        completion: @escaping (_ result: Result<AddressSuggestionResponse, Error>)->Void){
        
       let suggestionQuery = AddressSuggestionQuery(query, ofType: queryType)
        
        suggestionQuery.resultsCount = resultsCount
        suggestionQuery.language = language
        suggestionQuery.constraints = constraints
        suggestionQuery.regionPriority = regionPriority
        suggestionQuery.upperScaleLimit = upperScaleLimit != nil ? ScaleBound(value: upperScaleLimit) : nil
        suggestionQuery.lowerScaleLimit = upperScaleLimit != nil ? ScaleBound(value: lowerScaleLimit) : nil
        suggestionQuery.trimRegionResult = trimRegionResult
        
        suggestAddress(suggestionQuery, completion: completion)
    }
    
    ///Address suggestions request.
    ///
    ///Allows to pass most of arguments as a strings converting to internally used classes.
    ///
    ///- Parameter query: Query string to send to API. String of a free-form e.g. address part.
    ///- Parameter queryType: Lets select whether the request type. There are 3 query types available:
    ///`address` — standart address suggestion query;
    ///`fiasOnly` — query to only search in FIAS database: less matches, state provided address data only;
    ///`findByID` — takes KLADR or FIAS ID as a query parameter to lookup additional data.
    ///- Parameter resultsCount: How many suggestions to return. `1` provides more data on a single object
    ///including latitude and longitude. `20` is a maximum value.
    ///- Parameter language: Suggested results in "ru" — Russian or "en" — English.
    ///- Parameter constraints: Literal JSON string formated according to
    ///[Dadata online API documentation](https://confluence.hflabs.ru/pages/viewpage.action?pageId=204669108).
    ///- Parameter regionPriority: List of regions' KLADR IDs to prefer in lookup as shown in
    ///[Dadata online API documentation](https://confluence.hflabs.ru/pages/viewpage.action?pageId=285343795).
    ///- Parameter upperScaleLimit: Bigger sized object in pair of scale limits.
    ///- Parameter lowerScaleLimit: Smaller sized object in pair of scale limits. Both can take following values:
    ///`country` — Страна,
    ///`region` — Регион,
    ///`area` — Район,
    ///`city` — Город,
    ///`settlement` — Населенный пункт,
    ///`street` — Улица,
    ///`house` — Дом,
    ///`country` — Страна,
    ///- Parameter trimRegionResult: Remove region and city names from suggestion top level.
    ///- Parameter completion: Result handler.
    ///- Parameter result: result of address suggestion query.
    public func suggestAddress(_ query: String,
                        queryType: AddressQueryType = .address,
                        resultsCount: Int? = 10,
                        language: String? = nil,
                        constraints: [String]? = nil,
                        regionPriority: [String]? = nil,
                        upperScaleLimit: String? = nil,
                        lowerScaleLimit: String? = nil,
                        trimRegionResult: Bool = false,
                        completion: @escaping (_ result: Result<AddressSuggestionResponse, Error>)->Void){
        
        let queryConstraints: [AddressQueryConstraint]? = constraints?.compactMap{
                if let data = $0.data(using: .utf8) {
                    return try? JSONDecoder().decode(AddressQueryConstraint.self, from:  data )
                }
            return nil
            }
        let prefferedRegions: [RegionPriority]? = regionPriority?.compactMap{ RegionPriority(kladr_id: $0) }

        suggestAddress(query,
                       queryType: queryType,
                       resultsCount: resultsCount,
                       language: QueryResultLanguage(rawValue: language ?? "ru"),
                       constraints: queryConstraints,
                       regionPriority: prefferedRegions,
                       upperScaleLimit: ScaleLevel(rawValue: upperScaleLimit ?? "*"),
                       lowerScaleLimit: ScaleLevel(rawValue: lowerScaleLimit ?? "*"),
                       trimRegionResult: trimRegionResult,
                       completion: completion)
    }
    
    ///Basic address suggestions request to only search in FIAS database: less matches, state provided address data only.
    ///
    ///- Parameter query: Query string to send to API. String of a free-form e.g. address part.
    ///- Parameter completion: Result handler.
    ///- Parameter result: result of address suggestion query.
    public func suggestAddressFromFIAS(_ query: String, completion: @escaping (_ result: Result<AddressSuggestionResponse, Error>)->Void){
        suggestAddress(AddressSuggestionQuery(query, ofType: .fiasOnly), completion: completion)
    }
    
    ///Basic address suggestions request takes KLADR or FIAS ID as a query parameter to lookup additional data.
    ///
    ///- Parameter query: KLADR or FIAS ID.
    ///- Parameter completion: Result handler.
    ///- Parameter result: result of address suggestion query.
    public func suggestByKLADRFIAS(_ query: String, completion: @escaping (_ result: Result<AddressSuggestionResponse, Error>)->Void){
        suggestAddress(AddressSuggestionQuery(query, ofType: .findByID), completion: completion)
    }
    
    ///Address suggestion request with custom `AddressSuggestionQuery`.
    ///
    ///- Parameter query: Query object.
    ///- Parameter completion: Result handler.
    ///- Parameter result: result of address suggestion query.
    public func suggestAddress(_ query: AddressSuggestionQuery, completion: @escaping (_ result: Result<AddressSuggestionResponse, Error>)->Void){
        fetchResponse(withQuery: query, completionHandler: completion)
    }
    
    ///Reverse Geocode request with latitude and longitude as a single string.
    ///
    ///- Throws: May throw if query is malformed.
    ///
    ///- Parameter query: Latitude and longitude as a string. Should have single character separator.
    ///- Parameter delimeter: Character to separate latitude and longitude. Defaults to '`,`'
    ///- Parameter resultsCount: How many suggestions to return. `1` provides more data on a single object
    ///including latitude and longitude. `20` is a maximum value.
    ///- Parameter language: Suggested results in "ru" — Russian or "en" — English.
    ///- Parameter searchRadius: Radius to suggest objects nearest to coordinates point.
    ///- Parameter completion: Result handler.
    ///- Parameter result: result of reverse geocode query.
    public func reverseGeocode(query: String,
                        delimeter: Character = ",",
                        resultsCount: Int? = 10,
                        language: String? = "ru",
                        searchRadius: Int? = nil,
                        completion: @escaping (_ result: Result<AddressSuggestionResponse, Error>)->Void) throws {
        
        let geoquery = try ReverseGeocodeQuery(query: query, delimeter: delimeter)
        geoquery.resultsCount = resultsCount
        geoquery.language = QueryResultLanguage(rawValue: language ?? "ru")
        geoquery.searchRadius = searchRadius
        
        reverseGeocode(geoquery, completion: completion)
    }
    
    ///Reverse Geocode request with latitude and longitude as a single string.
    ///
    ///- Parameter latitude: Latitude.
    ///- Parameter longitude: Longitude.
    ///- Parameter resultsCount: How many suggestions to return. `1` provides more data on a single object
    ///including latitude and longitude. `20` is a maximum value.
    ///- Parameter language: Suggested results may be in Russian or English.
    ///- Parameter searchRadius: Radius to suggest objects nearest to coordinates point.
    ///- Parameter completion: Result handler.
    ///- Parameter result: result of reverse geocode query.
    public func reverseGeocode(latitude: Double,
                        longitude: Double,
                        resultsCount: Int? = 10,
                        language: QueryResultLanguage? = nil,
                        searchRadius: Int? = nil,
                        completion: @escaping (_ result: Result<AddressSuggestionResponse, Error>)->Void){
        let geoquery = ReverseGeocodeQuery(latitude: latitude, longitude: longitude)
        geoquery.resultsCount = resultsCount
        geoquery.language = language
        geoquery.searchRadius = searchRadius
        
        fetchResponse(withQuery: geoquery, completionHandler: completion)
    }
    
    ///Reverse geocode request with custom `ReverseGeocodeQuery`.
    ///
    ///- Parameter query: Query object.
    ///- Parameter completion: Result handler.
    ///- Parameter result: result of reverse geocode query.
    public func reverseGeocode(_ query: ReverseGeocodeQuery, completion: @escaping (_ result: Result<AddressSuggestionResponse, Error>)->Void){
        fetchResponse(withQuery: query, completionHandler: completion)
    }
    
    private func fetchResponse<T>(withQuery query: DadataQueryProtocol, completionHandler completion: @escaping (Result<T, Error>)->Void) where T: Decodable {
        var request = createRequest(url:suggestionsAPIURL.appendingPathComponent(query.queryEndpoint()))
        request.httpBody = try? query.toJSON()
        let session = URLSession.shared
        session.dataTask(with: request){data,response,error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            if let response = (response as? HTTPURLResponse), (200...299 ~= response.statusCode) == false {
                completion(.failure(NSError(domain: "Dadata HTTP response", code: response.statusCode, userInfo: ["description": response.description])))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "Dadata HTTP response", code: -1, userInfo: ["description": "missing data in response"])))
                return
            }
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
                return
            } catch let e {
                completion(.failure(e))
                return
            }
        }.resume()
    }
}
