extends Control
## Controla a sequência de cenas do episódio, com transição em fade.
## Cada cena é um JSON em data/cenas/ com "tipo" ("investigacao" ou "dialogo") e "proxima".

const CenaInvestigacao := preload("res://scripts/cena_investigacao.gd")
const CenaDialogo := preload("res://scripts/cena_dialogo.gd")
const CENA_INICIAL := "cena_01_corredor"
const PASTA_CENAS := "res://data/cenas/%s.json"

var _atual: Control
var _cortina: ColorRect
var _depuracao: Label
var _em_transicao := false


func _ready() -> void:
	_cortina = ColorRect.new()
	_cortina.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cortina.color = Color.BLACK
	_cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cortina)

	# Painel de depuração (F1), só em builds de desenvolvimento.
	_depuracao = Label.new()
	_depuracao.position = Vector2(20, 20)
	_depuracao.add_theme_font_size_override("font_size", 18)
	_depuracao.add_theme_color_override("font_color", Color(0.5, 1, 0.6))
	_depuracao.add_theme_color_override("font_outline_color", Color.BLACK)
	_depuracao.add_theme_constant_override("outline_size", 6)
	_depuracao.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_depuracao.visible = false
	add_child(_depuracao)

	ir_para(CENA_INICIAL)


func ir_para(id: String) -> void:
	if _em_transicao or id.is_empty():
		return
	_em_transicao = true
	_cortina.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade(1.0, 0.6)
	if _atual:
		_atual.queue_free()
		_atual = null

	if id == "fim_ato_1":
		_atual = _criar_tela_fim()
		EstadoJogo.pausado = true
	else:
		var dados := _ler(PASTA_CENAS % id)
		if dados.get("tipo", "investigacao") == "dialogo":
			var dialogo := CenaDialogo.new()
			dialogo.dados = dados
			_atual = dialogo
			EstadoJogo.pausado = true  # a bateria não gasta durante conversas
		else:
			var investigacao := CenaInvestigacao.new()
			investigacao.caminho_dados = PASTA_CENAS % id
			_atual = investigacao
			EstadoJogo.pausado = false
		_atual.concluida.connect(ir_para)

	add_child(_atual)
	move_child(_atual, 0)
	await _fade(0.0, 0.8)
	_cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_em_transicao = false


func _fade(alvo: float, duracao: float) -> void:
	var tween := create_tween()
	tween.tween_property(_cortina, "modulate:a", alvo, duracao)
	await tween.finished


func _ler(caminho: String) -> Dictionary:
	var resultado: Variant = JSON.parse_string(FileAccess.get_file_as_string(caminho))
	if typeof(resultado) != TYPE_DICTIONARY:
		push_error("Não foi possível ler a cena: %s" % caminho)
		return {}
	return resultado


func _criar_tela_fim() -> Control:
	var tela := ColorRect.new()
	tela.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tela.color = Color.BLACK
	var centro := VBoxContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	centro.grow_horizontal = Control.GROW_DIRECTION_BOTH
	centro.grow_vertical = Control.GROW_DIRECTION_BOTH
	centro.alignment = BoxContainer.ALIGNMENT_CENTER
	centro.add_theme_constant_override("separation", 24)
	tela.add_child(centro)
	for item in [["FIM DO ATO 1", 64, Color(0.95, 0.82, 0.55)], ["Continua em breve.", 30, Color(1, 1, 1, 0.6)]]:
		var rotulo := Label.new()
		rotulo.text = item[0]
		rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rotulo.add_theme_font_size_override("font_size", item[1])
		rotulo.add_theme_color_override("font_color", item[2])
		centro.add_child(rotulo)
	var botao := Button.new()
	botao.text = "   Jogar de novo   "
	botao.focus_mode = Control.FOCUS_NONE
	botao.add_theme_font_size_override("font_size", 26)
	botao.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	botao.pressed.connect(func():
		EstadoJogo.reiniciar()
		ir_para(CENA_INICIAL))
	centro.add_child(botao)
	return tela


func _unhandled_input(evento: InputEvent) -> void:
	if OS.is_debug_build() and evento is InputEventKey and evento.pressed and evento.keycode == KEY_F1:
		_depuracao.visible = not _depuracao.visible


func _process(_delta: float) -> void:
	if _depuracao.visible:
		_depuracao.text = "DEPURAÇÃO (F1)\ncaminho: %s\nmarcadores: %s\nbateria: %d%%" % [
			EstadoJogo.caminho(), EstadoJogo.marcadores, int(EstadoJogo.bateria)]
