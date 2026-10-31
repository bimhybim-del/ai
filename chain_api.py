#!/usr/bin/env python3
"""Chain Intelligence API — Full Access to 907TB Blockchain Data"""
import http.server, json, subprocess, urllib.parse, socketserver, threading, hashlib, time, os

API_KEY = "sk-ichainfo-private-7x9Km4Wz8vR2nP5qY6tB3sF1hJ0dL"
CACHE = {}
CACHE_TTL = 300  # 5 min cache

def doris_query(sql, timeout=300):
    cache_key = hashlib.md5(sql.encode()).hexdigest()
    if cache_key in CACHE and time.time() - CACHE[cache_key]["ts"] < CACHE_TTL:
        return CACHE[cache_key]["data"]
    try:
        r = subprocess.run(
            ["mysql", "-h", "14.198.78.149", "-P", "9030", "-u", "admin",
             "--skip-password", "--connect-timeout=10", "-N", "-e", sql],
            capture_output=True, text=True, timeout=timeout
        )
        rows = [l.split("\t") for l in r.stdout.strip().split("\n") if l]
        CACHE[cache_key] = {"data": rows, "ts": time.time()}
        return rows
    except subprocess.TimeoutExpired:
        return [["QUERY_TIMEOUT"]]
    except Exception as e:
        return [["ERROR", str(e)[:100]]]

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        auth = self.headers.get("Authorization", "")
        if auth != f"Bearer {API_KEY}":
            self.reply(401, {"error": "Need header: Authorization: Bearer sk-ichainfo-private-..."})
            return

        p = urllib.parse.urlparse(self.path)
        q = urllib.parse.parse_qs(p.query)
        path = p.path

        if path == "/":
            self.reply(200, {
                "name": "Chain Intelligence API",
                "data": "907TB across 13 blockchains (LIVE)",
                "chains": ["BSC","ETH","BTC","Solana(13 DBs)","DOGE","LTC","TRX","Polygon","Arbitrum","Base","Sonic","TON","BCH"],
                "smart_money": "973 tracked bots, 2.3M trades",
                "endpoints": {
                    "/api/sql": "Raw SQL query (any Doris SQL)",
                    "/api/smart-money/active": "Active profitable bots",
                    "/api/smart-money/trades": "Recent trades by address",
                    "/api/chains/status": "All chains latest block",
                    "/api/address/lookup": "Address info across chains",
                    "/api/tags/count": "Total tagged addresses"
                }
            })

        elif path == "/api/sql":
            sql = q.get("q", [""])[0]
            if not sql:
                self.reply(400, {"error": "Need ?q=SQL_QUERY"})
                return
            rows = doris_query(sql)
            self.reply(200, {"rows": rows, "count": len(rows)})

        elif path == "/api/smart-money/active":
            limit = q.get("limit", ["15"])[0]
            rows = doris_query(f"SWITCH mysql_hk; SELECT address,chain,COUNT(*) as trades,ROUND(SUM(CASE WHEN type=2 THEN CAST(value_usd AS DOUBLE) ELSE 0 END)-SUM(CASE WHEN type=1 THEN CAST(value_usd AS DOUBLE) ELSE 0 END),2) as profit,FROM_UNIXTIME(MAX(timestamp)) as last_trade FROM chainfo_v4.smart_money_records WHERE timestamp>UNIX_TIMESTAMP()-604800 GROUP BY address,chain HAVING profit>0 ORDER BY profit DESC LIMIT {limit}")
            bots = [{"address":r[0],"chain":r[1],"trades":r[2],"profit_usd":r[3],"last_trade":r[4]} for r in rows if len(r)>=5]
            self.reply(200, {"active_bots": bots, "period": "last 7 days"})

        elif path == "/api/smart-money/trades":
            addr = q.get("address", [""])[0]
            limit = q.get("limit", ["20"])[0]
            if not addr:
                self.reply(400, {"error": "Need ?address=WALLET_ADDRESS"})
                return
            rows = doris_query(f"SWITCH mysql_hk; SELECT FROM_UNIXTIME(timestamp),type,token_name,token_address,value_usd,tx_hash FROM chainfo_v4.smart_money_records WHERE address='{addr}' ORDER BY timestamp DESC LIMIT {limit}")
            trades = [{"time":r[0],"type":"buy" if r[1]=="1" else "sell","token":r[2],"token_addr":r[3],"value_usd":r[4],"tx":r[5]} for r in rows if len(r)>=6]
            self.reply(200, {"address": addr, "trades": trades})

        elif path == "/api/chains/status":
            chains = {}
            for db, tbl in [("binance","dwd_bsc_block"),("ethereum","dwd_eth_block"),("bitcoin","dwd_btc_block"),("dogecoin","dwd_doge_block"),("toncoin","dwd_ton_block")]:
                rows = doris_query(f"SELECT MAX(block_height),FROM_UNIXTIME(MAX(block_time)) FROM {db}.{tbl}")
                if rows and len(rows[0]) >= 2:
                    chains[db] = {"latest_block": rows[0][0], "latest_time": rows[0][1]}
            self.reply(200, {"chains": chains})

        elif path == "/api/tags/count":
            rows = doris_query("SELECT COUNT(*) FROM chain.dim_address_tag")
            self.reply(200, {"total_tagged_addresses": rows[0][0] if rows else "unknown"})

        elif path == "/api/address/lookup":
            addr = q.get("address", [""])[0]
            chain = q.get("chain", [""])[0]
            if not addr:
                self.reply(400, {"error": "Need ?address=0x...&chain=bsc|eth"})
                return
            result = {"address": addr}
            if chain.lower() in ["bsc", "binance"]:
                rows = doris_query(f"SELECT receive_amount,send_amount,receive_tx_num,send_tx_num FROM binance.dws_bsc_address_token_statis WHERE address='{addr}' AND token_address='0x0000000000000000000000000000000000000000' LIMIT 1")
                if rows and len(rows[0]) >= 4:
                    result["balance_info"] = {"received": rows[0][0], "sent": rows[0][1], "rx_txs": rows[0][2], "tx_txs": rows[0][3]}
            self.reply(200, result)

        else:
            self.reply(404, {"error": "Unknown endpoint", "see": "/"})

    def do_POST(self):
        self.do_GET()

    def reply(self, code, data):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False, indent=2).encode())

    def log_message(self, *a): pass

socketserver.TCPServer.allow_reuse_address = True
print("Chain Intelligence API on :18889")
with socketserver.TCPServer(("0.0.0.0", 18889), Handler) as s:
    s.serve_forever()
