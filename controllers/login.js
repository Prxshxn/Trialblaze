import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import supabase from "../config/supabaseClient.js";
import { SECRET_ACCESS_TOKEN } from "../config/index.js";

/**
 * @route POST v1/auth/login
 * @desc Logs in a user
 * @access Public
 */
export async function Login(req, res) {
    const { email, password } = req.body;

    try {
        // Fetch user with only required fields
        const { data: user, error } = await supabase
            .from('users')
            .select('id, username, role, password_hash')
            .eq('email', email)
            .single();

        if (error) {
            return res.status(500).json({ status: "error", message: "Database query failed." });
        }

        if (!user) {
            return res.status(401).json({ status: "failed", message: "Invalid email or password." });
        }

        // Compare password
        const isPasswordValid = await bcrypt.compare(password, user.password_hash);
        if (!isPasswordValid) {
            return res.status(401).json({ status: "failed", message: "Invalid email or password." });
        }

        // Generate JWT
        const token = jwt.sign({ id: user.id, role: user.role }, SECRET_ACCESS_TOKEN, { expiresIn: '20m' });

        // Securely set HTTP-only cookie
        res.cookie("SessionID", token, { 
            maxAge: 20 * 60 * 1000, 
            httpOnly: true, 
            secure: true, 
            sameSite: "None" 
        });

        return res.status(200).json({
            status: "success",
            message: "You have successfully logged in.",
            data: { id: user.id,role: user.role, username: user.username }
        });

    } catch (err) {
        console.error("Error: ", err.message);
        return res.status(500).json({ status: "error", message: "Internal Server Error" });
    }
}
