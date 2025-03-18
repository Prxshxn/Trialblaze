export async function Logout(req, res) {
    try {
        res.clearCookie("SessionID", {
            httpOnly: true,
            secure: true,
            sameSite: "None",
        });

        return res.status(200).json({
            status: "success",
            message: "You have been logged out.",
        });
    } catch (err) {
        console.error("Logout error:", err.message);
        return res.status(500).json({ status: "error", message: "Internal Server Error" });
    }
}
