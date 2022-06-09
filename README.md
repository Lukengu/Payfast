# Payfast

Payfast payment and subscription api wrapper -  for the recurring charge on a given date.
PayFast will charge the credit card according to the frequency, billing date and number of payments (cycles) specified in the payment request.
Use the settings plist to store your configurable variable: 
- passphrase  
- merchantID  
- merchantKey 
- returnUrl  
- cancelUrl   
- notifyUrl 
How to use
1. Payment processor 
use statically as follow
PaymentProcessor.setUp([String : String], completion: redirectUrl) where 
[String : String] is the your payment parameters such amount, email_address ...
required element amount, email_address, m_payment_id
2. Recurring Payment
init with the token
var  subscription = Subscription(token)
subscription.delegate = your delegate

    - subscription.get() will return the subscription detail
    - subscription.cancel() will cancel the subscription
    - subscription.pause(_ cycles:Int?) will pause the subscription for the amount of cycles default 1
    - subscription.unpause() will unpause the subscription

The subscription implements a SubscriptionDelegate with two methods 
    -  func success(_ data: JSON)
    -  func failure()
    
Enjoy!


