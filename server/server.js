const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/trail-app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Trail Schema
const trailSchema = new mongoose.Schema({
  name: String,
  difficulty: String,
  length: Number,
  estimatedTime: String,
  elevationGain: Number,
  imageUrl: String,
  reviews: [{
    userId: String,
    userName: String,
    userImage: String,
    date: { type: Date, default: Date.now },
    rating: Number,
    comment: String,
    likes: { type: Number, default: 0 }
  }]
});

const Trail = mongoose.model('Trail', trailSchema);

// Routes
// Get all trails
app.get('/api/trails', async (req, res) => {
  try {
    const trails = await Trail.find();
    res.json(trails);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get single trail
app.get('/api/trails/:id', async (req, res) => {
  try {
    const trail = await Trail.findById(req.params.id);
    if (!trail) {
      return res.status(404).json({ message: 'Trail not found' });
    }
    res.json(trail);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.post('/api/trails/:id/reviews', async (req, res) => {
  try {
    const trail = await Trail.findById(req.params.id);
    if (!trail) {
      return res.status(404).json({ message: 'Trail not found' });
    }

    const newReview = {
      userId: req.body.userId,
      userName: req.body.userName,
      userImage: req.body.userImage,
      rating: req.body.rating,
      comment: req.body.comment,
    };

    trail.reviews.push(newReview);
    await trail.save();

    res.status(201).json(newReview);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Like a review
app.post('/api/trails/:trailId/reviews/:reviewId/like', async (req, res) => {
  try {
    const trail = await Trail.findOneAndUpdate(
      { 
        '_id': req.params.trailId,
        'reviews._id': req.params.reviewId
      },
      { $inc: { 'reviews.$.likes': 1 } },
      { new: true }
    );

    if (!trail) {
      return res.status(404).json({ message: 'Trail or review not found' });
    }

    res.json(trail);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Add sample trail data if none exists
app.post('/api/seed', async (req, res) => {
  try {
    const count = await Trail.countDocuments();
    if (count === 0) {
      const sampleTrails = [
        {
          name: "Adams Peak",
          difficulty: "Hard",
          length: 4.3,
          estimatedTime: "2 hours 45 minutes",
          elevationGain: 1279,
          imageUrl: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b",
          reviews: [
            {
              userId: "user1",
              userName: "Sophia",
              userImage: "https://randomuser.me/api/portraits/women/1.jpg",
              date: new Date("2022-01-15"),
              rating: 5,
              comment: "Great hike, beautiful views of the bay area.",
              likes: 12
            }
          ]
        },
        {
          name: "Crystal Lake Trail",
          difficulty: "Moderate",
          length: 3.2,
          estimatedTime: "1 hour 30 minutes",
          elevationGain: 850,
          imageUrl: "https://images.unsplash.com/photo-1501555088652-021faa106b9b",
          reviews: []
        }
      ];

      await Trail.insertMany(sampleTrails);
      res.status(201).json({ message: 'Sample data added successfully' });
    } else {
      res.json({ message: 'Data already exists' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
}); 