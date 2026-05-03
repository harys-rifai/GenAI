const { default: makeWASocket, useMultiFileAuthState } = require("@whiskeysockets/baileys");
const express = require("express");
const axios = require("axios");

const app = express();
app.use(express.json());

async function start() {
    const { state, saveCreds } = await useMultiFileAuthState("auth_info");
    const sock = makeWASocket({ auth: state });

    sock.ev.on("messages.upsert", async ({ messages }) => {
        const msg = messages[0];
        if (!msg.message) return;

        const number = msg.key.remoteJid;
        const text = msg.message.conversation || msg.message.extendedTextMessage?.text;

        // Kirim ke Django webhook
        await axios.post("http://localhost:8000/webhook/", {
            number,
            text,
        });
    });

    // Endpoint untuk kirim pesan dari Django
    app.post("/send", async (req, res) => {
        const { number, text } = req.body;
        await sock.sendMessage(number, { text });
        res.json({ status: "sent" });
    });

    sock.ev.on("connection.update", (update) => {
        const { connection, lastDisconnect, qr } = update;
        if (qr) {
            console.log("📌 Scan this QR Code to connect to WhatsApp:");
            // Since we can't install qrcode-terminal, we log the QR string
            // User can also see it in the terminal if they run it interactively
            console.log(qr);
        }
        if (connection === "close") {
            const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401;
            console.log("🔄 Connection closed, reconnecting:", shouldReconnect);
            if (shouldReconnect) start();
        } else if (connection === "open") {
            console.log("✅ WhatsApp connection opened!");
        }
    });

    sock.ev.on("creds.update", saveCreds);
}


start();
app.listen(3000, () => console.log("Baileys Gateway running on port 3000"));
