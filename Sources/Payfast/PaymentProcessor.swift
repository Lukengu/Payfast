//
//  File.swift
//  
//
//  Created by FGX on 2022/06/10.
//

import Foundation
import OrderedCollections
import RegEx

enum RequiredKeyError: Error {
    case runtimeError(String)
}

public struct PaymentProcessor {
    public typealias redirectUrl = (_ redirectUrl : String ) -> Void
    
    private static func getConfiguration() -> [String:String]?{
        if let infoPlistUrl = Bundle.module.url(forResource: "settings", withExtension: "plist"),
           let configuration = NSDictionary(contentsOf: infoPlistUrl) as? [String: String] {
            return configuration
        }
        return nil
        
    }
    private static func generateSignature(_ purchase: OrderedDictionary<String,String>, for date:String)-> String {
        var signature = ""
        guard let configuration = PaymentProcessor.getConfiguration() else {
            return signature
        }
        
        signature += "merchant_id="+configuration["merchantID"]!.escapedString+"&"
        signature += "merchant_key="+configuration["merchantKey"]!.trimmingCharacters(in: [" "]).escapedString+"&"
        signature += "return_url="+configuration["returnUrl"]!.trimmingCharacters(in: [" "]).escapedString+"&"
        signature += "cancel_url="+configuration["cancelUrl"]!.trimmingCharacters(in: [" "]).escapedString+"&"
        signature += "notify_url="+configuration["notifyUrl"]!.trimmingCharacters(in: [" "]).escapedString+"&"
        
        for key in purchase.keys {
            signature += key+"="+purchase[key]!.trimmingCharacters(in: [" "]).escapedString+"&"
        }
    
        signature +=  "passphrase="+configuration["passphrase"]!.trimmingCharacters(in: [" "]).escapedString

            signature = signature.replacingOccurrences(of: "%20", with:"+")
            return signature.md5
    }
    
    public static func setUp  (_ purchase:OrderedDictionary<String,String>, completion: @escaping redirectUrl ) throws {
        if !purchase.keys.contains("m_payment_id") {
            throw RequiredKeyError.runtimeError("m_payment_id key not set")
        } else if !purchase.keys.contains("email_address") {
            throw RequiredKeyError.runtimeError("email_address key not set")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        let headers:[String:String] = [
            "Accept": "*/*",
            "Cache-Control": "no-cache",
            "accept-encoding": "*",
            "Connection": "keep-alive",
            "cache-control": "no-cache",
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        guard let configuration = PaymentProcessor.getConfiguration() else {
            completion("")
            return
        }
        var bodyRequest = URLComponents()
        bodyRequest.queryItems = [
            URLQueryItem(name:"merchant_id", value:configuration["merchantID"]!),
            URLQueryItem(name:"merchant_key", value:configuration["merchantKey"]!),
            URLQueryItem(name:"return_url", value:configuration["returnUrl"]!),
            URLQueryItem(name:"cancel_url", value:configuration["cancelUrl"]!),
            URLQueryItem(name:"notify_url", value:configuration["notifyUrl"]!)
        ];
        
        for key in purchase.keys {
            bodyRequest.queryItems!.append(URLQueryItem(name: key, value: purchase[key]))
        }
        bodyRequest.queryItems!.append(URLQueryItem(name:"signature", value: generateSignature(purchase, for:date)))
        
        var request = URLRequest(url: URL(string: configuration["paymentUrl"]!)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = bodyRequest.query?.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { data, response, error in
            var html = String(bytes: data!, encoding: String.Encoding.utf8)
            html = html?.replacingOccurrences(of: "/eng", with: "https://www.payfast.co.za/eng")
            
            let expression = "<meta http-equiv=\"Refresh\" content=\"0; url=(.*?)\\?noscript=true\">"
            guard let regex =  try? RegEx(pattern: expression) else {
                completion("")
                return
            }
            print("HTML _______")
            print(html)
            let matches = regex.matches(in: html!)
            completion( String(matches[0].values[1]!))
            
        }.resume()
        
        
    }
    
}
