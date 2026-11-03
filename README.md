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

Protótipo da mecânica principal: cena escura explorada com a lanterna do celular, fotos como evidências e bateria limitada.

## Como rodar

1. Instale o [Godot 4.3](https://godotengine.org/download) (versão padrão, não a .NET).
2. Clone este repositório e abra a pasta no Godot (Importar → `project.godot`).
3. Pressione **F5**.

**Controles:** mouse move a lanterna · clique examina · **F** liga/desliga a lanterna · **C** modo câmera · **Tab** evidências · **Esc** sai da câmera.

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `scripts/` | `estado_jogo.gd` (bateria, lanterna, evidências, escolhas) e `cena_investigacao.gd` (cena jogável) |
| `data/cenas/` | Uma cena por arquivo JSON: imagem, pontos de interesse, descrições e evidências |
| `shaders/` | Escuridão e luz da lanterna |
| `art/provisorio/` | Arte temporária do protótipo |
| `docs/` | Documento de design (**contém spoilers**) |

Para criar uma cena nova, basta adicionar uma imagem e um JSON em `data/cenas/`, sem mexer no código.

## Tecnologia

- [Godot 4](https://godotengine.org/) (GDScript)
- Conteúdo orientado a dados: cenas, diálogos e escolhas definidos em arquivos
- Lançamento previsto na Steam (Windows, macOS, Linux)

## Licença

- **Código:** MIT
- **Arte, roteiro, textos e cenas:** todos os direitos reservados

> ⚠️ A pasta `docs/` e os arquivos de cena contêm spoilers do jogo.
