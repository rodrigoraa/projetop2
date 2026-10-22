# DEVLOG

## 21/10/2026 — Preparação dos recursos visuais

O que fiz: selecionei sprites gratuitos de sapos, personagem, cenário e itens do pacote Ninja Adventure, de Pixel-boy e AAA, para avaliar no projeto de Coleta em modo Horda.
O que travou: a página oficial do pacote estava bloqueada pelo proxy deste ambiente.
Como resolvi: baixei uma cópia pública no GitHub que preserva o README e a licença CC0; registrei autores, fontes e hashes dos arquivos, sem implementar o jogo.


## Incremento 1 — Projeto executável e cenário

O que fiz: configurei o projeto Godot, a janela ampliada com filtro Nearest e as camadas físicas; montei o pântano com TileMapLayer, atlas dos PNGs existentes e colisões de mundo nas bordas, lagoas e pedras. Registrei o início, 12 pontos de itens e quatro nascedouros, com contêineres e timers parados para os próximos incrementos. Usei assistência de IA nos scripts e mantive a arte e os créditos originais.

O que travou: o primeiro teste falhou porque a arena ainda não existia; depois detectou um ponto de item encostando numa pedra. A importação do editor também tentou salvar configuração fora da área gravável do ambiente.

Como resolvi: implementei a arena após registrar o teste RED, afastei o ponto da pedra e redirecionei os diretórios XDG para `/tmp`. Na Godot 4.6.3, a importação, as 238 verificações funcionais e a inicialização headless por 120 quadros passaram. O cenário permanece estático; jogador, sapos e coleta pertencem aos próximos incrementos.

## Incremento 2 — Jogador, horda e vida

O que fiz: adicionei o Hunter com movimento por WASD/setas a 80 px/s e animação nas quatro direções; sapos pequenos perseguem a 40 px/s. A horda usa os nascedouros livres do mundo a pelo menos 64 px do jogador, começa em 2 s, reduz o intervalo em 5% até 0,8 s e para em 48 sapos. O jogador tem três vidas, contato com invencibilidade de 1 s indicada por transparência e morte única. A conexão provisória inicia a partida automaticamente, mostra as vidas e oferece reinício que limpa a horda. Scripts novos indicam assistência de IA; os PNGs e créditos foram preservados.

O que travou: o teste RED confirmou que as cenas dos atores e o controlador ainda não existiam. A primeira execução após implementar detectou dois códigos incorretos das setas horizontais.

Como resolvi: implementei as cenas e interfaces após o RED e conferi os códigos de tecla na própria Godot. Na Godot 4.6.3, a importação, as 240 verificações de arena, as 94 verificações de atores com cenas e física reais e a inicialização headless por 180 quadros passaram, com código zero e sem erros de script. Os testes cobrem entrada, velocidade diagonal, colisões, perseguição, dano contínuo, invencibilidade, morte, limite de horda, adiamento de nascimento, parada e reinício. A arena isolada mantém timers parados; a cena principal inicia a horda nesta etapa. Coleta e tela inicial ficam para o próximo incremento.


## Incremento 3 — Coleta e ciclo completo

O que fiz: adicionei a folha coletável com trava contra coleta repetida e detecção exclusiva do jogador. A arena começa com uma folha e tenta criar outra a cada 3 s em um ponto livre; um tick com todos os pontos ocupados é adiado. Separei a interface em português, com objetivo, controles, foco de teclado, corações e contador. A partida agora aguarda o botão de início, vence com 20 itens e perde ao zerar as três vidas. O resultado é decidido uma única vez antes de parar a arena. Recomeçar limpa os contêineres e restaura o jogador, contagem e timers, mantendo as conexões feitas uma única vez.

O que travou: o RED do novo teste confirmou o início automático e a ausência dos contratos e cenas de coleta/interface (8 verificações, 7 falhas, código 1). A primeira implementação ainda deixava o jogador ativo na tela inicial, corrigido antes do GREEN. A inspeção gráfica revelou o texto claro sobre o botão focado e a folha inteira de corações comprimida; quatro verificações adicionais reproduziram esses dois problemas antes da correção. A revisão própria também encontrou que retomar uma arena parada não reativava os itens existentes; um teste RED reproduziu a falha e a duplicação do item inicial. Uma captura de derrota mostrou ainda uma coleta indevida após reiniciar: a física entregava um contato da posição antiga do jogador, embora ele já estivesse no centro. Um teste com o item inicial no último ponto visitado reproduziu o caso de forma determinística.

Como resolvi: mantive o jogador inativo até o início explícito, travei cada item antes do sinal e adiei a alteração de monitoramento para respeitar o processamento físico. Corrigi o contraste do botão focado e usei um AtlasTexture de 16 × 16 para os corações, preservando o PNG. A retomada passou a reativar os itens e criar o item inicial apenas quando o contêiner está vazio. Antes de coletar, confirmei a interseção das formas nas posições atuais para rejeitar contatos antigos após o teleporte de reinício. Ajustei as expectativas antigas de início automático sem retirar cobertura e acrescentei verificações dos dois timers em INICIO, JOGANDO, resultado e reinício, resolvendo o achado anterior sobre NascimentoItens.

Na Godot 4.6.3, as suítes passaram com 242 verificações de arena, 99 de atores e 168 de partida (509 no total). Os testes exercitam contatos físicos reais, coleta única, lotação/liberação de pontos, 19/20 itens, duas vitórias, duas derrotas, eventos tardios e múltiplos reinícios sem instâncias antigas. Inspecionei as quatro telas renderizadas no display autenticado; as capturas ficaram em /tmp, fora das fontes. A perseguição permanece direta e pode prender sapos nos obstáculos. Os PNGs, as licenças e os créditos foram preservados.
