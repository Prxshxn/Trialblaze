import * as dotenv from "dotenv";
dotenv.config();


const { URI, PORT, SECRET_ACCESS_TOKEN } = process.env;

export { URI, PORT, SECRET_ACCESS_TOKEN };
               