import jwt from "jsonwebtoken";
import { SECRET_ACCESS_TOKEN } from "../config/index.js";

export const verifyToken = async (req, res, next) => {
    try {
        const token = req.cookies.SessionID;
        if (!token) return res.status(401).json({ status: "error", message: "Unauthorized! No token provided." });

        const decoded = jwt.verify(token, SECRET_ACCESS_TOKEN);
        req.user = decoded;
        next();

    } catch (error) {
        res.status(401).json({ status: "error", message: "Invalid token or session expired" });
    }
};
