import Foundation

public class DadataSuggestions {
    private let apiKey: String
    private var suggestionsAPIURL: URL
    private static var sharedInstance: DadataSuggestions?
    
    ///This init checks connectivity once class instance is set.
    ///
    ///This init should not be called on main thread as it may take up to 5+ seconds as it makes request to server in blocking manner.
    ///Throws if connection is impossible.
    ///```
    ///DispatchQueue.global(qos: .background).async {
    ///    let dadata = try DadataSuggestions(apiKey: "*Dadata API token*", secret: "*Dadata secret key*")
    ///}
    ///```
    ///- Parameter apiKey: Dadata API token. Check it in account settings at dadata.ru.
    ///- Parameter secret: Dadata secret key. Check it in account settings at dadata.ru.
    public convenience init(apiKey: String, secret: String) throws {
        self.init(apiKey: apiKey)
        try checkAPIConnectivity(withSecret: secret)
    }
    
    ///New instance of DadataSuggestions.
    ///- Parameter apiKey: DadataSuggestions API token. Check it in account settings at dadata.ru.
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
        
        var dictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            dictionary = NSDictionary(contentsOfFile: path)
        }
        if let key = apiKey { sharedInstance = DadataSuggestions(apiKey: key); return sharedInstance! }
        
        guard let key = dictionary?.value(forKey: Constants.infoPlistTokenKey) as? String else {
            throw NSError(domain: "Dadata API key missing in Info.plist", code: 1, userInfo: nil )
        }
        sharedInstance = DadataSuggestions(apiKey: key)
        return sharedInstance!
    }
    
    private func checkAPIConnectivity(withSecret secret: String) throws {
        let url = URL(string: Constants.checkConnectivityURL)!
        var request = createRequest(url:url)
        request.addValue(secret, forHTTPHeaderField: "X-Secret")
        request.timeoutInterval = 5
        
        let semaphore = DispatchSemaphore.init(value: 0)
        var errorValue: Error?
        
        let session = URLSession.shared
        session.dataTask(with: request){_,response,error in
            defer { semaphore.signal() }
            if error != nil { errorValue = error; return }
            if let code = (response as? HTTPURLResponse)?.statusCode {
                switch code{
                case 401:
                    errorValue = NSError(domain: "Wrong Dadata API Token", code: code, userInfo: nil)
                case 403:
                    errorValue = NSError(domain: "Dadata API limits exceeded", code: code, userInfo: nil)
                case 404:
                    errorValue = NSError(domain: "Wrong URL", code: code, userInfo: nil)
                default:
                    errorValue = nil
                }
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
    
    public func suggestAddress(_ query: String, completion: @escaping (Result<AddressSuggestionResponse, Error>)->Void){
        suggestAddress(AddressSuggestionQuery(query), completion: completion)
    }
    
    public func suggestAddress(_ query: String,
                        queryType: AddressQueryType = .address,
                        resultsCount: Int? = 10,
                        language: QueryResultLanguage? = nil,
                        constraints: [AddressQueryConstraint]? = nil,
                        regionPriority: [RegionPriority]? = nil,
                        upperScaleLimit: ScaleLevel? = nil,
                        lowerScaleLimit: ScaleLevel? = nil,
                        trimRegionResult: Bool = false,
                        completion: @escaping (Result<AddressSuggestionResponse, Error>)->Void){
        
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
    
    public func suggestAddress(_ query: String,
                        queryType: AddressQueryType = .address,
                        resultsCount: Int? = 10,
                        language: String? = nil,
                        constraints: [String]? = nil,
                        regionPriority: [String]? = nil,
                        upperScaleLimit: String? = nil,
                        lowerScaleLimit: String? = nil,
                        trimRegionResult: Bool = false,
                        completion: @escaping (Result<AddressSuggestionResponse, Error>)->Void){
        
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
    
    public func suggestAddressFromFIAS(_ query: String, completion: @escaping (Result<AddressSuggestionResponse, Error>)->Void){
        suggestAddress(AddressSuggestionQuery(query, ofType: .fiasOnly), completion: completion)
    }
    
    public func suggestByKLADRFIAS(_ query: String, completion: @escaping (Result<AddressSuggestionResponse, Error>)->Void){
        suggestAddress(AddressSuggestionQuery(query, ofType: .findByID), completion: completion)
    }
    
    public func suggestAddress(_ query: AddressSuggestionQuery, completion: @escaping (Result<AddressSuggestionResponse, Error>)->Void){
        fetchResponse(withQuery: query, completionHandler: completion)
    }
    
    public func reverseGeocode(query: String,
                        delimeter: Character = ",",
                        resultsCount: Int? = 10,
                        language: String? = "ru",
                        searchRadius: Int? = nil,
                        completion: @escaping (Result<AddressSuggestionResponse, Error>)->Void) throws {
        
        let geoquery = try ReverseGeocodeQuery(query: query, delimeter: delimeter)
        geoquery.resultsCount = resultsCount
        geoquery.language = QueryResultLanguage(rawValue: language ?? "ru")
        geoquery.searchRadius = searchRadius
        
        reverseGeocode(geoquery, completion: completion)
    }
    
    public func reverseGeocode(latitude: Double,
                        longitude: Double,
                        resultsCount: Int? = 10,
                        language: QueryResultLanguage? = nil,
                        searchRadius: Int? = nil,
                        completion: @escaping (Result<AddressSuggestionResponse, Error>)->Void){
        fetchResponse(withQuery: ReverseGeocodeQuery(latitude: latitude, longitude: longitude), completionHandler: completion)
    }
    
    public func reverseGeocode(_ query: ReverseGeocodeQuery, completion: @escaping (Result<AddressSuggestionResponse, Error>)->Void){
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
