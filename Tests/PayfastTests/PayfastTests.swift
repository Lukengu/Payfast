import XCTest
@testable import SwiftyJSON
import OrderedCollections
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
    
    func testPaymentProcessor(){
        let purchase: OrderedDictionary = [
            "name_first" : "Bona Philippe",
            "name_last" : "Lukengu",
            "email_address" : "lukengup@aim.com",
            "m_payment_id" : "1122887766554",
            "amount" : "65",
            "item_name": "Monthly Subscription",
            "subscription_type": "1",
            "recurring_amount": "65",
            "frequency": "3",
            "cycles": "12"
            
        ]
        
        
        do {
            try PaymentProcessor.setUp(purchase) { redirectUrl in
                XCTAssertTrue( redirectUrl
                    .contains("payfast.co.za"))
               
                    
            }
            
        } catch {
            print(error)
        }
        
        
        
    }
}
