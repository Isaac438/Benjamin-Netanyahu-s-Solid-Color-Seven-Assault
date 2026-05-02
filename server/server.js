const express = require("express");
const http = require("http");
const path = require("path");
const { WebSocketServer } = require("ws");
const crypto = require("crypto");

const app = express();
const port = process.env.PORT || 3000;
const publicPath = path.join(__dirname, "public");

app.use(express.static(publicPath));
app.get("/", (req, res) => {
  res.sendFile(path.join(publicPath, "index.html"));
});

const server = http.createServer(app);
const wss = new WebSocketServer({ server });
const clients = new Map();

function broadcast(data, excludeId) {
  const message = JSON.stringify(data);
  for (const [clientId, socket] of clients.entries()) {
    if (clientId === excludeId || socket.readyState !== socket.OPEN) continue;
    socket.send(message);
  }
}

wss.on("connection", (socket) => {
  const id = crypto.randomUUID ? crypto.randomUUID() : `${Math.random().toString(36).slice(2)}-${Date.now()}`;
  clients.set(id, socket);
  console.log(`Player connected: ${id}`);

  socket.send(JSON.stringify({ type: "welcome", id }));
  broadcast({ type: "player_joined", id }, id);

  socket.on("message", (rawData) => {
    let data;
    try {
      data = JSON.parse(rawData.toString());
    } catch (err) {
      console.warn("Received invalid JSON:", rawData.toString());
      return;
    }

    switch (data.type) {
      case "state_update":
        broadcast({ type: "state_update", id, state: data.state }, id);
        break;
      case "chat":
        broadcast({ type: "chat", id, message: data.message }, id);
        break;
      default:
        console.warn("Unknown message type:", data.type);
    }
  });

  socket.on("close", () => {
    clients.delete(id);
    console.log(`Player disconnected: ${id}`);
    broadcast({ type: "player_left", id });
  });

  socket.on("error", (err) => {
    console.error(`Socket error from ${id}:`, err);
  });
});

function startServer(listenPort) {
  server.listen(listenPort, () => {
    console.log(`Multiplayer server listening on http://localhost:${listenPort}`);
  });

  server.on("error", (err) => {
    if (err.code === "EADDRINUSE") {
      const nextPort = listenPort + 1;
      console.warn(`Port ${listenPort} is already in use. Trying port ${nextPort}...`);
      server.removeAllListeners("error");
      startServer(nextPort);
      return;
    }
    throw err;
  });
}

startServer(port);
