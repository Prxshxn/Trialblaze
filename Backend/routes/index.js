import express from 'express';
//import User from '../models/user.js';
//import registerValidationRules from '../validation/registerValidationSchemas.js';
import Validate from '../middleware/validate.js';
import { registerHiker, registerResponder } from '../controllers/register.js';
import { Login } from '../controllers/login.js';
import { check } from 'express-validator';
import {verifyToken} from "../middleware/verify.js";
import registerHikerValidation from '../validation/registerHikerValidation.js';
import registerResponderValidation from '../validation/registerResponderValidation.js';

const createMainRoute = (server) => {
  const router = express.Router();

  // Home route
  router.get('/', (req, res) => {
    try {
      res.status(200).json({
        message: 'Welcome to Trailblaze API v1!',
        status: 'success',
      });
    } catch (err) {
      res.status(500).json({
        status: 'error',
        message: 'Internal Server Error',
      });
    }
  });
  

  // Route to register users
  //router.post("/register",registerValidationRules, Validate, Register);

  //Route to register Hikers
  router.post("/register/hiker",registerHikerValidation, Validate, registerHiker);

  //Route to register Responders
  router.post("/register/responder",registerResponderValidation,Validate,registerResponder);

  // Login route == POST request
  router.post(
    "/login",
    check("email")
        .isEmail()
        .withMessage("Enter a valid email address")
        .normalizeEmail(),
    check("password").not().isEmpty(),
    Validate,
    Login
  );

  // Verification route
  router.get("/verified",
    verifyToken,
    (req, res) => {
      res.status(200).json({
        message: "Welcome to Trailblaze!"});
    });



  // Attach the main router to the server instance
  server.use('/api/v1', router);
};

export default createMainRoute;
