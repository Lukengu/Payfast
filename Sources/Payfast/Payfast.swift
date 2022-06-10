//
//  PayFast.swift
//  
//
//  Created by Philippe Bona on 2022/06/09.
//

import Foundation
import SwiftyJSON
import Alamofire


public protocol SubscriptionDelegate {
    func success(_ data: JSON)
    func failure()
    
}
enum Action: String, CaseIterable{
    case  pause = "pause"
    case  unpause = "unpause"
    case  cancel = "cancel"
    case  fetch = "fetch"
}

enum HttpMethod: String, CaseIterable {
    case put = "PUT"
    case get = "GET"
}




public struct Subscription {
    private var token:String!
    public var delegate:SubscriptionDelegate?
    public var configuration: [String: String]!
    
    /// Payfast Subscription Object
    /// - Parameter token: Payfast  recurring billing subscription or recurring adhoc token
    public init(_ token : String) {
        self.token = token
        if let infoPlistUrl = Bundle.module.url(forResource: "settings", withExtension: "plist"),
           let dict = NSDictionary(contentsOf: infoPlistUrl) as? [String: String] {
            configuration = dict
        }
        
    }
    
    ///Get the subsccription object
    public func get(){
        execute(.fetch, method: .get)
    }
    
    ///Cancels the subscription entirely. When a subscription is cancelled the customer will be notified of this via email.
    public func cancel(){
        execute(.cancel, method: .put)
    }
    
    ///Pauses the subscription.
    public func pause(_ cycles:Int? = nil){
        var params:[String:String] = [:]
        if(cycles != nil){
            params = ["cycles":String(cycles!)]
        }
        execute(.pause, method: .put, params: params)
    }
    ///UnPauses the subscription.
    public func unpause() {
        execute(.unpause, method: .put)
    }
    
    
    private func addHeaders(_ request: inout URLRequest, params:[String:String]? = nil){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        
       
        request.addValue(configuration["merchantID"]!,forHTTPHeaderField:"merchant-id")
        request.addValue(timestamp,forHTTPHeaderField:"timestamp")
        request.addValue( "v1",forHTTPHeaderField:"version")
        request.addValue(generateSignature(with: timestamp, for: params), forHTTPHeaderField: "signature")
        
    }
    
    private func getUrl(action:String) -> URLRequest{
        return URLRequest(url: URL(string:String(format:configuration["apiEndpoint"]!+token+"/%@", action))!,timeoutInterval: Double.infinity)
    }
    
    private func getRequestBody(_ params: [String:String]) -> Data {
        var body = ""
        params.forEach({ key,value in
            body += key+"="+value+"&"
        })
        body = body.trimmingCharacters(in: ["&"])
        return body.data(using: .utf8)!
    }
    
    private func generateSignature(with timestamp:String, for params:[String:String]? = nil) -> String {
        var signature = ""
        
        if(params != nil){
            params?.forEach({ key,value in
                signature += key+"="+value.escapedString+"&"
            })
        }
        
        signature += "merchant-id="+configuration["merchantID"]!.escapedString
        signature += "&passphrase="+configuration["passphrase"]!.escapedString
        signature += "&timestamp="+timestamp.escapedString
        signature += "&version="+"v1".escapedString
    
        return signature.md5
    }
    
    private func execute(_ action:Action,method:HttpMethod,params:[String:String]? = nil){
        
        var request = getUrl(action: action.rawValue)
        
        addHeaders(&request, params: params)
        
        if(params != nil) {
            request.httpBody = getRequestBody(params!)
        }
        
        request.httpMethod  = method.rawValue
        
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let af = AF.request(request)
        
        af.responseJSON {  [self] response   in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                delegate?.success(json)
                
            case .failure(_):
                delegate?.failure()
            }
           
        }
    }
    
}
