import crypto from "crypto";

const secretKey = crypto.randomBytes(20).toString("hex");
console.log("Generated Secret Key:", secretKey);
