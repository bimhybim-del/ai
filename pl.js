const m=require("mysql2/promise");
(async()=>{
  const c=await m.createConnection({host:"aether.mysql.prod.yoi.local",user:"aether-svc",password:"f9pXQYRxALywyVIw",database:"yoi",connectTimeout:8000});
  const[r]=await c.query("SELECT COUNT(*) c FROM conduit_apirequestlog WHERE service_name='payment'");
  console.log("TOTAL:"+r[0].c);
  const[d]=await c.query("SELECT id,endpoint_path,LEFT(request_data,200) rd FROM conduit_apirequestlog WHERE service_name='payment' AND endpoint_path LIKE '%disburs%' ORDER BY id DESC LIMIT 3");
  d.forEach(x=>console.log(x.id+"|"+x.endpoint_path+"|"+String(x.rd).slice(0,150)));
  await c.end();
})().catch(e=>console.log("E:"+e.message.slice(0,100)));
