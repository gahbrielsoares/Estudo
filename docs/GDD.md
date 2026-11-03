# Férias: Em Riviera Lake — Documento de Design (Episódio 1)

> **⚠️ SPOILERS: este documento revela o plot twist do jogo.**

## 1. Visão geral

| Item | Definição |
|---|---|
| Título (PT) | Férias: Em Riviera Lake |
| Título (EN / Steam) | Vacation: Riviera Lake |
| Franquia | *Férias* — cada episódio em um lugar novo, ligados pela máscara |
| Gênero | Mistério e suspense investigativo, com escolhas que mudam a história |
| Duração | ~20 minutos por jogada; feito para ser jogado mais de uma vez |
| Plataforma | PC (Steam): Windows, macOS, Linux |
| Engine | Godot 4 (GDScript), conteúdo orientado a dados |
| Tom | Suspense realista, com tensão constante e momentos de humor seco entre amigos |

**Premissa (para o jogador):** cinco amigos passam um fim de semana em um chalé à beira de Riviera Lake. Sem sinal de celular, sem vizinhos. Pendurada na parede, uma máscara que ninguém sabe quem deixou ali. Quando a noite cai, alguém começa a matar.

**Gancho de venda:** *"Suas escolhas decidem quem morre. E quem mata."*

## 2. Pilares de design

1. **Tudo é pé no chão.** Nada sobrenatural. Toda pista é um detalhe que existiria na vida real.
2. **Twist justo.** Toda revelação tem pistas visíveis antes. Quem rever o jogo precisa pensar "estava na minha cara".
3. **Escolhas que parecem inocentes.** As decisões mais importantes parecem conversas sociais sem consequência.
4. **Vale a pena jogar de novo.** Uma segunda jogada mostra outro assassino e reinterpreta cenas da primeira.

## 3. Protagonista

Neutro, para o jogador se projetar. Sem nome, sem rosto visível e sem gênero definido.

- Os amigos nunca dizem o nome do protagonista; usam "ei", "você" ou apelidos neutros.
- **Regra de escrita:** nenhuma fala usa adjetivo com gênero sobre o protagonista. Exemplo: em vez de "você está cansado", escrever "você está com cara de sono".
- Ilustrações em primeira pessoa ou com o protagonista de costas e na sombra.
- O protagonista estava na festa da noite do Davi (ver seção 5), mas o jogo nunca diz o que ele fez. Isso fica reservado para a franquia.

## 4. Elenco

| Personagem | Papel aparente | O que esconde |
|---|---|---|
| **Clara** | A gentil. Estudante de enfermagem, cuida de todos, organizou a viagem dos mantimentos ao kit de primeiros socorros. | É irmã do Davi. Aceitou o convite para descobrir o que aconteceu com ele. **Assassina no Caminho A.** |
| **Rafael** | O líder engraçado. O chalé é da família dele. Faz piada de tudo. | Foi ele quem empurrou o Davi na piscina e o deixou lá. **Assassino no Caminho B.** |
| **Bruna** | A sincera e ansiosa. Não consegue mais viver com a mentira. | Quer contar a verdade à polícia e vem juntando coragem para isso. Principal vítima em ambos os caminhos. |
| **Theo** | O cético. Filma e fotografa tudo com uma câmera antiga. Anda com um canivete. | Nada de grave. É o **falso suspeito** (*red herring*). Suas fotos com horário são pistas valiosas. |

## 5. A história de fundo: a noite do Davi

Um ano antes, os amigos foram a uma festa na casa do Rafael. Davi, um amigo do grupo, morreu afogado na piscina. A versão contada à polícia: ele bebeu demais e caiu sozinho, quando todos já dormiam.

A verdade: Rafael e Davi brigaram, Rafael o empurrou bêbado na piscina e voltou para dentro. Bruna e Theo viram parte da briga. Todos combinaram a mesma versão. Clara, irmã do Davi, nunca acreditou nela.

A viagem a Riviera Lake é, oficialmente, "para espairecer". Na prática, cada um está ali por um motivo diferente.

## 6. Estrutura do episódio (~20 min)

### Ato 1 — Chegada (0 a 4 min)

| Cena | Conteúdo | Escolha |
|---|---|---|
| 1. A chegada | Carro, trilha e chalé. A máscara na parede. Rafael brinca que "sempre esteve aí", mas as fotos de infância dele no corredor mostram a parede vazia. | — |
| 2. A fogueira | Bruna, já tensa, diz que precisam contar a verdade sobre o Davi. Rafael reage com raiva. | **E1: ficar do lado da Bruna ou do Rafael.** |
| 3. A cozinha | A sós, Clara pergunta com calma: "Vocês estavam lá naquela noite. O que aconteceu de verdade com o meu irmão?" | **E2: contar a verdade ou mentir.** |

### Regra que define o assassino

- **Contou a verdade para a Clara (E2)** → **Caminho A: Clara é a assassina.** Ela agradece com um abraço e passa o resto da noite sendo a pessoa mais prestativa do grupo.
- **Mentiu para a Clara** → **Caminho B: Rafael é o assassino.** Com ou sem o seu apoio, a Bruna vai à polícia ao amanhecer. Rafael decide que ninguém sai do lago.

A E1 não define o assassino, mas define **quem confia em você** e muda quem está ao seu lado nas separações.

**Por que isso funciona:** o jogador acha que a E2 é uma questão moral sobre honestidade. Só no final descobre que contar a verdade armou a Clara e que mentir deixou o Rafael sem saída.

### Ato 2 — A noite (4 a 15 min)

A luz cai. A partir daqui, o jogo repete três vezes o ciclo **separação → ataque → investigação**.

**O espelho entre os caminhos:** nos dois caminhos, **o Rafael é o primeiro a "morrer"**. No Caminho B, a morte é falsa. No Caminho A, é real. Quem jogar a segunda vez vai desconfiar da morte do Rafael, e no Caminho A essa desconfiança será a pista falsa.

#### Ciclo 1 — O gerador

- **Separação:** alguém precisa ir ao gerador no galpão. Você escolhe com quem ir.
- **Ataque:** Rafael é encontrado caído no barracão de barcos.
- **Investigação:**
  - **Caminho B (morte falsa):** nenhuma poça de sangue sob o corpo, o vapor da respiração no ar frio visível de perto, o relógio de mergulho dele que reaparece no pulso do mascarado em uma cena posterior.
  - **Caminho A (morte real):** a ferida é precisa demais, como se feita por alguém que sabe anatomia, e há luvas de látex no lixo do chalé, do mesmo tipo do kit de primeiros socorros.

#### Ciclo 2 — O tornozelo

- **Caminho A:** Bruna torce o tornozelo na trilha. Clara cuida dela com carinho e diz que vai buscar o kit no carro, a 2 minutos dali. Ela sai de cena. Corte. Bruna, sozinha, é atacada por alguém que não aparece. Corte. Clara volta, encontra o corpo e se desespera.
  - **Pistas:** a câmera do Theo mostra que a Clara demorou 20 minutos; a manga do casaco dela está molhada, mas não chovia; o botão encontrado junto ao corpo é do casaco dela.
  - **Variação:** se você escolheu ficar com a Bruna no ciclo 1, Clara manda **você** buscar o kit. Quando você volta, a vítima é o Theo, que tinha ido procurar sinal.
- **Caminho B:** Bruna tenta fugir de carro para chegar à polícia. O carro não liga; os fios foram cortados. Ela é atacada.
  - **Pistas:** cabos cortados com um alicate da caixa de ferramentas do Rafael; pegadas de bota tamanho 44 (o Rafael usava 44) indo e voltando do barracão onde estava o "corpo".
  - **Variação:** se você ficou do lado da Bruna na E1, ela te chama para fugir junto. Se aceitar, ela sobrevive a este ciclo e o Theo morre no lugar dela.

#### Ciclo 3 — O cerco

Restam você e um ou dois sobreviventes. O mascarado ataca o chalé. Você precisa decidir se se esconde, foge para o lago ou enfrenta. Cada escolha leva a uma cena final diferente.

### Ato 3 — A acusação e a máscara (15 a 20 min)

1. **O quadro de suspeitos:** você escolhe quem é o assassino com base nas fotos que coletou.
2. **Acusação certa:** você tem a chance de desmascarar o assassino e sobrevive com quem ainda está vivo.
3. **Acusação errada:** o verdadeiro assassino ataca enquanto você aponta para a pessoa errada. O final é pior, mas **a máscara cai mesmo assim**, para que todo jogador veja o twist.
4. **A revelação:**
   - **Clara:** tira a máscara, ainda com o rosto calmo e gentil, e diz que só queria que alguém tivesse contado a verdade antes.
   - **Rafael:** vivo, de pé, com o relógio de mergulho no pulso. "Vocês iam destruir a minha vida por causa de um acidente."

### Pós-créditos — o gancho da franquia

Manhã seguinte. A polícia leva os sobreviventes. Um policial pergunta de quem é a máscara. Ninguém sabe. Corte para outro lugar e outra época: uma casa de praia. A mesma máscara, pendurada em uma parede, à espera.

**Pergunta que fica:** *quem deixa a máscara?*

## 7. Mecânicas

### 7.1 Explorar a cena
Cada cena é uma ilustração estática e detalhada (como um diorama). O jogador pode arrastar e dar zoom. Pontos de interesse mostram uma breve descrição ao serem examinados.

### 7.2 O celular do protagonista (mecânica principal)
O protagonista usa o próprio celular como lanterna e câmera.
- **Fotografar** um detalhe transforma-o em evidência.
- **Bateria:** cada foto e cada uso da lanterna gastam bateria. Isso impede clicar em tudo sem pensar e cria tensão real. Pode haver um carregador em uma cena, se o jogador encontrar.
- Sem sinal de rede durante todo o episódio.

### 7.3 O quadro de suspeitos
As fotos vão para um quadro de cortiça com os rostos do grupo. O jogador prende cada evidência no suspeito que ela incrimina.
- O jogo **não** diz quem é o assassino.
- Quando o jogador liga três evidências corretas a uma mesma **contradição** (por exemplo, "a Clara mentiu sobre o horário"), o jogo confirma aquela contradição. Isso evita chutes e recompensa o raciocínio, sem entregar a resposta.

### 7.4 Escolhas
- Algumas têm tempo para responder (barra de tempo), principalmente no Ato 2.
- As escolhas sociais do Ato 1 não têm tempo, para parecer que "não importam".

### 7.5 Jogar de novo
- Ao final, uma tela mostra quantos caminhos e finais o jogador descobriu (sem revelar quais são).
- Conquistas na Steam para cada assassino descoberto, cada final e "desconfiar do Rafael no caminho errado".

## 8. Direção de arte

- Ilustrações 2D estáticas, ricas em detalhes, inspiradas em dioramas.
- Paleta noturna: azuis frios, com a luz quente da fogueira e da lanterna do celular como contraste.
- Personagens com traços levemente exagerados, para dar identidade sem perder o realismo do tom.
- **Estimativa de produção:** ~16 a 18 ilustrações principais (3 do Ato 1, ~10 entre os ciclos dos dois caminhos e ~4 de finais), além do quadro de suspeitos e da interface.

## 9. Som

- Ambiente noturno: grilos, água do lago, vento nas árvores.
- **O silêncio é um recurso:** antes de cada ataque, os sons da natureza param.
- Trilha mínima; a tensão vem do som ambiente.

## 10. Técnica

- **Engine:** Godot 4, GDScript.
- **Conteúdo orientado a dados:** cada cena é um arquivo (imagem + pontos de interesse + diálogos + escolhas). Criar um episódio novo não exige mudar código.
- **Estado do jogo:** variáveis simples (`e1_lado`, `e2_verdade`, `caminho`, `vivos`, `bateria`, `evidencias`).
- **Steam:** integração via GodotSteam (conquistas, nuvem).
- **Licenças:** código sob MIT; arte, roteiro e cenas sob licença proprietária.

## 11. Roteiro de produção

1. **Protótipo cinza:** uma cena com pontos de interesse, celular com bateria e foto.
2. **Quadro de suspeitos** funcionando com evidências de teste.
3. **Sistema de escolhas e caminhos** com o Ato 1 completo em texto.
4. **Episódio jogável do início ao fim** com arte provisória.
5. **Teste com jogadores:** medir duração, entendimento das pistas e impacto do twist.
6. **Arte final, som e polimento.**
7. **Página na Steam**, demo e participação no Steam Next Fest.
