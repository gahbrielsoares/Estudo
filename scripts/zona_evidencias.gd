extends PanelContainer
## Uma área do quadro que recebe fotos: a coluna de um suspeito ou a área de fotos soltas.

var quadro: Control
var suspeito: Dictionary = {}
var suspeito_id := ""

var _cartoes: HFlowContainer
var _lista_contradicoes: VBoxContainer


func configurar(dono_quadro: Control, dados_suspeito: Dictionary = {}) -> void:
	quadro = dono_quadro
	suspeito = dados_suspeito
	suspeito_id = dados_suspeito.get("id", "")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.1, 0.07, 0.05, 0.55)
	estilo.set_corner_radius_all(12)
	estilo.set_content_margin_all(14)
	add_theme_stylebox_override("panel", estilo)

	var coluna := VBoxContainer.new()
	coluna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_theme_constant_override("separation", 12)
	add_child(coluna)

	if not suspeito.is_empty():
		coluna.add_child(_criar_cabecalho())
		_lista_contradicoes = VBoxContainer.new()
		_lista_contradicoes.mouse_filter = Control.MOUSE_FILTER_IGNORE
		coluna.add_child(_lista_contradicoes)

	_cartoes = HFlowContainer.new()
	_cartoes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cartoes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cartoes.add_theme_constant_override("h_separation", 10)
	_cartoes.add_theme_constant_override("v_separation", 10)
	coluna.add_child(_cartoes)


func _criar_cabecalho() -> Control:
	var linha := HBoxContainer.new()
	linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	linha.add_theme_constant_override("separation", 12)

	# Retrato provisório: um círculo com a inicial do nome.
	var retrato := PanelContainer.new()
	retrato.custom_minimum_size = Vector2(64, 64)
	retrato.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var circulo := StyleBoxFlat.new()
	circulo.bg_color = Color.from_string(suspeito.get("cor", "#888888"), Color.GRAY)
	circulo.set_corner_radius_all(32)
	retrato.add_theme_stylebox_override("panel", circulo)
	var inicial := Label.new()
	inicial.text = str(suspeito.get("nome", "?")).left(1)
	inicial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inicial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inicial.add_theme_font_size_override("font_size", 32)
	inicial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	retrato.add_child(inicial)
	linha.add_child(retrato)

	var textos := VBoxContainer.new()
	textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var nome := Label.new()
	nome.text = suspeito.get("nome", "")
	nome.add_theme_font_size_override("font_size", 28)
	nome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.add_child(nome)
	var descricao := Label.new()
	descricao.text = suspeito.get("descricao", "")
	descricao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	descricao.add_theme_font_size_override("font_size", 16)
	descricao.add_theme_color_override("font_color", Color(1, 1, 1, 0.65))
	descricao.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.add_child(descricao)
	linha.add_child(textos)
	return linha


func limpar() -> void:
	for cartao in _cartoes.get_children():
		_cartoes.remove_child(cartao)
		cartao.queue_free()


func adicionar_cartao(cartao: Control) -> void:
	cartao.zona = self
	_cartoes.add_child(cartao)


func mostrar_contradicoes(lista: Array) -> void:
	if _lista_contradicoes == null:
		return
	for filho in _lista_contradicoes.get_children():
		filho.queue_free()
	for contradicao in lista:
		var caixa := PanelContainer.new()
		caixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(0.2, 0.45, 0.28, 0.85)
		estilo.set_corner_radius_all(8)
		estilo.set_content_margin_all(10)
		caixa.add_theme_stylebox_override("panel", estilo)
		var texto := Label.new()
		texto.text = "CONFIRMADO · " + str(contradicao.get("titulo", ""))
		texto.tooltip_text = contradicao.get("texto", "")
		texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		texto.add_theme_font_size_override("font_size", 17)
		texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caixa.add_child(texto)
		_lista_contradicoes.add_child(caixa)


func _can_drop_data(_posicao: Vector2, dados: Variant) -> bool:
	return dados is Dictionary and dados.get("tipo", "") == "evidencia"


func _drop_data(_posicao: Vector2, dados: Variant) -> void:
	quadro.fixar(dados["id"], suspeito_id)
