import { check } from "express-validator";
import User from '../models/user.js';

const registerHikerValidation = [
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

    check("hikingExperience")
        .notEmpty()
        .isIn(["Beginner", "Intermediate", "Expert"])
        .withMessage("Invalid hiking experience"),

    check("emergencyContact")
        .notEmpty()
        .withMessage("Emergency contact is required"),

    check("address")
        .notEmpty()
        .withMessage("Address is required"),

    check("gender")
        .notEmpty()
        .withMessage("Gender is required"),

    check("age")
        .notEmpty()
        .withMessage("Age is required")

        
];

export default registerHikerValidation;
