import axios from "axios";

Deno.serve(async (req) => {
  try {
    const params = {
      "latitude": 38.7167,
      "longitude": -9.1333,
      "hourly": ["temperature_2m", "precipitation_probability"],
      "timezone": "auto",
    };
    const url = "https://api.open-meteo.com/v1/forecast";
    const response = await axios.get(url, { params });

    // Helper function to form time ranges
    const range = (start: number, stop: number, step: number) =>
      Array.from({ length: (stop - start) / step }, (_, i) => start + i * step);

    // Process first location. Add a for-loop for multiple locations or weather models
    return new Response(JSON.stringify(response.data), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error('Error fetching weather data:', error);
    return new Response(
      JSON.stringify({ error: error.message, stack: error.stack }),
      {
        headers: { "Content-Type": "application/json" },
        status: 500,
      },
    );
  }
});
