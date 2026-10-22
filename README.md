# Pântano de sapos venenosos

Projeto acadêmico de Jogos Digitais II.

| Carta | Definição |
|---|---|
| Tema | Pântano de sapos venenosos |
| Tipo | Coleta |
| Objetivo | Juntar 20 itens que surgem pela arena |
| Modo | Horda, com visão de cima |

## Estado atual

O protótipo executa um cenário de pântano: arena de 640 × 384 px em grade de 16 px, chão verde e terra, duas lagoas laterais, árvores fechando o perímetro e pedras com colisão. A janela inicial de 1280 × 768 px usa filtro Nearest para manter os pixels nítidos.

O centro fica livre. A arena oferece o início do jogador, 12 pontos de itens e quatro nascedouros como `Marker2D`. Os contêineres `Atores` e `Itens` e os timers `Horda` e `NascimentoItens` ficam dentro de `Arena`. A arena isolada e a tela inicial começam inativas; escolha **Iniciar partida** para jogar. As camadas físicas são Mundo (1), Jogador (2) e Inimigos (3).

Use **WASD ou setas** para mover o Hunter a 80 px/s. Os sapos pequenos perseguem diretamente a 40 px/s, respeitando o mundo. A horda começa com um nascimento a cada 2 s, reduz o intervalo em 5% até 0,8 s e limita a arena a 48 sapos. Os nascimentos usam pontos livres do mundo a pelo menos 64 px do jogador.

O jogador começa com três vidas. Contato com sapos tira uma vida e concede 1 s de invencibilidade, indicada pela transparência do personagem. Uma folha aparece ao iniciar e outra nasce a cada 3 s em um dos 12 pontos livres, sem empilhamento. Passe sobre ela para coletar. Ao juntar **20 folhas**, você vence; ao perder as três vidas, a partida termina em derrota. Não há limite de tempo.

As telas mostram o objetivo, os controles e o resultado em português. O HUD apresenta vidas, corações e **Itens: n / 20**. Os botões recebem foco de teclado: **Enter ou Espaço** confirma. Após vitória ou derrota, a arena congela e o resultado fica fixo. **Recomeçar** limpa itens e sapos antigos e restaura três vidas, contador zero e os intervalos iniciais.

A perseguição é direta: sapos respeitam as colisões, mas podem ficar presos em pedras e lagoas, sem procurar caminhos alternativos. Esta versão não inclui combate, chefes, efeito de veneno acumulativo, áudio novo nem exportação.

## Executar e testar

Abra `project.godot` na Godot e use F6 em `scenes/principal.tscn` ou F5 para executar o projeto. A configuração usa o renderizador GL Compatibility. Validado com **Godot 4.6.3**; a versão 4.7.1 citada no roteiro não estava disponível neste ambiente.

Na raiz do repositório:

```sh
godot --headless --path . --editor --import
godot --headless --path . --script tests/test_arena.gd
godot --headless --path . --script tests/test_atores.gd
godot --headless --path . --script tests/test_partida.gd
godot --headless --path . --quit-after 120
```

Os testes retornam código diferente de zero em caso de falha. Verificam arena, movimento por ações de entrada, velocidade diagonal, colisões, perseguição, contato com invencibilidade, morte única, limite de horda, coleta por contato, lotação de pontos, vitória em 20 itens, derrota, resultado fixo e reinícios usando cenas e física reais. As três suítes executaram 509 verificações na Godot 4.6.3. As telas inicial, de jogo, vitória e derrota também foram inspecionadas com renderização gráfica neste ambiente. O mapa é montado em `scripts/arena.gd` ao executar a cena; os pontos ficam editáveis em `scenes/arena.tscn`. A assistência de IA está indicada nos scripts novos.

Em ambientes com diretório pessoal somente para leitura, execute antes:

```sh
mkdir -p /tmp/projetop2-config /tmp/projetop2-cache /tmp/projetop2-data
export XDG_CONFIG_HOME=/tmp/projetop2-config
export XDG_CACHE_HOME=/tmp/projetop2-cache
export XDG_DATA_HOME=/tmp/projetop2-data
```

Os caches `.godot/` e logs são locais e não entram no Git. Os arquivos `.import` e `.uid` preservam as configurações de importação e identificadores do projeto.

## Recursos visuais e créditos

- **Pacote:** Ninja Adventure Asset Pack.
- **Autores:** [Pixel-boy](https://pixel-boy.itch.io/) e [AAA](https://www.instagram.com/challenger.aaa/).
- **Página oficial:** https://pixel-boy.itch.io/ninja-adventure-asset-pack
- **Licença:** [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/), com [texto integral preservado](sprites/ninja-adventure/LICENSE.txt).
- **Download:** [espelho público no GitHub, em revisão fixa](https://github.com/MarioLDD/Kuroshiro-adventure/tree/0476a561d5e6da477d5d2de2e738f0595754adbb/Assets/NinjaAdventure).

A seleção inclui sapos, uma opção de personagem, água, vegetação, terreno, itens, corações e névoa. Os arquivos originais foram mantidos sem alterações. CC0 permite uso, adaptação e redistribuição, inclusive comercial; os créditos são mantidos também para atender à orientação da disciplina.

Consulte o [catálogo dos sprites](sprites/ninja-adventure/README.md) para conhecer os arquivos e suas limitações. O protótipo usa o Hunter como jogador e a TeaLeaf como coletável; os demais recursos selecionados não definem mecânicas adicionais.

## Histórico do trabalho

O [DEVLOG](DEVLOG.md) registra o processo real. Commits de preparação não substituem as entregas das aulas; as tags de cada aula devem apontar para o incremento correspondente quando ele estiver implementado e validado.
