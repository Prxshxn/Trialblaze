import User from "../models/user.js";

/**
 * @route POST v1/auth/register/hiker
 * @desc Registers a user
 * @access Public
 */
export async function registerHiker(req, res) {
    // get required variables from request body
    // using es6 object destructing
    const { username, email, password, hikingExperience, emergencyContact, address, gender, age } = req.body;
    try {
        // create an instance of a user
        const newUser = new User({
            username,
            email,
            password,
            role: 'hiker', // Set role for hiker
            hikingExperience,
            emergencyContact,
            address,
            gender,
            age
        });
        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser)
            return res.status(422).json({
                status: "failed",
                data: [],
                message: "It seems you already have an account, please log in instead.",
            });
        const savedUser = await newUser.save(); // save new user into the database
        const { password: pwd, ...user_data } = savedUser._doc;
        res.status(201).json({
            status: "success",
            data: [user_data],
            message:
                "Thank you for registering with us. Your account has been successfully created.",
        });
    } catch (err) {
        console.log("Error in registration:", err); 
        res.status(500).json({
            status: "error",
            code: 500,
            data: [],
            message: err.message || "Internal Server Error",
        });
    }
}

/**
 * @route POST v1/auth/register/responder
 * @desc Registers a user
 * @access Public
 */
export async function registerResponder(req, res) {
    // get required variables from request body
    // using es6 object destructing
    const { username, email, password, responderType, location } = req.body;
    try {
        // create an instance of a user
        const newUser = new User({
            username,
            email,
            password,
            role: 'responder', // Set role for responder
            responderType,
            location
        });
        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser)
            return res.status(422).json({
                status: "failed",
                data: [],
                message: "It seems you already have an account, please log in instead.",
            });
        const savedUser = await newUser.save(); // save new user into the database
        const { password: pwd, ...user_data } = savedUser._doc;
        res.status(201).json({
            status: "success",
            data: [user_data],
            message:
                "Thank you for registering with us. Your account has been successfully created.",
        });
    } catch (err) {
        console.log("Error in registration:", err); 
        res.status(500).json({
            status: "error",
            code: 500,
            data: [],
            message: err.message || "Internal Server Error",
        });
    }
}