import mongoose from "mongoose";
import bcrypt from "bcrypt";
import jwt from 'jsonwebtoken';
import { SECRET_ACCESS_TOKEN } from '../config/index.js';

const UserSchema = new mongoose.Schema({
  //Common Fields
  username: { type: String, required: true },
  password: { type: String, required: true},
  email: { type: String, required: true, unique: true },
  //role:{type:String,enum: ["hiker","responder"],required: true, unique: true},

  //Fields for Hikers
  hikingExperience: { type: String, enum: ["Beginner", "Intermediate", "Expert"], default: "Beginner" },
  emergencyContact: { type: String },
  address: { type: String },
  gender: { type: String },
  age: { type: String },
  
  //Fields for responders
  responderType: { type: String, enum: ["Search & Rescue", "Medical", "Firefighter"] },
  location : { type: String },


});

UserSchema.pre("save", function (next) {
  const user = this;

  if (!user.isModified("password")) return next();
  bcrypt.genSalt(10, (err, salt) => {
      if (err) return next(err);

      bcrypt.hash(user.password, salt, (err, hash) => {
          if (err) return next(err);

          user.password = hash;
          next();
      });
  });
});

UserSchema.methods.generateAccessJWT = function () {
  let payload = {
    id: this._id,
  };
  return jwt.sign(payload, SECRET_ACCESS_TOKEN, {
    expiresIn: '20m',
  });
};

const User = mongoose.model("Sample", UserSchema);

export default User;




