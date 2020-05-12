//
//  ReverseGeocodeQuery.swift
//  IIDadata
//
//  Created by Yachin Ilya on 12.05.2020.
//

import Foundation

public class ReverseGeocodeQuery: Encodable, DadataQueryProtocol{
    let latitude: Double
    let longitude: Double
    let endpoint: String
    var resultsCount: Int? = 10
    var language: QueryResultLanguage?
    var searchRadius: Int?
    
    convenience init(query: String, delimeter: Character = ",") throws {
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
    
    required init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
        self.endpoint = Constants.revGeocodeEndpoint
    }
    
    func toJSON() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func queryEndpoint() -> String { return endpoint }
}
