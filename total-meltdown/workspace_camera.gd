extends Camera2D

var zoom_normal: Vector2 = Vector2(1.0, 1.0)
var tween: Tween
var posicao_original

func _ready() -> void:
	posicao_original = global_position

func zoom_para_ponto(ponto_global: Vector2, zoom_novo: float, duracao: float):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "zoom", Vector2(zoom_novo, zoom_novo), duracao).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "global_position", ponto_global, duracao).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	print("Zoom in")
	await get_tree().create_timer(2.5).timeout
	voltar_zoom_normal()

func voltar_zoom_normal(duracao: float = 0.3):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "zoom", zoom_normal, duracao)
	tween.tween_property(self, "global_position", posicao_original, duracao)
