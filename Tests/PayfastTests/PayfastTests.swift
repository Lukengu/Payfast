import XCTest
@testable import SwiftyJSON
import Payfast



final class PayfastTests: XCTestCase, SubscriptionDelegate {
    func success(_ data: JSON) {
        XCTAssertEqual(data["response"]["status_text"].stringValue,"active")
    }
    
    func failure() {
       
    }
    
    func  testconfiguration(){
        let subscription = Subscription("0baefaf7-2706-4ee7-8182-bf3a20167431")
        XCTAssertEqual(subscription.configuration["apiEndpoint"],"https://api.payfast.co.za/subscriptions/")
    }
    func  testconfigurationNegative(){
        let subscription = Subscription("0baefaf7-2706-4ee7-8182-bf3a20167431")
        XCTAssertNotEqual(subscription.configuration["apiEndpoint"],"anythingelse")
    }
    
    func testFetch() {
        var subscription = Subscription("0baefaf7-2706-4ee7-8182-bf3a20167431")
        subscription.delegate = self
        subscription.get()
        
    }
}
