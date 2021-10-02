extends Area

export (Resource) var music



func _on_New_Environment_body_entered(body):
	SignalBus.emit_signal("music_transition",music)
