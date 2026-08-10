from flask import Flask, request, jsonify

app = Flask(__name__)

players = []
maps = [1, 2, 3, 4]
current_map = 1

@app.post("/join")
def join():
	data = request.json
	print("debug")
	player = {
		"id": len(players) + 1,
		"name": data["name"],
		"position": data["position"]
	}

	players.append(player)

	return jsonify(player)

@app.post("/leave")
def leave():
	data = request.json

	for player in players:
		if player["id"] == data["id"]:
			players.remove(player)
			return jsonify({"success": True})

	return jsonify({"success": False})

@app.post("/exchange_info")
def exchange_info():
	global current_map

	data = request.json
	current_map = data["map"]

	return jsonify({
		"current_map": current_map,
		"players": players
	})

app.run(host="0.0.0.0", port=8000)