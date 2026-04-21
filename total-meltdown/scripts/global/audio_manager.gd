extends Node

@onready var SFXPlayer = $SFXPlayer
@onready var BGMPlayer = $BGMPlayer

func play_sfx(target_sfx: AudioStream):
	SFXPlayer.stream = target_sfx
	SFXPlayer.play()

func play_bgm(target_bgm: AudioStream):
	BGMPlayer.stream = target_bgm
	BGMPlayer.play()
