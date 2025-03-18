import supabase from '../config/supabaseClient.js';

export const getAllTrails = async (req, res) => {
  try {
    // Fetch all trails
    const { data: trails, error: trailsError } = await supabase
      .from('trails')
      .select('*');

    if (trailsError) {
      console.error('Error fetching trails:', trailsError);
      return res.status(500).json({ error: 'Failed to fetch trails' });
    }

    // Format trails to match Flutter app's data model
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
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getTrailById = async (req, res) => {
  try {
    const { id } = req.params;

    // Fetch the trail
    const { data: trail, error: trailError } = await supabase
      .from('trails')
      .select('*')
      .eq('id', id)
      .single();

    if (trailError) {
      console.error('Error fetching trail:', trailError);
      return res.status(500).json({ error: 'Failed to fetch trail' });
    }

    if (!trail) {
      return res.status(404).json({ error: 'Trail not found' });
    }

    // Format the response to match Flutter app's data model
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
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};