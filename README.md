# Férias: Em Riviera Lake

*Vacation: Riviera Lake*

> Suas escolhas decidem quem morre. E quem mata.

Cinco amigos passam um fim de semana em um chalé à beira de Riviera Lake. Sem sinal de celular, sem vizinhos. Pendurada na parede, uma máscara que ninguém sabe quem deixou ali. Quando a noite cai, alguém começa a matar.

**Férias: Em Riviera Lake** é o primeiro episódio da série *Férias*: um jogo curto (cerca de 20 minutos) de mistério e suspense investigativo, em que você explora cenas ilustradas, fotografa evidências com o celular e decide em quem confiar.

## Características

- **Investigação com o celular:** use a câmera e a lanterna para coletar evidências, mas cuidado com a bateria.
- **Quadro de suspeitos:** ligue as evidências a cada pessoa e encontre as contradições.
- **Escolhas com consequências:** decisões que parecem simples mudam o rumo da noite.
- **Feito para jogar de novo:** caminhos e finais diferentes a cada jogada.

## Status

Ato 1 e primeiro ciclo do Ato 2 jogáveis (com arte provisória): corredor, fogueira, cozinha, apagão e barracão de barcos. As escolhas mudam o rumo da história, as pistas e a própria cena.

## Como rodar

1. Baixe o [Godot 4.7](https://godotengine.org/download) (versão padrão, não a .NET). Ele não precisa ser instalado.
2. Clone este repositório e abra a pasta no Godot (Importar → `project.godot`).
3. Pressione **F5**.

**Controles na investigação:** mouse move a lanterna · clique examina · **F** liga/desliga a lanterna · **C** modo câmera · **Tab** quadro de suspeitos (arraste as fotos até as pessoas) · **Esc** sai da câmera.

**Controles nos diálogos:** clique, **Espaço** ou **Enter** avançam · **1**, **2**, **3** escolhem uma resposta.

**Depuração:** **F1** mostra as escolhas feitas e o caminho da história (só durante o desenvolvimento).

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `scripts/` | `jogo.gd` (sequência de cenas), `cena_dialogo.gd` (diálogos e escolhas), `estado_jogo.gd` (bateria, lanterna, evidências, quadro, escolhas), `cena_investigacao.gd` (cena jogável) e `quadro_suspeitos.gd` com `cartao_evidencia.gd` e `zona_evidencias.gd` |
| `data/cenas/` | Uma cena por arquivo JSON. Investigação: imagem, pontos de interesse e evidências. Diálogo: falas, escolhas e ramificações |
| `data/quadro.json` | Suspeitos e contradições (quais fotos, presas em quem, confirmam cada uma) |
| `shaders/` | Escuridão e luz da lanterna |
| `art/provisorio/` | Arte temporária do protótipo |
| `docs/` | Documento de design (**contém spoilers**) |

Para criar uma cena nova, basta adicionar uma imagem e um JSON em `data/cenas/`, sem mexer no código. Pistas, imagens, falas e contradições aceitam um campo `"se"` (por exemplo, `{"caminho": "clara"}` ou `{"e1": "bruna"}`) para aparecer só em certas jogadas.

## Tecnologia

- [Godot 4](https://godotengine.org/) (GDScript)
- Conteúdo orientado a dados: cenas, diálogos e escolhas definidos em arquivos
- Lançamento previsto na Steam (Windows, macOS, Linux)

## Licença

- **Código:** MIT
- **Arte, roteiro, textos e cenas:** todos os direitos reservados

> ⚠️ A pasta `docs/` e os arquivos de cena contêm spoilers do jogo.
