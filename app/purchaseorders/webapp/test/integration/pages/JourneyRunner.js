sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"purchaseorders/test/integration/pages/PurchaseOrdersList",
	"purchaseorders/test/integration/pages/PurchaseOrdersObjectPage",
	"purchaseorders/test/integration/pages/PurchaseOrderItemsObjectPage"
], function (JourneyRunner, PurchaseOrdersList, PurchaseOrdersObjectPage, PurchaseOrderItemsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('purchaseorders') + '/test/flp.html#app-preview',
        pages: {
			onThePurchaseOrdersList: PurchaseOrdersList,
			onThePurchaseOrdersObjectPage: PurchaseOrdersObjectPage,
			onThePurchaseOrderItemsObjectPage: PurchaseOrderItemsObjectPage
        },
        async: true
    });

    return runner;
});

