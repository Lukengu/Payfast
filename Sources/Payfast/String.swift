//
//  File.swift
//  
//
//  Created by FGX on 2022/06/09.
//

import Foundation
import CommonCrypto

extension String  {
    var md5: String! {
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes {digestBytes in
                messageData.withUnsafeBytes {messageBytes in
                    CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
                }
            }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var escapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
 }
