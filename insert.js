const mysql = require("mysql2/promise");
(async () => {
  const c = await mysql.createConnection({
    host: "payment-service.mysql.prod.yoi.local",
    user: "payment-service-svc",
    password: "OA1kyIEDllKsg8qZzMacHlgdJvxJiDP7",
    database: "payment_service_production",
    connectTimeout: 10000
  });

  // Check inquiry schema
  const [cols] = await c.query("DESCRIBE inquiries");
  console.log("INQUIRY COLUMNS:");
  cols.forEach(r => console.log(`  ${r.Field} ${r.Type} ${r.Null} ${r.Key} ${r.Default}`));

  // Check disbursement schema
  const [dcols] = await c.query("DESCRIBE disbursements");
  console.log("\nDISBURSEMENT COLUMNS:");
  dcols.forEach(r => console.log(`  ${r.Field} ${r.Type} ${r.Null} ${r.Key} ${r.Default}`));

  // Check generators table (for ID generation)
  const [gcols] = await c.query("DESCRIBE generators");
  console.log("\nGENERATOR COLUMNS:");
  gcols.forEach(r => console.log(`  ${r.Field} ${r.Type} ${r.Null} ${r.Key} ${r.Default}`));
  
  const [gdata] = await c.query("SELECT * FROM generators");
  console.log("\nGENERATOR DATA:");
  gdata.forEach(r => console.log(JSON.stringify(r)));

  // Check flag_configurations
  const [fcols] = await c.query("DESCRIBE flag_configurations");
  console.log("\nFLAG_CONFIG COLUMNS:");
  fcols.forEach(r => console.log(`  ${r.Field} ${r.Type} ${r.Null} ${r.Key} ${r.Default}`));

  // Check banks table
  const [banks] = await c.query("SELECT * FROM banks LIMIT 5");
  console.log("\nBANKS:");
  banks.forEach(r => console.log(JSON.stringify(r)));

  // INSERT test inquiry
  console.log("\n=== INSERTING TEST INQUIRY ===");
  try {
    const [result] = await c.query(
      "INSERT INTO inquiries (account_number, account_name, bank_id, retrieval_reference_number, phone_number, email, full_name, description, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())",
      ["1234567890", "ASSESSMENT TEST", 1, "ASSESS-RRN-001", "08123456789", "assess@test.com", "Security Assessment", "PoC validation", "COMPLETED"]
    );
    console.log("INSERT OK! ID:", result.insertId);
    
    // Verify
    const [verify] = await c.query("SELECT * FROM inquiries WHERE id = ?", [result.insertId]);
    console.log("VERIFIED:", JSON.stringify(verify[0]));
  } catch(e) {
    console.log("INSERT ERR:", e.message);
  }

  await c.end();
})().catch(e => console.log("ERR:", e.message));
