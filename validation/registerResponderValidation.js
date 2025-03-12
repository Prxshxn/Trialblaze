import { check } from "express-validator";
import User from '../models/user.js';

const registerResponderValidation = [
    check("email")
        .isEmail()
        .withMessage("Please provide a valid email address")
        .normalizeEmail(),
    
    check("password")
        .notEmpty()
        .withMessage("Password Required")
        .isLength({ min: 6 })
        .withMessage("Password must be at least 6 characters long"),
      
    check("username")
        .trim()
        .escape()
        .notEmpty()
        .withMessage("Username is required")
        .custom(async(value)=>{
            const existingUserName = await User.findOne({username: value});
            if (existingUserName){
                throw new Error ("Username already taken.");
            }
            return true;
        }),

    check("responderType")
        .notEmpty()
        .isIn(["Search & Rescue", "Medical", "FireFighter"])
        .withMessage("Invalid Responder Type"),

    check("location")
        .notEmpty()
        .withMessage("Location is required"),    

    
        
];

export default registerResponderValidation;
