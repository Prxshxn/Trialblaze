import * as dotenv from "dotenv";
dotenv.config();

const { PORT, SECRET_ACCESS_TOKEN, SUPABASE_URL, SUPABASE_ANON_KEY } = process.env;

export { PORT, SECRET_ACCESS_TOKEN, SUPABASE_URL, SUPABASE_ANON_KEY };
