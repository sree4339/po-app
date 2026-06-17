using PurchasingService from './purchasing-service';

// ---- Texts (show names, not GUIDs) ----
annotate PurchasingService.PurchaseOrders with {
  supplier @Common: { Text: supplier.name, TextArrangement: #TextOnly };
}
annotate PurchasingService.PurchaseOrderItems with {
  product  @Common: { Text: product.name, TextArrangement: #TextOnly };
}

// ---- Value Helps ----
annotate PurchasingService.PurchaseOrders with {
  supplier @Common.ValueList: {
    CollectionPath: 'Suppliers',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: supplier_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly',                                 ValueListProperty: 'name' },
      { $Type: 'Common.ValueListParameterDisplayOnly',                                 ValueListProperty: 'country' }
    ]
  };
}
annotate PurchasingService.PurchaseOrderItems with {
  product @Common.ValueList: {
    CollectionPath: 'Products',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut',       LocalDataProperty: product_ID, ValueListProperty: 'ID' },
      { $Type: 'Common.ValueListParameterDisplayOnly',                                ValueListProperty: 'name' },
      { $Type: 'Common.ValueListParameterOut',         LocalDataProperty: unitPrice,  ValueListProperty: 'price' }
    ]
  };
}

// ---- Labels + Field Control (read-only once not Draft) ----
annotate PurchasingService.PurchaseOrders with {
  poNumber     @title: 'PO Number'     @Common.FieldControl: fieldControl;
  supplier     @title: 'Supplier'      @Common.FieldControl: fieldControl;
  priority     @title: 'Priority'      @Common.FieldControl: fieldControl;
  expectedDate @title: 'Expected Date' @Common.FieldControl: fieldControl;
  notes        @title: 'Notes'         @Common.FieldControl: fieldControl;
  status       @title: 'Status'        @readonly;
  totalAmount  @title: 'Total Amount'  @readonly;
}
annotate PurchasingService.PurchaseOrderItems with {
  product    @title: 'Product';
  quantity   @title: 'Quantity';
  unitPrice  @title: 'Unit Price';
  totalPrice @title: 'Line Total' @readonly;
}

// ---- List Report + Object Page ----
annotate PurchasingService.PurchaseOrders with @(
  UI: {
    SelectionFields: [ poNumber, status, priority, supplier_ID ],

    LineItem: [
      { $Type: 'UI.DataField', Value: poNumber },
      { $Type: 'UI.DataField', Value: supplier_ID, Label: 'Supplier' },
      { $Type: 'UI.DataField', Value: priority },
      { $Type: 'UI.DataField', Value: status, Criticality: criticality },
      { $Type: 'UI.DataField', Value: expectedDate },
      { $Type: 'UI.DataField', Value: totalAmount }
    ],

    HeaderInfo: {
      TypeName: 'Purchase Order', TypeNamePlural: 'Purchase Orders',
      Title:       { $Type: 'UI.DataField', Value: poNumber },
      Description: { $Type: 'UI.DataField', Value: supplier_ID }
    },

    HeaderFacets: [
      { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#KPIs', Label: 'Overview' }
    ],
    FieldGroup #KPIs: { Data: [
      { $Type: 'UI.DataField', Value: totalAmount },
      { $Type: 'UI.DataField', Value: status, Criticality: criticality },
      { $Type: 'UI.DataField', Value: priority }
    ]},

    Identification: [
      { $Type: 'UI.DataFieldForAction', Action: 'PurchasingService.submit',  Label: 'Submit for Approval', ![@UI.Hidden]: hideSubmit },
      { $Type: 'UI.DataFieldForAction', Action: 'PurchasingService.approve', Label: 'Approve',              ![@UI.Hidden]: hideApprove },
      { $Type: 'UI.DataFieldForAction', Action: 'PurchasingService.reject',  Label: 'Reject',               ![@UI.Hidden]: hideReject }
    ],

    Facets: [
      { $Type: 'UI.ReferenceFacet', ID: 'General', Label: 'General Information', Target: '@UI.FieldGroup#General' },
      { $Type: 'UI.ReferenceFacet', ID: 'Items',   Label: 'Line Items',         Target: 'items/@UI.LineItem' }
    ],
    FieldGroup #General: { Data: [
      { $Type: 'UI.DataField', Value: poNumber },
      { $Type: 'UI.DataField', Value: supplier_ID, Label: 'Supplier' },
      { $Type: 'UI.DataField', Value: priority },
      { $Type: 'UI.DataField', Value: status, Criticality: criticality },
      { $Type: 'UI.DataField', Value: expectedDate },
      { $Type: 'UI.DataField', Value: notes }
    ]}
  }
);

annotate PurchasingService.PurchaseOrderItems with @(
  UI: {
    LineItem: [
      { $Type: 'UI.DataField', Value: product_ID, Label: 'Product' },
      { $Type: 'UI.DataField', Value: quantity },
      { $Type: 'UI.DataField', Value: unitPrice },
      { $Type: 'UI.DataField', Value: totalPrice }
    ]
  }
);

// ---- Side Effects ----
annotate PurchasingService.PurchaseOrderItems with @(
  Common.SideEffects #ItemTotal: {
    SourceProperties: [ quantity, unitPrice, product_ID ],
    TargetProperties: [ 'totalPrice' ]
  }
);
annotate PurchasingService.PurchaseOrders with @(
  Common.SideEffects #TotalRefresh: {
    SourceEntities:   [ items ],
    TargetProperties: [ 'totalAmount' ]
  }
);