//
//  ReverseGeocodeQuery.swift
//  IIDadata
//
//  Created by Yachin Ilya on 12.05.2020.
//

import Foundation

///ReverseGeocodeQuery represents an serializable object used to perform reverse geocode queries.
public class ReverseGeocodeQuery: Encodable, DadataQueryProtocol{
    let latitude: Double
    let longitude: Double
    let endpoint: String
    public var resultsCount: Int? = 10
    public var language: QueryResultLanguage?
    public var searchRadius: Int?
    
    ///New instance of ReverseGeocodeQuery.
    ///- Parameter query: Query should contain latitude and longitude of the point of interest.
    ///- Parameter delimeter: Single character delimeter to separate latitude and longitude.
    ///- Throws: May throw if parsing of latitude and longitude out of query fails.
    public convenience init(query: String, delimeter: Character = ",") throws {
        let splitStr = query.split(separator: delimeter)
        
        let latStr = String(splitStr[0]).trimmingCharacters(in: .whitespacesAndNewlines)
        let lonStr = String(splitStr[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let latitude = Double(latStr),
            let longitude = Double(lonStr)
            else {
                throw NSError(domain: "Dadata ReverseGeocodeQuery",
                                 code: -1,
                                 userInfo: ["description" : "Failed to parse coordinates from \(query) uding delimeter \(delimeter)"]
                )
        }
        
        self.init(latitude: latitude, longitude: longitude)
    }
    
    ///New instance of ReverseGeocodeQuery.
    ///- Parameter latitude: Latitude of the point of interest.
    ///- Parameter longitude: Longitude of the point of interest.
    public required init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
        self.endpoint = Constants.revGeocodeEndpoint
    }
    
    ///Serializes ReverseGeocodeQuery to send over the wire.
    func toJSON() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    ///Returns an API endpoint for reverse geocode query.
    func queryEndpoint() -> String { return endpoint }
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
        case resultsCount = "count"
        case language
        case searchRadius = "radius_meters"
    }
}
