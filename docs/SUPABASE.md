# Supabase (ระบบรับข้อมูล MT4)

## สรุปย่อ ✅

ไฟล์นี้อธิบายการเชื่อมต่อและโครงสร้างข้อมูลที่ใช้โดย Supabase Edge Function ที่รับข้อมูลจาก MT4 (mt4-receiver) และเก็บลงฐานข้อมูล (ตาราง `accounts` และ `history`) โดยไม่แก้โค้ดในโปรเจกต์ — เอกสารนี้อธิบายการทำงาน, payload, ตัวอย่าง, และ SQL schema ที่เกี่ยวข้อง

---

## โครงสร้าง & จุดประสงค์ 🔧

- **Edge Function location:** `supabase/functions/mt4-receiver/index.ts` (ตัวอย่างในเอกสาร)
- **หน้าที่:** รับ HTTP POST ที่มี JSON payload (รองรับทั้ง single object และ array) → ทำการ upsert ข้อมูลบัญชี (`accounts`) → upsert ประวัติ (`history`) โดยมี key สำหรับความเป็นเอกลักษณ์คือ `acc_number` ใน `accounts` และ `(account_id, date)` ใน `history`.
- **Environment variables (ต้องตั้ง):**
  - `SUPABASE_URL`
  - `SUPABASE_SERVICE_ROLE_KEY` (ใช้เพื่อเชื่อมต่อด้วย service role)

---

## Endpoint: Usage & Behavior 📥

- **Method:** POST
- **Content-Type:** application/json
- **รับได้ทั้ง:** 1) single JSON object 2) array of JSON objects

Behavior details:

- ถ้า payload เป็น array จะวนลูปประมวลผลทีละบัญชี (per-account processing)
- ฟังก์ชันจะตรวจสอบความสมบูรณ์ของฟิลด์สำคัญ (`acc_number` และ `date`) หากขาดจะเก็บเป็น error สำหรับรายการนั้น ๆ แล้วดำเนินการกับรายการถัดไป
- หากเกิดข้อผิดพลาดจากการ upsert ของแต่ละบัญชี ฟังก์ชันจะเพิ่มรายละเอียดลงใน `errors` แต่จะไม่หยุดการประมวลผลของรายการอื่น
- Response จะสรุปทั้ง `total_received`, `success_count`, `error_count`, `results` และถ้ามี ошибки จะมี `errors` รายการ

---

## Payload (ตัวอย่าง) 🧾

ตัวอย่าง single object:

```json
{
  "acc_number": 123456,
  "date": "2025-12-16",
  "balance": 1000.5,
  "equity": 1100.0,
  "current": {
    "total_trade": 5,
    "profit": 120,
    "lot": 1.2,
    "order_buy_count": 3,
    "order_sell_count": 2
  },
  "history": {
    "total_trade": 50,
    "profit": 700,
    "lot": 10.5,
    "order_buy_count": 30,
    "order_sell_count": 20,
    "win": 25,
    "loss": 25
  }
}
```

และตัวอย่าง array:

```json
[
  { "acc_number": 123, "date": "2025-12-16" },
  { "acc_number": 456, "date": "2025-12-16", "balance": 500 }
]
```

ข้อสังเกต:

- `acc_number` และ `date` เป็นฟิลด์ที่ต้องมี (required)
- ฟิลด์อื่น ๆ เป็น optional — หากไม่มี จะถูกตั้งเป็นค่าเริ่มต้น (เช่น 0) ตาม schema

---

## Responses (ตัวอย่าง) ✅❌

- **Success (ส่วนใหญ่สำเร็จ):**

```json
{
  "total_received": 2,
  "success_count": 2,
  "error_count": 0,
  "results": [
    {
      "success": true,
      "account_id": 1,
      "acc_number": 123,
      "date": "2025-12-16"
    },
    {
      "success": true,
      "account_id": 2,
      "acc_number": 456,
      "date": "2025-12-16"
    }
  ]
}
```

- **Partial errors (มีรายการที่ล้มเหลว):**

```json
{
  "total_received": 2,
  "success_count": 1,
  "error_count": 1,
  "results": [
    {
      "success": true,
      "account_id": 1,
      "acc_number": 123,
      "date": "2025-12-16"
    }
  ],
  "errors": [
    {
      "index": 1,
      "acc_number": 456,
      "error": "Missing required fields: acc_number or date"
    }
  ]
}
```

- **Fail all:** HTTP status 500 ถูกส่งถ้าทุกรายการล้มเหลว; ถ้าอย่างอื่นสำเร็จ จะส่ง 200 พร้อมสรุป

---

## ตัวอย่างการทดสอบ (curl) 🧪

```bash
curl -X POST https://YOUR-EDGE-FUNCTION-URL -H 'Content-Type: application/json' -d '[{"acc_number":123,"date":"2025-12-16"}]'
```

---

## SQL Schema (สำคัญ) 🗂️

ต่อไปนี้คือ SQL statements ที่โปรเจกต์ใช้ (หรือใช้เป็นตัวอย่างการตั้งค่า DB):

```sql
-- =========================
-- updated (realtime trigger)
-- =========================
CREATE TABLE IF NOT EXISTS public.updated (
  id SERIAL PRIMARY KEY,
  title varchar NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- run once
INSERT INTO public.updated (title)
SELECT 'update'
WHERE NOT EXISTS (SELECT 1 FROM public.updated);

-- =========================
-- run_at
-- =========================
CREATE TABLE IF NOT EXISTS public.run_at (
  id SERIAL PRIMARY KEY,
  title varchar NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- =========================
-- accounts
-- =========================
CREATE TABLE IF NOT EXISTS public.accounts (
  id SERIAL PRIMARY KEY,
  acc_number bigint NOT NULL,
  name varchar,
  email varchar,
  balance numeric DEFAULT 0,
  equity numeric DEFAULT 0,
  run_at_id integer,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT accounts_run_at_id_fkey
    FOREIGN KEY (run_at_id)
    REFERENCES public.run_at (id)
    ON DELETE SET NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS accounts_acc_number_key
ON public.accounts (acc_number);

-- =========================
-- history
-- =========================
CREATE TABLE IF NOT EXISTS public.history (
  id SERIAL PRIMARY KEY,
  account_id integer NOT NULL,
  date date NOT NULL,
  current_total_trade integer DEFAULT 0,
  current_profit numeric DEFAULT 0,
  current_lot numeric DEFAULT 0,
  current_order_buy_count integer DEFAULT 0,
  current_order_sell_count integer DEFAULT 0,
  history_total_trade integer DEFAULT 0,
  history_profit numeric DEFAULT 0,
  history_lot numeric DEFAULT 0,
  history_order_buy_count integer DEFAULT 0,
  history_order_sell_count integer DEFAULT 0,
  history_win integer DEFAULT 0,
  history_loss integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT history_account_id_fkey
    FOREIGN KEY (account_id)
    REFERENCES public.accounts (id)
    ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS history_account_id_date_key
ON public.history (account_id, date);

-- add updated table to realtime
ALTER PUBLICATION supabase_realtime
ADD TABLE public.updated;

-- replica identity (สำคัญมาก)
ALTER TABLE public.updated
REPLICA IDENTITY FULL;
```

update for ENABLE ROW LEVEL SECURITY

```sql
-- Enable RLS on the tables used by the project
BEGIN;

ALTER TABLE public.updated ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.run_at ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.history ENABLE ROW LEVEL SECURITY;

-- allow realtime read
CREATE POLICY "updated_select_anon"
ON public.updated
FOR SELECT
TO anon
USING (true);

-- block anon write
CREATE POLICY "updated_no_insert_anon"
ON public.updated
FOR INSERT
TO anon
WITH CHECK (false);

CREATE POLICY "updated_no_update_anon"
ON public.updated
FOR UPDATE
TO anon
USING (false);

CREATE POLICY "run_at_all"
ON "public"."run_at"
TO public
using (true);

CREATE POLICY "accounts_select_anon"
ON public.accounts
FOR SELECT
TO anon
USING (true);

CREATE POLICY "accounts_update_anon"
ON public.accounts
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

CREATE POLICY "accounts_delete_anon"
ON public.accounts
FOR DELETE
TO anon
USING (true);

CREATE POLICY "history_select_anon"
ON public.history
FOR SELECT
TO anon
USING (true);

COMMIT;
```

---

## Edge Function ✨

```ts
// supabase/functions/mt4-receiver/index.ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  try {
    const rawData = await req.json();

    // ✅ รองรับทั้ง array และ single object
    const dataArray = Array.isArray(rawData) ? rawData : [rawData];

    if (dataArray.length === 0) {
      return new Response(
        JSON.stringify({
          error: "Empty data array",
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const results = [];
    const errors = [];

    // ✅ วนลูปประมวลผลทีละ account
    for (let i = 0; i < dataArray.length; i++) {
      const data = dataArray[i];

      // Validate required fields
      if (!data.acc_number || !data.date) {
        errors.push({
          index: i,
          acc_number: data.acc_number || "unknown",
          error: "Missing required fields: acc_number or date",
        });
        continue;
      }

      try {
        // 1. Upsert Account
        const { data: account, error: accError } = await supabase
          .from("accounts")
          .upsert(
            {
              acc_number: data.acc_number,
              balance: data.balance,
              equity: data.equity,
              updated_at: new Date().toISOString(),
            },
            { onConflict: "acc_number" }
          )
          .select("id")
          .single();

        if (accError) throw accError;
        const accountId = account.id;

        // 2. Upsert History
        const { error: histError } = await supabase.from("history").upsert(
          {
            account_id: accountId,
            date: data.date,
            current_total_trade: data.current?.total_trade || 0,
            current_profit: data.current?.profit || 0,
            current_lot: data.current?.lot || 0,
            current_order_buy_count: data.current?.order_buy_count || 0,
            current_order_sell_count: data.current?.order_sell_count || 0,
            history_total_trade: data.history?.total_trade || 0,
            history_profit: data.history?.profit || 0,
            history_lot: data.history?.lot || 0,
            history_order_buy_count: data.history?.order_buy_count || 0,
            history_order_sell_count: data.history?.order_sell_count || 0,
            history_win: data.history?.win || 0,
            history_loss: data.history?.loss || 0,
            updated_at: new Date().toISOString(),
          },
          { onConflict: "account_id,date" }
        );

        if (histError) throw histError;

        results.push({
          success: true,
          account_id: accountId,
          acc_number: data.acc_number,
          date: data.date,
        });
      } catch (error) {
        errors.push({
          index: i,
          acc_number: data.acc_number,
          error: error.message || "Unknown error",
        });
      }
    }

    // Update 'updated' table timestamp
    const { error: updatedError } = await supabase
      .from("updated")
      .update({
        updated_at: new Date().toISOString(),
      })
      .eq("title", "update");

    if (updatedError) throw updatedError;

    // ✅ Response สรุปผล
    const response = {
      total_received: dataArray.length,
      success_count: results.length,
      error_count: errors.length,
      results,
      ...(errors.length > 0 && { errors }),
    };

    return new Response(JSON.stringify(response), {
      status: errors.length === dataArray.length ? 500 : 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({
        error: "Failed to process request",
        details: error.message || "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
```
