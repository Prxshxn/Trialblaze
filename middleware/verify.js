import jwt from "jsonwebtoken";
import { SECRET_ACCESS_TOKEN } from "../config/index.js";

export const verifyToken = async (req, res, next) => {
    try {
        const token = req.cookies.SessionID;

        if (!token) {
            return res.status(401).json({ status: "error", message: "Unauthorized! No token provided." });
        }

        // Verify the token
        const decoded = jwt.verify(token, SECRET_ACCESS_TOKEN);
        req.user = decoded;

        // Send user role back to the client
        res.status(200).json({ 
            status: "success", 
            user: {
                role: decoded.role, // Include the user role in the response
            },
        });
    } catch (error) {
        res.status(401).json({ status: "error", message: "Invalid token or session expired" });
    }
};

