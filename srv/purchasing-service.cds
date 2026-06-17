using { com.epm as db } from '../db/schema';

service PurchasingService @(path: '/purchasing') {

  entity PurchaseOrders as projection on db.PurchaseOrders
    actions {
      action submit()                       returns PurchaseOrders;
      action approve(comment : String(500)) returns PurchaseOrders;
      @Common.IsActionCritical
      action reject(reason : String(500))   returns PurchaseOrders;
    };

  entity PurchaseOrderItems as projection on db.PurchaseOrderItems;
  @readonly entity Suppliers as projection on db.Suppliers;
  @readonly entity Products  as projection on db.Products;
}

annotate PurchasingService.PurchaseOrders with @odata.draft.enabled;