# DEVLOG

## 21/10/2026 — Escolha dos sprites

Separei os sprites de sapos, personagem, terreno e itens do pacote Ninja Adventure.
O acesso à página oficial estava bloqueado no ambiente, então usei um espelho público do pacote no GitHub.
Conferi a licença CC0 e mantive os créditos, os arquivos originais e o registro da origem.

## Primeiro incremento — Cenário

Configurei o projeto na Godot e montei o pântano com chão, lagoas, árvores, pedras e colisões.
Deixei o centro livre e marquei os pontos de início, de nascimento dos sapos e dos itens.
Um ponto de item estava perto demais de uma pedra; afastei esse ponto depois de conferir a colisão.
Também ajustei os diretórios de configuração para conseguir executar os testes no ambiente. Usei assistência de IA nos scripts, com indicação nos comentários.

## Segundo incremento — Jogador e horda

Adicionei movimento nas quatro direções, os sapos perseguindo o jogador e a horda que acelera com o tempo.
Implementei três vidas e um segundo de invencibilidade depois do dano.
Os códigos das setas horizontais estavam incorretos; conferi os valores na Godot e corrigi.
Testei movimento, colisões, dano, limite de inimigos e reinício com as cenas do jogo.

## Terceiro incremento — Coleta

Adicionei as folhas, o contador até 20 e as telas de início, vitória e derrota.
Corrigi o contraste do botão selecionado, o recorte dos corações e a reativação dos itens ao retomar a arena.
No reinício, um contato antigo da física podia contar uma folha à distância; passei a conferir as posições atuais antes de aceitar a coleta.
As três suítes passaram com 509 verificações na Godot 4.6.3. Também conferi as telas renderizadas e o reinício da partida.

## 22/10/2026 — Aula 09: sobrevivência

Separei a versão de sobrevivência por 60 segundos pedida na Aula 09, mantendo a Coleta disponível.
Reaproveitei o jogador, a arena e a interface; nesse modo, o HUD mostra o tempo e não nascem folhas.
Mantive a tag da Aula 08 e reservei a tag `aula-09` para a versão que abre diretamente a sobrevivência.
Os testes passaram com 644 verificações, incluindo a espera pelos 60 segundos simulados e os reinícios. Também conferi a nova tela inicial renderizada.
