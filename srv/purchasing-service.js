const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {
  const { PurchaseOrders, PurchaseOrderItems } = this.entities;

  const criticalityOf = (s) =>
    s === 'Approved' ? 3 : s === 'Pending' ? 2 : s === 'Rejected' ? 1 : 0;

  // ---- Criticality / button visibility / live totals (draft + active) ----
  this.after('READ', 'PurchaseOrders', async (data) => {
    for (const po of [].concat(data)) {
      if (!po || !po.ID) continue;
      po.criticality  = criticalityOf(po.status);
      po.fieldControl = po.status === 'Draft' ? 7 : 1;   // 7=editable, 1=read-only
      po.hideSubmit   = po.status !== 'Draft';
      po.hideApprove  = po.status !== 'Pending';
      po.hideReject   = po.status !== 'Pending';
      try {
        const src   = po.IsActiveEntity === false ? PurchaseOrderItems.drafts : PurchaseOrderItems;
        const items = await SELECT.from(src).where({ parent_ID: po.ID });
        po.totalAmount = items.reduce((s, i) => s + (i.quantity || 0) * (i.unitPrice || 0), 0);
      } catch (e) { /* keep stored total */ }
    }
  });

  this.after('READ', 'PurchaseOrderItems', (data) => {
    for (const it of [].concat(data)) {
      if (it && it.quantity != null && it.unitPrice != null)
        it.totalPrice = it.quantity * it.unitPrice;
    }
  });

  // ---- Validation + persist totals on Save (draft activation) ----
  this.before('SAVE', 'PurchaseOrders', (req) => {
    const { poNumber, supplier_ID, items = [] } = req.data;
    if (!poNumber)    req.error({ target: 'poNumber',    message: 'PO Number is required' });
    if (!supplier_ID) req.error({ target: 'supplier_ID', message: 'Supplier is required' });
    if (!items.length) req.error('At least one line item is required');
    let total = 0;
    for (const it of items) { it.totalPrice = (it.quantity || 0) * (it.unitPrice || 0); total += it.totalPrice; }
    req.data.totalAmount = total;
  });

  // ---- Actions (status checks) ----
  const load = (req) => SELECT.one.from(PurchaseOrders).where({ ID: req.params.at(-1).ID });

  this.on('submit', 'PurchaseOrders', async (req) => {
    const po = await load(req);
    if (!po) return req.error(404, 'PO not found');
    if (po.status !== 'Draft') return req.error(400, `Only Draft POs can be submitted (current: ${po.status})`);
    await UPDATE(PurchaseOrders).set({ status: 'Pending' }).where({ ID: po.ID });
    return SELECT.one.from(PurchaseOrders).where({ ID: po.ID });
  });

  this.on('approve', 'PurchaseOrders', async (req) => {
    const po = await load(req);
    if (!po) return req.error(404, 'PO not found');
    if (po.status !== 'Pending') return req.error(400, `Only Pending POs can be approved (current: ${po.status})`);
    await UPDATE(PurchaseOrders).set({ status: 'Approved', approvalComment: req.data.comment }).where({ ID: po.ID });
    return SELECT.one.from(PurchaseOrders).where({ ID: po.ID });
  });

  this.on('reject', 'PurchaseOrders', async (req) => {
    const { reason } = req.data;
    if (!reason) return req.error(400, 'A rejection reason is required');
    const po = await load(req);
    if (!po) return req.error(404, 'PO not found');
    if (po.status !== 'Pending') return req.error(400, `Only Pending POs can be rejected (current: ${po.status})`);
    await UPDATE(PurchaseOrders).set({ status: 'Rejected', rejectReason: reason }).where({ ID: po.ID });
    return SELECT.one.from(PurchaseOrders).where({ ID: po.ID });
  });
});