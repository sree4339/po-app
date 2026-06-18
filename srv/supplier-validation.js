// Supplier validation handler (skeleton)
// Supplier validation handler
// Verifies that the given supplier_ID exists in Suppliers before save.
module.exports = async function validateSupplier(req, Suppliers, supplier_ID) {
  if (!supplier_ID) return; // already handled by required-field check
  const exists = await SELECT.one.from(Suppliers).where({ ID: supplier_ID });
  if (!exists) {
    req.error({ target: 'supplier_ID', message: `Supplier ${supplier_ID} does not exist` });
  }
};