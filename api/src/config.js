import dotenv from "dotenv";

dotenv.config();

export const config = {
  PORT: Number(process.env.PORT) || 3000,
  DB_PATH: process.env.DB_PATH || "/app/db/data.sqlite",
  SUPABASE_URL: process.env.SUPABASE_URL || "",
  SUPABASE_TOKEN: process.env.SUPABASE_TOKEN || "",
  BATCH_INTERVAL: 60000, // 60 seconds
};
