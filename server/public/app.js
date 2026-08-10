const logEl = document.getElementById("log");
const connectBtn = document.getElementById("connectBtn");
const disconnectBtn = document.getElementById("disconnectBtn");
const sendBtn = document.getElementById("sendBtn");
const chatInput = document.getElementById("chatInput");
const stateBtn = document.getElementById("stateBtn");
let socket = null;

function log(message) {
  logEl.textContent += `${message}\n`;
  logEl.scrollTop = logEl.scrollHeight;
}

function getWebSocketUrl() {
  return `ws://${window.location.hostname}:${window.location.port}`;
}

function updateButtons(connected) {
  connectBtn.disabled = connected;
  disconnectBtn.disabled = !connected;
  sendBtn.disabled = !connected;
  chatInput.disabled = !connected;
  stateBtn.disabled = !connected;
}

connectBtn.addEventListener("click", () => {
  const url = getWebSocketUrl();
  log(`Connecting to ${url}...`);
  socket = new WebSocket(url);

  socket.addEventListener("open", () => {
    log("Connected to server.");
    updateButtons(true);
  });

  socket.addEventListener("message", (event) => {
    try {
      const data = JSON.parse(event.data);
      log(`Received: ${JSON.stringify(data)}`);
    } catch (err) {
      log(`Received raw: ${event.data}`);
    }
  });

  socket.addEventListener("close", () => {
    log("Disconnected from server.");
    updateButtons(false);
    socket = null;
  });

  socket.addEventListener("error", (event) => {
    log("WebSocket error occurred.");
    console.error(event);
  });
});

disconnectBtn.addEventListener("click", () => {
  if (socket) {
    socket.close();
  }
});

sendBtn.addEventListener("click", () => {
  if (!socket || socket.readyState !== WebSocket.OPEN) return;
  const message = chatInput.value.trim();
  if (!message) return;
  socket.send(JSON.stringify({ type: "chat", message }));
  log(`Sent chat: ${message}`);
  chatInput.value = "";
});

stateBtn.addEventListener("click", () => {
  if (!socket || socket.readyState !== WebSocket.OPEN) return;
  socket.send(JSON.stringify({ type: "state_update", state: { x: Math.random() * 100, y: Math.random() * 100 } }));
  log("Sent state update.");
});

updateButtons(false);
