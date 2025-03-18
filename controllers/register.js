import bcrypt from 'bcrypt';
import supabase from '../config/supabaseClient.js';

/**
 * @route POST /api/v1/register/hiker
 * @desc Registers a hiker
 * @access Public
 */
export async function registerHiker(req, res) {
    const { username, email, password, hikingExperience, emergencyContact, address, gender, age } = req.body;

    // Validate required fields
    if (!username || !email || !password) {
        return res.status(400).json({ status: "failed", message: "Username, email, and password are required." });
    }

    try {
        // Trim input
        const trimmedEmail = email.trim().toLowerCase();
        const trimmedUsername = username.trim();

        // Check if user already exists
        const { data: existingUser } = await supabase
            .from('users')
            .select('id')
            .eq('email', trimmedEmail)
            .single();

        if (existingUser) {
            return res.status(422).json({
                status: "failed",
                message: "It seems you already have an account, please log in instead.",
            });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert user into Supabase
        const { data, error } = await supabase
            .from('users')
            .insert([
                {
                    username: trimmedUsername,
                    email: trimmedEmail,
                    password_hash: hashedPassword,
                    role: 'hiker',
                    hiking_experience: hikingExperience || 'beginner',
                    emergency_contact: emergencyContact || null,
                    address: address || null,
                    gender: gender || null,
                    age: age || null
                }
            ])
            .select('*');

        if (error) throw error;

        // Exclude password from response
        delete data[0].password_hash;

        return res.status(201).json({
            status: "success",
            data: data[0],
            message: "Thank you for registering with us. Your account has been successfully created.",
        });

    } catch (err) {
        console.error("Error in registration:", err.message);
        return res.status(500).json({ status: "error", message: err.message || "Internal Server Error" });
    }
}

/**
 * @route POST /api/v1/register/responder
 * @desc Registers a responder
 * @access Public
 */
export async function registerResponder(req, res) {
    const { username, email, password, responderType, location } = req.body;

    // Validate required fields
    if (!username || !email || !password || !responderType) {
        return res.status(400).json({ status: "failed", message: "Username, email, password, and responder type are required." });
    }

    try {
        const trimmedEmail = email.trim().toLowerCase();
        const trimmedUsername = username.trim();

        // Check if user already exists
        const { data: existingUser } = await supabase
            .from('users')
            .select('id')
            .eq('email', trimmedEmail)
            .single();

        if (existingUser) {
            return res.status(422).json({
                status: "failed",
                message: "It seems you already have an account, please log in instead.",
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const { data, error } = await supabase
            .from('users')
            .insert([
                {
                    username: trimmedUsername,
                    email: trimmedEmail,
                    password_hash: hashedPassword,
                    role: 'responder',
                    responder_type: responderType,
                    location: location || null
                }
            ])
            .select('*');

        if (error) throw error;

        delete data[0].password_hash;

        return res.status(201).json({
            status: "success",
            data: data[0],
            message: "Thank you for registering with us. Your account has been successfully created.",
        });

    } catch (err) {
        console.error("Error in registration:", err.message);
        return res.status(500).json({ status: "error", message: err.message || "Internal Server Error" });
    }
}
