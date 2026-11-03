extends PanelContainer
## Foto de evidência no quadro de suspeitos. Pode ser arrastada até um suspeito.
## Quando faz parte de uma contradição confirmada, fica travada no lugar.

var evidencia: Dictionary = {}
var travado := false
## Zona (suspeito ou fotos soltas) onde o cartão está. Recebe os drops feitos sobre o cartão.
var zona: Control


func _init(dados_evidencia: Dictionary = {}, esta_travado: bool = false) -> void:
	evidencia = dados_evidencia
	travado = esta_travado


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_ARROW if travado else Control.CURSOR_DRAG
	tooltip_text = evidencia.get("texto", "")

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.94, 0.92, 0.87)
	estilo.set_content_margin_all(8)
	estilo.content_margin_bottom = 12
	estilo.shadow_color = Color(0, 0, 0, 0.45)
	estilo.shadow_size = 6
	estilo.shadow_offset = Vector2(2, 3)
	if travado:
		estilo.border_color = Color(0.35, 0.75, 0.45)
		estilo.set_border_width_all(4)
	add_theme_stylebox_override("panel", estilo)

	var coluna := VBoxContainer.new()
	coluna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(coluna)

	var miniatura := TextureRect.new()
	miniatura.custom_minimum_size = Vector2(150, 105)
	miniatura.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	miniatura.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	miniatura.clip_contents = true
	miniatura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	miniatura.texture = _criar_miniatura()
	coluna.add_child(miniatura)

	var titulo := Label.new()
	titulo.text = evidencia.get("titulo", "")
	titulo.custom_minimum_size = Vector2(150, 0)
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titulo.add_theme_font_size_override("font_size", 17)
	titulo.add_theme_color_override("font_color", Color(0.15, 0.12, 0.1))
	titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_child(titulo)


## Recorta o pedaço da cena onde a foto foi tirada.
func _criar_miniatura() -> Texture2D:
	var caminho: String = evidencia.get("imagem", "")
	if caminho.is_empty():
		return null
	var textura := load(caminho) as Texture2D
	var r: Array = evidencia.get("regiao", [])
	if textura == null or r.size() != 4:
		return textura
	var recorte := AtlasTexture.new()
	recorte.atlas = textura
	recorte.region = Rect2(r[0], r[1], r[2], r[3])
	return recorte


func _get_drag_data(_posicao: Vector2) -> Variant:
	if travado:
		return null
	var previa := Label.new()
	previa.text = "  " + str(evidencia.get("titulo", "")) + "  "
	previa.add_theme_font_size_override("font_size", 20)
	previa.add_theme_color_override("font_color", Color(0.15, 0.12, 0.1))
	var fundo := StyleBoxFlat.new()
	fundo.bg_color = Color(0.94, 0.92, 0.87)
	fundo.set_content_margin_all(10)
	previa.add_theme_stylebox_override("normal", fundo)
	set_drag_preview(previa)
	modulate.a = 0.35
	return {"tipo": "evidencia", "id": evidencia.get("id", "")}


func _notification(o_que: int) -> void:
	if o_que == NOTIFICATION_DRAG_END:
		modulate.a = 1.0


func _can_drop_data(posicao: Vector2, dados: Variant) -> bool:
	return zona != null and zona._can_drop_data(posicao, dados)


func _drop_data(posicao: Vector2, dados: Variant) -> void:
	if zona != null:
		zona._drop_data(posicao, dados)
