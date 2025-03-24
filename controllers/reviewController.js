import supabase from '../config/supabaseClient.js';

// Add a new review
export const addReview = async (req, res) => {
    try {
        // Log the incoming request body for debugging
        console.log("Received Data:", req.body);

        // Destructure the required fields from the request body
        const { user_id, trail_id, rating, review_text } = req.body;

        // Validate that all required fields are present
        if (!user_id || !trail_id || !rating || !review_text) {
            return res.status(400).json({ 
                status: "error", 
                message: "All fields are required: user_id, trail_id, rating, review_text" 
            });
        }

        // Insert the review into the Supabase "reviews" table and return the inserted data
        const { data, error } = await supabase
            .from('reviews')
            .insert([{ user_id, trail_id, rating, review_text }])
            .select(); // Use .select() to return the inserted row

        // Log Supabase response and error for debugging
        console.log("Supabase response:", data);
        console.log("Supabase error:", error);

        // Handle Supabase errors
        if (error) {
            throw error;
        }

        // Return success response with the inserted data
        return res.status(201).json({
            status: "success",
            data: data,
            message: "Review added successfully."
        });
    } catch (err) {
        console.error("Error in addReview:", err.message);
        return res.status(500).json({ 
            status: "error", 
            message: err.message || "Internal Server Error" 
        });
    }
};

// Get all reviews for a specific trail
export const getReviews = async (req, res) => {
    try {
        // Extract trail_id from the request parameters
        const { trail_id } = req.params;

        // Log the requested trail_id for debugging
        console.log("Requested trail_id:", trail_id);

        // Validate that trail_id is provided
        if (!trail_id) {
            return res.status(400).json({ 
                status: "error", 
                message: "trail_id is required" 
            });
        }

        // Query the Supabase "reviews" table for reviews matching the trail_id
        const { data, error } = await supabase
            .from('reviews')
            .select('*')
            .eq('trail_id', trail_id);

        // Log Supabase response and error for debugging
        console.log("Supabase response:", data);
        console.log("Supabase error:", error);

        // Handle Supabase errors
        if (error) {
            throw error;
        }

        // If no reviews are found, return a 404 error
        if (data.length === 0) {
            return res.status(404).json({ 
                status: "error", 
                message: "No reviews found for this trail_id" 
            });
        }

        // Return the reviews data
        return res.status(200).json({
            status: "success",
            data: data,
            message: "Reviews fetched successfully."
        });
    } catch (err) {
        console.error("Error in getReviews:", err.message);
        return res.status(500).json({ 
            status: "error", 
            message: err.message || "Internal Server Error" 
        });
    }
};