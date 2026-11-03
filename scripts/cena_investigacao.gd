extends Control
## Cena de investigação: uma ilustração estática explorada com a lanterna do celular.
## Os pontos de interesse vêm de um arquivo JSON, para que novas cenas não exijam código novo.

signal concluida(proxima: String)

const QuadroSuspeitos := preload("res://scripts/quadro_suspeitos.gd")
const CenaDialogo := preload("res://scripts/cena_dialogo.gd")

@export_file("*.json") var caminho_dados := "res://data/cenas/cena_01_corredor.json"

const RAIO_LANTERNA := 230.0
const TEMPO_TEXTO := 6.0
const COR_PAINEL := Color(0.05, 0.05, 0.07, 0.88)
const COR_DESTAQUE := Color(0.95, 0.82, 0.55)

var dados: Dictionary = {}
var modo_camera := false

var _pos_luz := Vector2(960, 540)
var _alvo_luz := Vector2(960, 540)
var _aviso_bateria_dado := false

var _imagem: TextureRect
var _pontos: Control
var _escuridao: ColorRect
var _material_escuridao: ShaderMaterial
var _flash: ColorRect
var _moldura_camera: ReferenceRect
var _aviso_camera: Label
var _caixa_texto: PanelContainer
var _titulo_texto: Label
var _corpo_texto: Label
var _temporizador_texto: Timer
var _rotulo_bateria: Label
var _barra_bateria: ProgressBar
var _botao_lanterna: Button
var _botao_camera: Button
var _botao_evidencias: Button
var _quadro: Control
var _botao_saida: Button
var _confirmando_saida := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dados = _carregar_dados(caminho_dados)
	_montar_cena()
	_montar_hud()
	EstadoJogo.bateria_mudou.connect(_ao_mudar_bateria)
	EstadoJogo.lanterna_mudou.connect(_ao_mudar_lanterna)
	EstadoJogo.evidencia_adicionada.connect(_ao_adicionar_evidencia)
	for evidencia in EstadoJogo.evidencias:
		_ao_adicionar_evidencia(evidencia)
	_ao_mudar_bateria(EstadoJogo.bateria)
	_ao_mudar_lanterna(EstadoJogo.lanterna_ligada)
	var intro: Dictionary = dados.get("introducao", {})
	if not intro.is_empty():
		mostrar_texto(intro.get("titulo", ""), intro.get("texto", ""), 9.0)


func _process(delta: float) -> void:
	# A luz segue o mouse com um pequeno atraso, como uma mão segurando o celular.
	_pos_luz = _pos_luz.lerp(_alvo_luz, 1.0 - exp(-delta * 18.0))
	var raio := 0.0
	if EstadoJogo.lanterna_ligada:
		raio = RAIO_LANTERNA
		if EstadoJogo.bateria < 15.0 and randf() < 0.12:
			raio *= randf_range(0.55, 0.9)  # bateria fraca: a luz falha
	_material_escuridao.set_shader_parameter("posicao_luz", _pos_luz)
	_material_escuridao.set_shader_parameter("tamanho", size)
	_material_escuridao.set_shader_parameter("raio", raio)
	_material_escuridao.set_shader_parameter("escuridao", 0.94 if EstadoJogo.lanterna_ligada else 0.975)


func _input(evento: InputEvent) -> void:
	if evento is InputEventMouse:
		_alvo_luz = get_global_transform_with_canvas().affine_inverse() * evento.position


func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and not evento.echo:
		match evento.keycode:
			KEY_F:
				EstadoJogo.alternar_lanterna()
			KEY_C:
				if not _quadro.visible:
					_alternar_camera()
			KEY_TAB:
				_alternar_evidencias()
			KEY_ESCAPE:
				if _quadro.visible:
					_alternar_evidencias()
				elif modo_camera:
					_alternar_camera()


# --- Dados -----------------------------------------------------------------

func _carregar_dados(caminho: String) -> Dictionary:
	var texto := FileAccess.get_file_as_string(caminho)
	if texto.is_empty():
		push_error("Não foi possível ler a cena: %s" % caminho)
		return {}
	var resultado: Variant = JSON.parse_string(texto)
	if typeof(resultado) != TYPE_DICTIONARY:
		push_error("JSON inválido na cena: %s" % caminho)
		return {}
	return resultado


# --- Montagem da cena --------------------------------------------------------

func _montar_cena() -> void:
	_imagem = TextureRect.new()
	_imagem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_imagem.stretch_mode = TextureRect.STRETCH_SCALE
	_imagem.mouse_filter = Control.MOUSE_FILTER_STOP
	dados["imagem"] = CenaDialogo._escolher_imagem(dados)
	_imagem.texture = load(dados["imagem"])
	_imagem.gui_input.connect(_ao_clicar_fundo)
	add_child(_imagem)

	_pontos = Control.new()
	_pontos.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pontos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_pontos)
	for ponto in dados.get("pontos", []):
		if EstadoJogo.condicao(ponto.get("se", {})):
			_criar_ponto(ponto)

	_escuridao = ColorRect.new()
	_escuridao.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_escuridao.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_material_escuridao = ShaderMaterial.new()
	_material_escuridao.shader = load("res://shaders/lanterna.gdshader")
	_escuridao.material = _material_escuridao
	add_child(_escuridao)

	_moldura_camera = ReferenceRect.new()
	_moldura_camera.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_moldura_camera.offset_left = 40
	_moldura_camera.offset_top = 40
	_moldura_camera.offset_right = -40
	_moldura_camera.offset_bottom = -40
	_moldura_camera.editor_only = false
	_moldura_camera.border_color = Color(1, 1, 1, 0.55)
	_moldura_camera.border_width = 3.0
	_moldura_camera.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_moldura_camera.visible = false
	add_child(_moldura_camera)

	_aviso_camera = Label.new()
	_aviso_camera.text = "MODO CÂMERA  ·  clique para fotografar (−%d%% de bateria)  ·  Esc para sair" % int(EstadoJogo.CUSTO_FOTO)
	_aviso_camera.add_theme_font_size_override("font_size", 26)
	_aviso_camera.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	_aviso_camera.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso_camera.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_ancorar(_aviso_camera, 0.0, 0.0, 1.0, 0.0, 0, 60, 0, 110)
	_aviso_camera.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aviso_camera.visible = false
	add_child(_aviso_camera)

	_flash = ColorRect.new()
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color.WHITE
	_flash.modulate.a = 0.0
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)


func _criar_ponto(ponto: Dictionary) -> void:
	var r: Array = ponto.get("retangulo", [0, 0, 0, 0])
	var area := Control.new()
	area.name = ponto.get("id", "ponto")
	area.position = Vector2(r[0], r[1])
	area.size = Vector2(r[2], r[3])
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.gui_input.connect(_ao_clicar_ponto.bind(ponto))
	_pontos.add_child(area)


# --- HUD ------------------------------------------------------------------

func _montar_hud() -> void:
	# Celular (canto inferior direito)
	var celular := _novo_painel()
	_ancorar(celular, 1, 1, 1, 1, -380, -330, -30, -30)
	add_child(celular)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 10)
	celular.add_child(coluna)
	coluna.add_child(_novo_rotulo("CELULAR · sem sinal", 20, Color(1, 1, 1, 0.5)))
	_rotulo_bateria = _novo_rotulo("", 30, Color.WHITE)
	coluna.add_child(_rotulo_bateria)
	_barra_bateria = ProgressBar.new()
	_barra_bateria.show_percentage = false
	_barra_bateria.custom_minimum_size = Vector2(0, 14)
	coluna.add_child(_barra_bateria)
	_botao_lanterna = _novo_botao("", func(): EstadoJogo.alternar_lanterna())
	coluna.add_child(_botao_lanterna)
	_botao_camera = _novo_botao("Câmera  [C]", _alternar_camera)
	coluna.add_child(_botao_camera)
	_botao_evidencias = _novo_botao("Quadro de suspeitos (0)  [Tab]", _alternar_evidencias)
	coluna.add_child(_botao_evidencias)

	# Caixa de texto (canto inferior esquerdo)
	_caixa_texto = _novo_painel()
	_ancorar(_caixa_texto, 0, 1, 0, 1, 30, -230, 1150, -30)
	_caixa_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caixa_texto.visible = false
	add_child(_caixa_texto)
	var coluna_texto := VBoxContainer.new()
	coluna_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE  # o texto não pode bloquear cliques na cena
	_caixa_texto.add_child(coluna_texto)
	_titulo_texto = _novo_rotulo("", 30, COR_DESTAQUE)
	coluna_texto.add_child(_titulo_texto)
	_corpo_texto = _novo_rotulo("", 26, Color(0.92, 0.92, 0.92))
	_corpo_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coluna_texto.add_child(_corpo_texto)
	_temporizador_texto = Timer.new()
	_temporizador_texto.one_shot = true
	_temporizador_texto.timeout.connect(func(): _caixa_texto.visible = false)
	add_child(_temporizador_texto)

	# Saída da cena (canto superior direito)
	var saida: Dictionary = dados.get("saida", {})
	if not saida.is_empty():
		_botao_saida = _novo_botao("  %s  →  " % saida.get("rotulo", "Continuar"), _ao_clicar_saida.bind(saida))
		_botao_saida.add_theme_font_size_override("font_size", 24)
		_ancorar(_botao_saida, 1, 0, 1, 0, -480, 40, -40, 100)
		add_child(_botao_saida)

	# Quadro de suspeitos (tela cheia, por cima de tudo)
	_quadro = QuadroSuspeitos.new()
	_quadro.visible = false
	_quadro.fechado.connect(_alternar_evidencias)
	add_child(_quadro)


func _novo_painel() -> PanelContainer:
	var painel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = COR_PAINEL
	estilo.set_corner_radius_all(14)
	estilo.set_content_margin_all(20)
	estilo.border_color = Color(1, 1, 1, 0.08)
	estilo.set_border_width_all(1)
	painel.add_theme_stylebox_override("panel", estilo)
	return painel


func _novo_rotulo(texto: String, tamanho: int, cor: Color) -> Label:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.add_theme_font_size_override("font_size", tamanho)
	rotulo.add_theme_color_override("font_color", cor)
	return rotulo


func _novo_botao(texto: String, acao: Callable) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.focus_mode = Control.FOCUS_NONE
	botao.add_theme_font_size_override("font_size", 22)
	botao.pressed.connect(acao)
	return botao


func _ancorar(c: Control, al: float, at: float, ar: float, ab: float, ol: float, ot: float, orr: float, ob: float) -> void:
	c.anchor_left = al
	c.anchor_top = at
	c.anchor_right = ar
	c.anchor_bottom = ab
	c.offset_left = ol
	c.offset_top = ot
	c.offset_right = orr
	c.offset_bottom = ob


func mostrar_texto(titulo: String, corpo: String, duracao: float = TEMPO_TEXTO) -> void:
	_titulo_texto.text = titulo
	_titulo_texto.visible = not titulo.is_empty()
	_corpo_texto.text = corpo
	_caixa_texto.visible = true
	_temporizador_texto.start(duracao)


# --- Interação ------------------------------------------------------------

func _e_clique(evento: InputEvent) -> bool:
	return evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT


func _ao_clicar_ponto(evento: InputEvent, ponto: Dictionary) -> void:
	if not _e_clique(evento):
		return
	accept_event()
	if not EstadoJogo.lanterna_ligada:
		mostrar_texto("", "Está escuro demais para ver qualquer coisa. Ligue a lanterna [F].")
		return
	if modo_camera:
		_tirar_foto(ponto)
	else:
		_examinar(ponto)


func _ao_clicar_fundo(evento: InputEvent) -> void:
	if not _e_clique(evento) or not modo_camera:
		return
	if not EstadoJogo.lanterna_ligada:
		mostrar_texto("", "Está escuro demais para fotografar. Ligue a lanterna [F].")
		return
	_tirar_foto({})


func _examinar(ponto: Dictionary) -> void:
	var nome: String = ponto.get("nome", "")
	var item: Dictionary = ponto.get("item", {})
	if item.get("tipo", "") == "recarga":
		var marcador := "usado_" + str(ponto.get("id", ""))
		if EstadoJogo.marcadores.get(marcador, false):
			mostrar_texto(nome, item.get("texto_usado", ""))
		else:
			EstadoJogo.marcadores[marcador] = true
			EstadoJogo.recarregar(float(item.get("quantidade", 0)))
			mostrar_texto(nome, item.get("texto_uso", ""))
		return
	mostrar_texto(nome, ponto.get("descricao", ""))


func _tirar_foto(ponto: Dictionary) -> void:
	var evidencia: Dictionary = ponto.get("evidencia", {})
	if not evidencia.is_empty() and EstadoJogo.tem_evidencia(evidencia.get("id", "")):
		mostrar_texto("Foto", "Você já fotografou isso.")
		return
	if not EstadoJogo.tem_bateria(EstadoJogo.CUSTO_FOTO):
		mostrar_texto("Bateria", "Bateria insuficiente para tirar uma foto.")
		return
	EstadoJogo.gastar_bateria(EstadoJogo.CUSTO_FOTO)
	_animar_flash()
	if evidencia.is_empty():
		mostrar_texto("Foto", "A foto não mostra nada de útil. Bateria desperdiçada.")
	else:
		EstadoJogo.adicionar_evidencia(_com_foto(evidencia, ponto))
		mostrar_texto("Nova evidência", evidencia.get("titulo", "") + "  ·  veja no quadro de suspeitos [Tab]")


## Guarda na evidência o recorte da cena onde a foto foi tirada, para virar miniatura no quadro.
func _com_foto(evidencia: Dictionary, ponto: Dictionary) -> Dictionary:
	var copia := evidencia.duplicate()
	var r: Array = ponto.get("retangulo", [0, 0, 0, 0])
	var centro := Vector2(r[0] + r[2] / 2.0, r[1] + r[3] / 2.0)
	var lado := maxf(r[2], r[3]) * 1.3
	var regiao := Rect2(centro - Vector2(lado, lado * 0.7) / 2.0, Vector2(lado, lado * 0.7))
	regiao = regiao.intersection(Rect2(0, 0, 1920, 1080))
	copia["imagem"] = dados.get("imagem", "")
	copia["regiao"] = [regiao.position.x, regiao.position.y, regiao.size.x, regiao.size.y]
	return copia


func _animar_flash() -> void:
	_flash.modulate.a = 0.85
	create_tween().tween_property(_flash, "modulate:a", 0.0, 0.35)


func _ao_clicar_saida(saida: Dictionary) -> void:
	if not _confirmando_saida:
		_confirmando_saida = true
		_botao_saida.text = "  Confirmar  →  "
		mostrar_texto(saida.get("rotulo", ""), saida.get("confirmacao", "Você não poderá voltar aqui."))
		return
	if _quadro.visible:
		_alternar_evidencias()
	concluida.emit(dados.get("proxima", ""))


func _alternar_camera() -> void:
	modo_camera = not modo_camera
	_moldura_camera.visible = modo_camera
	_aviso_camera.visible = modo_camera
	_botao_camera.text = "Sair da câmera  [Esc]" if modo_camera else "Câmera  [C]"


func _alternar_evidencias() -> void:
	_quadro.visible = not _quadro.visible
	EstadoJogo.pausado = _quadro.visible  # a bateria não gasta enquanto você pensa
	if _quadro.visible and modo_camera:
		_alternar_camera()


# --- Reações ao estado -------------------------------------------------------

func _ao_mudar_bateria(valor: float) -> void:
	_rotulo_bateria.text = "Bateria %d%%" % int(ceil(valor))
	_barra_bateria.value = valor
	var cor := Color(0.45, 0.85, 0.5)
	if valor < 15.0:
		cor = Color(0.9, 0.3, 0.25)
	elif valor < 35.0:
		cor = Color(0.95, 0.75, 0.3)
	_rotulo_bateria.add_theme_color_override("font_color", cor)
	if valor <= 0.0 and not _aviso_bateria_dado:
		_aviso_bateria_dado = true
		mostrar_texto("Bateria", "A tela apaga. A bateria acabou.", 8.0)


func _ao_mudar_lanterna(ligada: bool) -> void:
	_botao_lanterna.text = ("Desligar lanterna" if ligada else "Ligar lanterna") + "  [F]"
	var cursor := Control.CURSOR_POINTING_HAND if ligada else Control.CURSOR_ARROW
	for area in _pontos.get_children():
		(area as Control).mouse_default_cursor_shape = cursor


func _ao_adicionar_evidencia(_evidencia: Dictionary) -> void:
	_botao_evidencias.text = "Quadro de suspeitos (%d)  [Tab]" % EstadoJogo.evidencias.size()
