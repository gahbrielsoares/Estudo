extends Control
## Cena de diálogo com escolhas. Os diálogos vêm do JSON da cena, organizados em "nós":
##   fala + texto + proximo      → uma fala comum
##   escolhas (+ tempo, padrao)  → o jogador decide; cada escolha pode "definir" marcadores
##   ramos (se/proximo) + senao  → desvio silencioso conforme escolhas anteriores
##   efeito: "flash" | "apagar"  → efeito visual ao mostrar a fala
##   fim: true                   → encerra a cena e segue para "proxima"

signal concluida(proxima: String)

const VELOCIDADE_TEXTO := 0.022  # segundos por letra
const COR_DESTAQUE := Color(0.95, 0.82, 0.55)

var dados: Dictionary = {}

var _personagens: Dictionary = {}
var _retratos: Dictionary = {}
var _no_atual: Dictionary = {}
var _digitando := false
var _aguardando_escolha := false
var _terminou := false
var _tween_texto: Tween
var _tempo_total := 0.0
var _tempo_restante := 0.0

var _fundo: TextureRect
var _escurecer: ColorRect
var _flash: ColorRect
var _nome: Label
var _texto: Label
var _dica: Label
var _opcoes: VBoxContainer
var _barra_tempo: ProgressBar


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_carregar_personagens()
	_montar()
	_ir_para_no(dados.get("inicio", "inicio"))


func _carregar_personagens() -> void:
	var lista: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/quadro.json"))
	if lista is Dictionary:
		for personagem in lista.get("suspeitos", []):
			_personagens[personagem["id"]] = personagem


# --- Montagem ----------------------------------------------------------------

func _montar() -> void:
	_fundo = TextureRect.new()
	_fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fundo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_fundo.stretch_mode = TextureRect.STRETCH_SCALE
	_fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if dados.has("imagem"):
		_fundo.texture = load(dados["imagem"])
	add_child(_fundo)

	_escurecer = ColorRect.new()
	_escurecer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_escurecer.color = Color(0, 0, 0.02)
	_escurecer.modulate.a = 0.0
	_escurecer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_escurecer)

	# Retratos de quem está na cena (topo)
	var linha_retratos := HBoxContainer.new()
	linha_retratos.alignment = BoxContainer.ALIGNMENT_CENTER
	linha_retratos.add_theme_constant_override("separation", 40)
	linha_retratos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	linha_retratos.anchor_right = 1.0
	linha_retratos.offset_top = 40
	linha_retratos.offset_bottom = 200
	add_child(linha_retratos)
	for id in dados.get("personagens", []):
		var retrato := _criar_retrato(_personagens.get(id, {"nome": id}))
		linha_retratos.add_child(retrato)
		_retratos[id] = retrato

	# Caixa de diálogo (baixo; cresce para cima quando há escolhas)
	var caixa := PanelContainer.new()
	caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caixa.anchor_top = 1.0
	caixa.anchor_bottom = 1.0
	caixa.anchor_right = 1.0
	caixa.offset_left = 180
	caixa.offset_right = -180
	caixa.offset_top = -40
	caixa.offset_bottom = -40
	caixa.grow_vertical = Control.GROW_DIRECTION_BEGIN
	caixa.custom_minimum_size = Vector2(0, 230)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.04, 0.04, 0.06, 0.92)
	estilo.set_corner_radius_all(16)
	estilo.set_content_margin_all(28)
	estilo.border_color = Color(1, 1, 1, 0.08)
	estilo.set_border_width_all(1)
	caixa.add_theme_stylebox_override("panel", estilo)
	add_child(caixa)

	var coluna := VBoxContainer.new()
	coluna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_theme_constant_override("separation", 12)
	caixa.add_child(coluna)
	_nome = _rotulo(30, COR_DESTAQUE)
	coluna.add_child(_nome)
	_texto = _rotulo(30, Color(0.93, 0.93, 0.93))
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coluna.add_child(_texto)
	_barra_tempo = ProgressBar.new()
	_barra_tempo.show_percentage = false
	_barra_tempo.custom_minimum_size = Vector2(0, 8)
	_barra_tempo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_barra_tempo.visible = false
	coluna.add_child(_barra_tempo)
	_opcoes = VBoxContainer.new()
	_opcoes.add_theme_constant_override("separation", 10)
	_opcoes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_child(_opcoes)
	_dica = _rotulo(20, Color(1, 1, 1, 0.4))
	_dica.text = "clique ou Espaço para continuar"
	_dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	coluna.add_child(_dica)

	_flash = ColorRect.new()
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color.WHITE
	_flash.modulate.a = 0.0
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)


func _criar_retrato(personagem: Dictionary) -> Control:
	var coluna := VBoxContainer.new()
	coluna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var circulo := PanelContainer.new()
	circulo.custom_minimum_size = Vector2(100, 100)
	circulo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	circulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color.from_string(personagem.get("cor", "#888888"), Color.GRAY)
	estilo.set_corner_radius_all(50)
	estilo.shadow_color = Color(0, 0, 0, 0.5)
	estilo.shadow_size = 8
	circulo.add_theme_stylebox_override("panel", estilo)
	var inicial := _rotulo(46, Color.WHITE)
	inicial.text = str(personagem.get("nome", "?")).left(1)
	inicial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inicial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	circulo.add_child(inicial)
	coluna.add_child(circulo)
	var nome := _rotulo(22, Color.WHITE)
	nome.text = personagem.get("nome", "")
	nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(nome)
	return coluna


func _rotulo(tamanho: int, cor: Color) -> Label:
	var rotulo := Label.new()
	rotulo.add_theme_font_size_override("font_size", tamanho)
	rotulo.add_theme_color_override("font_color", cor)
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rotulo


# --- Fluxo do diálogo --------------------------------------------------------

func _ir_para_no(id: String) -> void:
	var nos: Dictionary = dados.get("nos", {})
	if not nos.has(id):
		push_error("Nó de diálogo inexistente: '%s'" % id)
		_concluir()
		return
	var no: Dictionary = nos[id]
	_definir(no.get("definir", {}))
	if no.has("ramos"):
		for ramo in no["ramos"]:
			if _condicao(ramo.get("se", {})):
				_ir_para_no(ramo["proximo"])
				return
		_ir_para_no(no.get("senao", ""))
		return
	if no.get("fim", false):
		_concluir()
		return
	_no_atual = no
	_aplicar_efeito(no.get("efeito", ""))
	_mostrar_fala(no)


func _definir(valores: Dictionary) -> void:
	for chave in valores:
		EstadoJogo.marcadores[chave] = valores[chave]


func _condicao(se: Dictionary) -> bool:
	for chave in se:
		if str(EstadoJogo.marcadores.get(chave, "")) != str(se[chave]):
			return false
	return true


func _mostrar_fala(no: Dictionary) -> void:
	var quem: String = no.get("fala", "narrador")
	for id in _retratos:
		_retratos[id].modulate = Color.WHITE if id == quem else Color(1, 1, 1, 0.35)
	match quem:
		"narrador":
			_nome.visible = false
			_texto.add_theme_color_override("font_color", Color(0.75, 0.78, 0.85))
		"voce":
			_nome.visible = true
			_nome.text = "Você"
			_texto.add_theme_color_override("font_color", Color(0.93, 0.93, 0.93))
		_:
			_nome.visible = true
			_nome.text = _personagens.get(quem, {}).get("nome", quem)
			_texto.add_theme_color_override("font_color", Color(0.93, 0.93, 0.93))
	_limpar_opcoes()
	_dica.visible = false
	_texto.text = no.get("texto", "")
	_texto.visible_ratio = 0.0
	_digitando = true
	if _tween_texto:
		_tween_texto.kill()
	_tween_texto = create_tween()
	_tween_texto.tween_property(_texto, "visible_ratio", 1.0, maxf(0.2, _texto.text.length() * VELOCIDADE_TEXTO))
	_tween_texto.finished.connect(_ao_terminar_digitacao)


func _ao_terminar_digitacao() -> void:
	_digitando = false
	_texto.visible_ratio = 1.0
	if _no_atual.has("escolhas"):
		_mostrar_escolhas()
	else:
		_dica.visible = true


func _avancar() -> void:
	if _aguardando_escolha or _terminou:
		return
	if _digitando:
		_tween_texto.kill()
		_ao_terminar_digitacao()
		return
	_ir_para_no(_no_atual.get("proximo", ""))


func _mostrar_escolhas() -> void:
	_aguardando_escolha = true
	var escolhas: Array = _no_atual["escolhas"]
	for i in escolhas.size():
		var botao := Button.new()
		botao.text = "%d.   %s" % [i + 1, escolhas[i].get("texto", "")]
		botao.alignment = HORIZONTAL_ALIGNMENT_LEFT
		botao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		botao.focus_mode = Control.FOCUS_NONE
		botao.add_theme_font_size_override("font_size", 26)
		botao.pressed.connect(_escolher.bind(i))
		_opcoes.add_child(botao)
	_tempo_total = float(_no_atual.get("tempo", 0))
	_tempo_restante = _tempo_total
	_barra_tempo.visible = _tempo_total > 0.0
	_barra_tempo.max_value = _tempo_total
	_barra_tempo.value = _tempo_total


func _process(delta: float) -> void:
	if _aguardando_escolha and _tempo_total > 0.0:
		_tempo_restante -= delta
		_barra_tempo.value = _tempo_restante
		if _tempo_restante <= 0.0:
			# Sem resposta a tempo: vale a escolha padrão (por padrão, a última).
			_escolher(int(_no_atual.get("padrao", _no_atual["escolhas"].size() - 1)))


func _escolher(indice: int) -> void:
	if not _aguardando_escolha:
		return
	_aguardando_escolha = false
	_tempo_total = 0.0
	_barra_tempo.visible = false
	var escolha: Dictionary = _no_atual["escolhas"][indice]
	_definir(escolha.get("definir", {}))
	_limpar_opcoes()
	if escolha.get("mudo", false):
		_ir_para_no(escolha.get("proximo", ""))
	else:
		# O que o protagonista diz aparece como fala dele antes de seguir.
		_no_atual = {"fala": "voce", "texto": escolha.get("dito", escolha.get("texto", "")), "proximo": escolha.get("proximo", "")}
		_mostrar_fala(_no_atual)


func _limpar_opcoes() -> void:
	for filho in _opcoes.get_children():
		filho.queue_free()


func _aplicar_efeito(efeito: String) -> void:
	match efeito:
		"flash":
			_flash.modulate.a = 0.9
			create_tween().tween_property(_flash, "modulate:a", 0.0, 0.4)
		"apagar":
			# A luz pisca e apaga.
			var t := create_tween()
			for alfa in [0.85, 0.0, 0.9, 0.15, 0.97]:
				t.tween_property(_escurecer, "modulate:a", alfa, 0.12)
				t.tween_interval(0.15)


func _concluir() -> void:
	if _terminou:
		return
	_terminou = true
	concluida.emit(dados.get("proxima", ""))


# --- Entrada -------------------------------------------------------------------

func _gui_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_avancar()


func _unhandled_input(evento: InputEvent) -> void:
	if not (evento is InputEventKey and evento.pressed and not evento.echo):
		return
	if evento.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
		_avancar()
	elif _aguardando_escolha and evento.keycode >= KEY_1 and evento.keycode <= KEY_9:
		var indice: int = evento.keycode - KEY_1
		if indice < _no_atual["escolhas"].size():
			_escolher(indice)
