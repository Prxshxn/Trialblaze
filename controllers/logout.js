/**
 * Logout API endpoint
 * This function handles the logout process by clearing the session cookie and returning a success response.
 * 
 * @param{Object} req - The request object containing client request data.
 * @param{Object} res - The response object used to send data back to the client.
 * @returns {Object} - Returns a JSON response indicating the status of the logout operation.
 */
export async function Logout(req, res) {
    try {
        // Clear the session cookie named "SessionID"
        res.clearCookie("SessionID", {
            httpOnly: true,  // Prevents client-side scripts from accessing the cookie
            secure: true,   // Ensures the cookie is only sent over HTTPS
            sameSite: "None",    // Allows the cookie to be sent with cross-site requests
        });

        // Return a success response with a 200 status code
        return res.status(200).json({
            status: "success",
            message: "You have been logged out.",
        });
    } catch (err) {
        // Log the error to the console for debugging purposes
        console.error("Logout error:", err.message);

        // Return a 500 Internal Server Error response if an exception occurs
        return res.status(500).json({ 
            status: "error", 
            message: "Internal Server Error" });
    }
}
