import { supabase } from '../config/supabaseClient.js';

// Function to fetch all trails
export const getAllTrails = async (req, res) => {
  const { data: trails } = await supabase
    .from('trails')
    .select('*');

  const formattedTrails = trails.map(trail => ({
    id: trail.id,
    name: trail.name,
    description: trail.description,
    difficulty: trail.difficulty,
    length: parseFloat(trail.length),
    estimatedTime: trail.estimated_time,
    elevationGain: trail.elevation_gain,
    imageUrl: trail.image_url,
    mapUrl: trail.map_url
  }));

  res.json(formattedTrails);
};

// Function to fetch a trail by ID
export const getTrailById = async (req, res) => {
  const { id } = req.params;

  const { data: trail } = await supabase
    .from('trails')
    .select('*')
    .eq('id', id)
    .single();

  const formattedTrail = {
    id: trail.id,
    name: trail.name,
    description: trail.description,
    difficulty: trail.difficulty,
    length: parseFloat(trail.length),
    estimatedTime: trail.estimated_time,
    elevationGain: trail.elevation_gain,
    imageUrl: trail.image_url,
    mapUrl: trail.map_url
  };

  res.json(formattedTrail);
};

// Export the functions
export default { getAllTrails, getTrailById };