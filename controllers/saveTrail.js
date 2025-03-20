import supabase from "../config/supabaseClient.js";


export const saveTrail = async (req, res) => {

  const { name, description, distance, duration,user_id, coordinates, district, difficulty_level, elevation_gain } = req.body;
  console.log('Request body:', req.body);
  try {
    // Save trail data
    const { data: trailData, error: trailError } = await supabase
      .from('trails')
      .insert({
        name,
        description,
        distance_meters: distance,
        duration_seconds: duration,

        user_id,
        district, // Add district
        difficulty_level, // Add difficulty level
        elevation_gain,

      })
      .select('id')
      .single();

    if (trailError) throw trailError;

    const trailId = trailData.id;

    // Save coordinates
    const coordinatesWithTrailId = coordinates.map(coord => ({
      trail_id: trailId,
      latitude: coord.latitude,
      longitude: coord.longitude,
    }));

    const { error: coordError } = await supabase
      .from('coordinates')
      .insert(coordinatesWithTrailId);

    if (coordError) throw coordError;

    res.status(200).json({ message: 'Trail and coordinates saved successfully', trailId });
  } catch (error) {
    console.error('Error saving trail:', error);
    res.status(500).json({ error: 'Failed to save trail and coordinates' });
  }
};