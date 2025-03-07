const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/trail-tracker', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('MongoDB Connected'))
.catch(err => console.log('MongoDB Connection Error:', err));

// User Schema
const userSchema = new mongoose.Schema({
  name: String,
  location: String,
  profilePicture: String,
  coverPhoto: String,
  followers: { type: Number, default: 0 },
  following: { type: Number, default: 0 },
  stats: {
    miles: { type: Number, default: 0 },
    hours: { type: Number, default: 0 }
  }
});

const User = mongoose.model('User', userSchema);

// Routes
app.get('/api/user/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create a test user
app.post('/api/user', async (req, res) => {
  try {
    const user = new User({
      name: 'John Doe',
      location: 'Charleston, SC',
      followers: 8,
      following: 12,
      stats: {
        miles: 150,
        hours: 48
      }
    });
    await user.save();
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
}); 