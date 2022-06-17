extends Node2D

export var player : PackedScene 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ReadyPlayers = {}
var AlivePlayers = {}
var Players = {}
signal GameOver()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func StartGame(players : Dictionary):
	#rpc("setupGame", players)
	setupGame(players)

func setupGame(players :Dictionary):
	Players = players
	AlivePlayers = players
	for id in players:
		var currentPlayer = player.instance()
		currentPlayer.name = str(id)
		$PlayersSpawnUnder.add_child(currentPlayer)
		currentPlayer.set_network_master(players[id].peer_id)
		currentPlayer.position = get_node("SpawnPoints/" + str(players[id].peer_id)).position
		currentPlayer.connect("PlayerHasDied", self, "onPlayerDeath", [id])
	var myID = OnlineMatch.get_my_session_id()
	var player = $PlayersSpawnUnder.get_node(str(myID))
	player.playerControlled = true
	
	rpc_id(1, "finishedSetup", myID)
	#get_tree().get_nodes_in_group("GameWorld")[0].HideMatchMakeInterface()
	
mastersync func finishedSetup(id):
	ReadyPlayers[id] = Players[id]
	if ReadyPlayers.size() == Players.size():
		pass
		#get_tree().get_nodes_in_group("GameWorld")[0].startGame()
		
func onPlayerDeath(id):
	AlivePlayers.erase(id)
	if AlivePlayers.size() <= 1:
		emit_signal("GameOver", AlivePlayers)
