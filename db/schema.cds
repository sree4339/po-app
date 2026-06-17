namespace com.epm;
using { cuid, managed } from '@sap/cds/common';

type Priority : String(10) enum { Low='Low'; Medium='Medium'; High='High'; Urgent='Urgent'; };
type Status   : String(15) enum { Draft='Draft'; Pending='Pending'; Approved='Approved'; Rejected='Rejected'; };

entity PurchaseOrders : cuid, managed {
  poNumber        : String(20);
  supplier        : Association to Suppliers;
  priority        : Priority default 'Medium';
  status          : Status   default 'Draft';
  expectedDate    : Date;
  notes           : String(500);
  totalAmount     : Decimal(15,2) default 0;
  rejectReason    : String(500);
  approvalComment : String(500);
  items           : Composition of many PurchaseOrderItems on items.parent = $self;

  // virtual = computed in handler, not stored
  virtual criticality  : Integer;
  virtual fieldControl : Integer;
  virtual hideSubmit   : Boolean;
  virtual hideApprove  : Boolean;
  virtual hideReject   : Boolean;
}

entity PurchaseOrderItems : cuid {
  parent     : Association to PurchaseOrders;
  product    : Association to Products;
  quantity   : Integer default 1;
  unitPrice  : Decimal(15,2) default 0;
  totalPrice : Decimal(15,2) default 0;
}

entity Suppliers : cuid { name : String(100); country : String(50); }
entity Products  : cuid { name : String(100); price   : Decimal(10,2); rating : Integer; }