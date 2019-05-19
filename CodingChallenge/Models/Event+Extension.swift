//
//  Event+Extension.swift
//  CodingChallenge
//
//  Created by Vincil Bishop on 5/18/19.
//  Copyright © 2019 Vrbo. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireCoreData
import Groot
import SugarRecord

extension Event {
    
    public enum Request: URLRequestConvertible {
        case query(_ queryString: String)
        
        static let clientId = "MTY2ODQ4NDB8MTU1ODE4NjQwNC41NA"
        static let baseURLString = "https://api.seatgeek.com/"
        
        // MARK: URLRequestConvertible
        
        public func asURLRequest() throws -> URLRequest {
            let result: (path: String, parameters: Parameters) = {
                switch self {
                case let .query(queryString):
                    return ("2/events", ["client_id": Request.clientId, "q": queryString])
                }
            }()
            
            let url = try  Request.baseURLString.asURL()
            let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
            
            return try URLEncoding.default.encode(urlRequest, with: result.parameters)
        }
    }
    
    public static func getEvents(_ query: String, _ completion: ((_ response: DataResponse<Many<Event>>) -> Void)? = nil) -> Void  {
        
        let jsonTransformer = DataRequest.jsonTransformerSerializer { (responseInfo, result) -> Result<Any> in
            guard result.isSuccess else {
                return result
            }
            
            let json = result.value as! [String: Any]
            let success = json["events"] != nil
            switch success {
            case true:
                return Result.success(json["events"]!)
            default:
                // here we should create our own error and send it
                return Result.failure("JSON Transofrmer failure")
            }
        }
        
        do {
            _ = try AppData.shared.db.operation { (context, save) throws in
                
                Alamofire.SessionManager.default.request(Request.query(query)).responseInsert(jsonSerializer: jsonTransformer, context: context.managedObjectContext(), type: Many<Event>.self, completionHandler: { (response) in
                    
                    save()
                   
                    if (completion != nil) {
                        completion!(response)
                    }
                })
                
            }
        } catch {
            // There was an error in the operation
            print("Unexpected error: \(error).")
            
        }
    }
    
    public func imageUrl() -> URL? {
        // TODO: Ensure this is pulling the correct home/away team
        let performersSet = self.performers!
        let performersArray: [Performer] = performersSet.array as! [Performer]
        if (performersArray.count > 0) {
            if let imageUrlString = performersArray.first?.imageUrlString {
                return URL(string: imageUrlString)
            }
        }
        
        return nil
    }
}
