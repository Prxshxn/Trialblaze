import express from 'express';
import Validate from '../middleware/validate.js';
import { registerHiker, registerResponder } from '../controllers/register.js';
import { Login } from '../controllers/login.js';
import { check } from 'express-validator';
import { verifyToken } from "../middleware/verify.js";
import { Logout } from '../controllers/logout.js';

const router = express.Router();

router.get('/', (req, res) => {
    res.status(200).json({ message: 'Welcome to Trailblaze API v1!', status: 'success' });
});

router.post("/register/hiker", Validate, registerHiker);
router.post("/register/responder", Validate, registerResponder);
router.post("/login", check("email").isEmail().normalizeEmail(), check("password").not().isEmpty(), Validate, Login);
router.get("/verified", verifyToken, (req, res) => res.status(200).json({ message: "Welcome to Trailblaze!" }));
router.post("/logout", Logout);

export default (server) => server.use('/api/v1', router);
