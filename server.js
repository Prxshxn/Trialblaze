import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import { PORT } from "./config/index.js";
import createMainRoute from "./routes/index.js";
import supabase from "./config/supabaseClient.js"; // Import Supabase client

// === 1 - CREATE SERVER ===
const server = express();

// CONFIGURE HEADER INFORMATION
server.use(cors());
server.disable("x-powered-by");
server.use(cookieParser());
server.use(express.urlencoded({ extended: false }));
server.use(express.json());

// === 2 - CHECK DATABASE CONNECTION ===
async function checkDatabaseConnection() {
  const { data, error } = await supabase.from("users").select("id").limit(1);
  if (error) {
    console.error("Database connection failed:", error.message);
  } else {
    console.log("Connected to Supabase database");
  }
}

checkDatabaseConnection(); // Run check on startup

// === 3 - CONFIGURE ROUTES ===
createMainRoute(server);

// === 4 - START SERVER ===
server.listen(PORT, () =>
  console.log(`Server running on http://localhost:${PORT}`)


);

