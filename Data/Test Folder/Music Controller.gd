extends Node


onready var time = get_node("Timer")
onready var tween = get_node("Tween")
var transition_time : float = 3.0
export (Resource) var music_1
export (Resource) var music_2
onready var music_player_1 = get_node("Music-Player-1")
onready var music_player_2 = get_node("Music-Player-2")
onready var music_playlist : Array = [music_1,music_2]

	
func _ready():
	SignalBus.playlist = music_playlist
	SignalBus.connect("music_transition",self,"transition")
	#SignalBus.emit_signal("music_transition",SignalBus.playlist[0]) # Test
	

func transition(next_playlist):
	if music_player_1.stream == next_playlist:
		return
	else:
		tween.interpolate_property(music_player_1,"volume_db",0,-50,transition_time,Tween.EASE_IN)
		tween.start()
		yield(get_tree().create_timer(transition_time), "timeout") # wait for the tween to finish
		if music_player_1.volume_db <= -45:
			music_player_1.stop()
			music_player_1.stream = next_playlist
		yield(get_tree().create_timer(0.1),"timeout")
		tween.interpolate_property(music_player_1,"volume_db",-50,0,transition_time/2,Tween.EASE_IN)
		tween.start()
		music_player_1.play()
		print("its is done")
		
