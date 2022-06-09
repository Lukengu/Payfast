import XCTest
@testable import SwiftyJSON
import Payfast



final class PayfastTests: XCTestCase, SubscriptionDelegate {
    func success(_ data: JSON) {
        XCTAssertEqual(data["status"].stringValue,"active")
    }
    
    func failure() {
       
    }
    
    func testFetch() throws {
        var subscription = try Subscription("0baefaf7-2706-4ee7-8182-bf3a20167431")
        subscription.delegate = self
        subscription.get()
        
    }
}
