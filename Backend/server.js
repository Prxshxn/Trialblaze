import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import mongoose from "mongoose";
import { PORT, URI } from "./config/index.js";
import createMainRoute from "./routes/index.js";

// === 1 - CREATE SERVER ===
const server = express();

// CONFIGURE HEADER INFORMATION
server.use(cors());
server.disable("x-powered-by");
server.use(cookieParser());
server.use(express.urlencoded({ extended: false }));
server.use(express.json());

// === 2 - CONNECT DATABASE ===
mongoose
  .connect(URI)
  .then(() => console.log("Connected to database"))
  .catch((err) => console.log(err));

// === 4 - CONFIGURE ROUTES ===
createMainRoute(server);

// === 5 - START UP SERVER ===
server.listen(PORT, () =>
  console.log(`Server running on http://localhost:${PORT}`)
);
