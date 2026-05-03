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

    sock.ev.on("creds.update", saveCreds);
}

start();
app.listen(3000, () => console.log("Baileys Gateway running on port 3000"));
