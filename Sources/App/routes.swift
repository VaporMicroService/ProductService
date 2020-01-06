import Vapor
import Avenue

public func routes(_ router: Router) throws {
    let router = router.grouped("festivals")
    try ProductController().boot(router: router)
    //CRUD routes
    _ = MainController<Vendor>(router: router)
    _ = MainController<Customer>(router: router)
    //Parent-Child relation routes
    _ = ChildController<Vendor, Event>(router: router, keypath: \Event.vendorID)
    _ = ChildController<Vendor, Product>(router: router, keypath: \Product.vendorID)
    _ = ChildController<Vendor, List>(router: router, keypath: \List.vendorID)
    _ = ChildController<Customer, Order>(router: router, keypath: \Order.customerID)
    //Siblings routes
    _ = SiblingController<List, Product, ListProduct>(router: router, keypathLeft: ListProduct.leftIDKey, keypathRight: ListProduct.rightIDKey)
    _ = SiblingController<Event, List, EventProductList>(router: router, keypathLeft: EventProductList.leftIDKey, keypathRight: EventProductList.rightIDKey)
    _ = SiblingController<Order, Product, OrderProduct>(router: router, keypathLeft: OrderProduct.leftIDKey, keypathRight: OrderProduct.rightIDKey)
    _ = SiblingController<Customer, Order, CustomerOrder>(router: router, keypathLeft: CustomerOrder.leftIDKey, keypathRight: CustomerOrder.rightIDKey)
}
