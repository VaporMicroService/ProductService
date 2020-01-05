import Vapor

struct Pagination: Content {
    var offset: Int?
    var length: Int?
}

var decoderJSON: JSONDecoder = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
}()

public func routes(_ router: Router) throws {
    //CRUD routes
    try MainController<Vendor>().boot(router: router)
    try MainController<Customer>().boot(router: router)
    //Parent-Child relation routes
    try ChildController<Vendor, Event>(keypath: \Event.vendorID).boot(router: router)
    try ChildController<Vendor, Product>(keypath: \Product.vendorID).boot(router: router)
    try ChildController<Vendor, List>(keypath: \List.vendorID).boot(router: router)
    try ChildController<Customer, Order>(keypath: \Order.customerID).boot(router: router)
    //Siblings routes
    try SiblingController<List, Product, ListProduct>(keypathLeft: ListProduct.leftIDKey, keypathRight: ListProduct.rightIDKey).boot(router: router)
    try SiblingController<Event, List, EventProductList>(keypathLeft: EventProductList.leftIDKey, keypathRight: EventProductList.rightIDKey).boot(router: router)
    try SiblingController<Order, Product, OrderProduct>(keypathLeft: OrderProduct.leftIDKey, keypathRight: OrderProduct.rightIDKey).boot(router: router)
    try SiblingController<Customer, Order, CustomerOrder>(keypathLeft: CustomerOrder.leftIDKey, keypathRight: CustomerOrder.rightIDKey).boot(router: router)
}
