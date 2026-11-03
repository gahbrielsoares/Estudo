extends Control
## Quadro de suspeitos: o jogador arrasta as fotos até as pessoas.
## Uma contradição só é confirmada quando TODAS as evidências dela estão no suspeito certo,
## e o jogo não diz quais estão erradas. Isso recompensa o raciocínio em vez do chute.

signal fechado

const CartaoEvidencia := preload("res://scripts/cartao_evidencia.gd")
const ZonaEvidencias := preload("res://scripts/zona_evidencias.gd")
const INSTRUCAO := "Arraste as fotos até as pessoas. Quando todas as provas de uma contradição estiverem na pessoa certa, ela será confirmada."

@export_file("*.json") var caminho_dados := "res://data/quadro.json"

var dados: Dictionary = {}
var _zonas: Dictionary = {}
var _zona_soltas: PanelContainer
var _aviso: Label
var _contador: Label


func _ready() -> void:
	dados = _carregar_dados(caminho_dados)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var fundo := ColorRect.new()
	fundo.color = Color(0.29, 0.2, 0.13)  # cortiça
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)

	var margem := MarginContainer.new()
	margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for lado in ["left", "right", "top", "bottom"]:
		margem.add_theme_constant_override("margin_" + lado, 36)
	add_child(margem)

	var principal := VBoxContainer.new()
	principal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	principal.add_theme_constant_override("separation", 16)
	margem.add_child(principal)

	# Cabeçalho
	var cabecalho := HBoxContainer.new()
	cabecalho.mouse_filter = Control.MOUSE_FILTER_IGNORE
	principal.add_child(cabecalho)
	var titulo := Label.new()
	titulo.text = "QUADRO DE SUSPEITOS"
	titulo.add_theme_font_size_override("font_size", 38)
	titulo.add_theme_color_override("font_color", Color(0.95, 0.82, 0.55))
	cabecalho.add_child(titulo)
	var espaco := Control.new()
	espaco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	espaco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cabecalho.add_child(espaco)
	_contador = Label.new()
	_contador.add_theme_font_size_override("font_size", 24)
	cabecalho.add_child(_contador)
	var fechar := Button.new()
	fechar.text = "  Fechar  [Tab]  "
	fechar.focus_mode = Control.FOCUS_NONE
	fechar.add_theme_font_size_override("font_size", 22)
	fechar.pressed.connect(func(): fechado.emit())
	cabecalho.add_child(fechar)

	_aviso = Label.new()
	_aviso.text = INSTRUCAO
	_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_aviso.add_theme_font_size_override("font_size", 22)
	_aviso.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	principal.add_child(_aviso)

	# Colunas dos suspeitos
	var colunas := HBoxContainer.new()
	colunas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	colunas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	colunas.add_theme_constant_override("separation", 18)
	principal.add_child(colunas)
	for suspeito in dados.get("suspeitos", []):
		var zona := ZonaEvidencias.new()
		zona.configurar(self, suspeito)
		colunas.add_child(zona)
		_zonas[suspeito["id"]] = zona

	# Fotos ainda não presas em ninguém
	var rotulo_soltas := Label.new()
	rotulo_soltas.text = "FOTOS SOLTAS"
	rotulo_soltas.add_theme_font_size_override("font_size", 22)
	rotulo_soltas.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	principal.add_child(rotulo_soltas)
	_zona_soltas = ZonaEvidencias.new()
	_zona_soltas.configurar(self)
	_zona_soltas.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_zona_soltas.custom_minimum_size = Vector2(0, 190)
	principal.add_child(_zona_soltas)

	EstadoJogo.evidencia_adicionada.connect(func(_evidencia): _atualizar.call_deferred())
	visibility_changed.connect(func(): if visible: _aviso.text = INSTRUCAO)
	_atualizar.call_deferred()


func _carregar_dados(caminho: String) -> Dictionary:
	var resultado: Variant = JSON.parse_string(FileAccess.get_file_as_string(caminho))
	if typeof(resultado) != TYPE_DICTIONARY:
		push_error("Não foi possível ler o quadro: %s" % caminho)
		return {}
	return resultado


## Chamado quando uma foto é solta em uma zona. Um id vazio significa "fotos soltas".
func fixar(id_evidencia: String, id_suspeito: String) -> void:
	if _esta_travada(id_evidencia):
		return
	EstadoJogo.fixar_evidencia(id_evidencia, id_suspeito)
	_verificar_contradicoes()
	_atualizar.call_deferred()


## Contradições que existem nesta jogada (algumas só valem para um caminho).
func _contradicoes() -> Array:
	return dados.get("contradicoes", []).filter(func(c): return EstadoJogo.condicao(c.get("se", {})))


func _verificar_contradicoes() -> void:
	for contradicao in _contradicoes():
		var id: String = contradicao["id"]
		if id in EstadoJogo.contradicoes_confirmadas:
			continue
		var completa := true
		for id_evidencia in contradicao["evidencias"]:
			if EstadoJogo.quadro.get(id_evidencia, "") != contradicao["suspeito"]:
				completa = false
				break
		if completa:
			EstadoJogo.contradicoes_confirmadas.append(id)
			_anunciar(contradicao)


func _anunciar(contradicao: Dictionary) -> void:
	_aviso.text = "Contradição confirmada: %s. %s" % [contradicao["titulo"], contradicao["texto"]]
	_aviso.modulate = Color(0.6, 1.0, 0.7)
	create_tween().tween_property(_aviso, "modulate", Color.WHITE, 1.5)


func _esta_travada(id_evidencia: String) -> bool:
	for contradicao in _contradicoes():
		if contradicao["id"] in EstadoJogo.contradicoes_confirmadas and id_evidencia in contradicao["evidencias"]:
			return true
	return false


func _atualizar() -> void:
	for zona in _zonas.values():
		zona.limpar()
	_zona_soltas.limpar()
	for evidencia in EstadoJogo.evidencias:
		var id: String = evidencia.get("id", "")
		var destino: PanelContainer = _zonas.get(EstadoJogo.quadro.get(id, ""), _zona_soltas)
		destino.adicionar_cartao(CartaoEvidencia.new(evidencia, _esta_travada(id)))
	for id_suspeito in _zonas:
		var confirmadas := []
		for contradicao in _contradicoes():
			if contradicao["suspeito"] == id_suspeito and contradicao["id"] in EstadoJogo.contradicoes_confirmadas:
				confirmadas.append(contradicao)
		_zonas[id_suspeito].mostrar_contradicoes(confirmadas)
	_contador.text = "Contradições: %d de %d    " % [EstadoJogo.contradicoes_confirmadas.size(), _contradicoes().size()]
