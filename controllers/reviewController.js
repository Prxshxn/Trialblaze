import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

// Add a new review
export const addReview = async (req, res) => {
    let { user_id, trail_id, rating, review_text } = req.body;

    console.log("Received Data:", req.body); // Debugging line

    if (!user_id || !trail_id || !rating || !review_text) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    // If IDs are integers, convert them to UUID format
    if (!user_id.includes('-')) user_id = uuidv4();
    if (!trail_id.includes('-')) trail_id = uuidv4();

    const { data, error } = await supabase
        .from('reviews')
        .insert([{ user_id, trail_id, rating, review_text }]);

    // Debugging: Log Supabase response and error
    console.log("Supabase response:", data);
    console.log("Supabase error:", error);

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.status(201).json({ message: 'Review added successfully', data });
};
// Get all reviews for a specific trail
export const getReviews = async (req, res) => {
    const { trail_id } = req.params;

    const { data, error } = await supabase
        .from('reviews')
        .select('*')
        .eq('trail_id', trail_id);

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.status(200).json(data);
};
