import supabase from '../config/supabaseClient.js';

export async function getTrailDetails(req, res) {
    console.log ("working")
    try {
        // Fetch trail details from the trails table
        const { data, error } = await supabase
            .from('trails')
            .select('name, description,id');

        if (error) throw error;

        // Add a static image URL to each trail
        const trailsWithImages = data.map(trail => ({
            ...trail,
            imageUrl: 'https://rockyruggiero.com/wp-content/uploads/2017/09/Padua.jpg' // static image URL
        }));

        return res.status(200).json({
            status: "success",
            data: trailsWithImages,
            message: "Trail details fetched successfully."
        });

    } catch (err) {
        console.error("Error fetching trail details:", err.message);
        return res.status(500).json({ status: "error", message: err.message || "Internal Server Error" });
    }
}
