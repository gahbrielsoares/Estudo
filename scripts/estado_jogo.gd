extends Node
## Estado global do jogo (autoload "EstadoJogo").
## Guarda bateria, lanterna, evidências e marcadores de história (escolhas, itens usados).

signal bateria_mudou(valor: float)
signal lanterna_mudou(ligada: bool)
signal evidencia_adicionada(evidencia: Dictionary)

const BATERIA_INICIAL := 58.0
const CUSTO_FOTO := 6.0
const CONSUMO_LANTERNA_POR_SEGUNDO := 0.35

var bateria: float = BATERIA_INICIAL
var lanterna_ligada: bool = true
var evidencias: Array[Dictionary] = []
## Marcadores de história: escolhas (ex.: "e2_verdade") e itens já usados.
var marcadores: Dictionary = {}


func _process(delta: float) -> void:
	if lanterna_ligada:
		gastar_bateria(CONSUMO_LANTERNA_POR_SEGUNDO * delta)


func tem_bateria(quantidade: float) -> bool:
	return bateria >= quantidade


func gastar_bateria(quantidade: float) -> void:
	if bateria <= 0.0:
		return
	bateria = maxf(0.0, bateria - quantidade)
	bateria_mudou.emit(bateria)
	if bateria <= 0.0 and lanterna_ligada:
		definir_lanterna(false)


func recarregar(quantidade: float) -> void:
	bateria = minf(100.0, bateria + quantidade)
	bateria_mudou.emit(bateria)


func definir_lanterna(ligada: bool) -> void:
	if ligada and bateria <= 0.0:
		ligada = false
	if ligada == lanterna_ligada:
		return
	lanterna_ligada = ligada
	lanterna_mudou.emit(lanterna_ligada)


func alternar_lanterna() -> void:
	definir_lanterna(not lanterna_ligada)


func tem_evidencia(id: String) -> bool:
	for evidencia in evidencias:
		if evidencia.get("id", "") == id:
			return true
	return false


## Retorna false se a evidência já tinha sido coletada.
func adicionar_evidencia(evidencia: Dictionary) -> bool:
	if tem_evidencia(evidencia.get("id", "")):
		return false
	evidencias.append(evidencia)
	evidencia_adicionada.emit(evidencia)
	return true


func reiniciar() -> void:
	bateria = BATERIA_INICIAL
	lanterna_ligada = true
	evidencias.clear()
	marcadores.clear()
	bateria_mudou.emit(bateria)
	lanterna_mudou.emit(lanterna_ligada)
