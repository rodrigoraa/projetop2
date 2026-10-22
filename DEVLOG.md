# DEVLOG

## 21/10/2026 — Preparação dos recursos visuais

O que fiz: selecionei sprites gratuitos de sapos, personagem, cenário e itens do pacote Ninja Adventure, de Pixel-boy e AAA, para avaliar no projeto de Coleta em modo Horda.
O que travou: a página oficial do pacote estava bloqueada pelo proxy deste ambiente.
Como resolvi: baixei uma cópia pública no GitHub que preserva o README e a licença CC0; registrei autores, fontes e hashes dos arquivos, sem implementar o jogo.


## Incremento 1 — Projeto executável e cenário

O que fiz: configurei o projeto Godot, a janela ampliada com filtro Nearest e as camadas físicas; montei o pântano com TileMapLayer, atlas dos PNGs existentes e colisões de mundo nas bordas, lagoas e pedras. Registrei o início, 12 pontos de itens e quatro nascedouros, com contêineres e timers parados para os próximos incrementos. Usei assistência de IA nos scripts e mantive a arte e os créditos originais.

O que travou: o primeiro teste falhou porque a arena ainda não existia; depois detectou um ponto de item encostando numa pedra. A importação do editor também tentou salvar configuração fora da área gravável do ambiente.

Como resolvi: implementei a arena após registrar o teste RED, afastei o ponto da pedra e redirecionei os diretórios XDG para `/tmp`. Na Godot 4.6.3, a importação, as 238 verificações funcionais e a inicialização headless por 120 quadros passaram. O cenário permanece estático; jogador, sapos e coleta pertencem aos próximos incrementos.
