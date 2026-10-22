# Catálogo da seleção — Ninja Adventure

Autores: **Pixel-boy e AAA**. Licença: **CC0 1.0 Universal**.

- [Página oficial](https://pixel-boy.itch.io/ninja-adventure-asset-pack)
- [README original do pacote](README.original.md)
- [Licença original integral](LICENSE.txt)
- [Proveniência, medidas e SHA256 por arquivo](PROVENIENCIA.json)

Copiei os PNGs sem redimensionar, recortar ou mudar as cores. Mantive a estrutura e os nomes internos do pacote e não trouxe os scripts, cenas ou metadados Unity do espelho.

## Conteúdo disponível

| Pasta ou arquivo | Conteúdo |
|---|---|
| `Actor/Animals/Frog/` | Sapo pequeno: folha de 32 × 16 px com duas poses de 16 × 16; retrato separado |
| `Actor/Boss/GiantFrog/` | Sapo verde: animações em quadros de 40 × 40 e retrato |
| `Actor/Boss/GiantFrog2/` | Sapo rosa/vermelho: animações em quadros de 40 × 40 e retrato |
| `Actor/Characters/Hunter/` | Opção de personagem com folha de 64 × 112 px e retrato |
| `Backgrounds/Tilesets/` | Chão, detalhes, vegetação, árvores, pedras, água e relevo |
| `Backgrounds/Animated/Plant/` | Planta animada |
| `Backgrounds/Animated/Water Ripples/` | Ondulações de água |
| `Items/Food/` | Folha e semente, opções visuais de coletáveis |
| `Items/Potion/` | Frascos, opções visuais de coletáveis |
| `Ui/LifeReceptacle/` | Três folhas de corações para interface |
| `FX/Environment/Fog.png` | Textura de névoa |

## Limitações e notas para uso posterior

- Os sapos maiores têm animações frontais, não animações completas nas quatro direções. Os retratos `Faceset.png` são imagens separadas, não quadros de movimento.
- Nos sapos maiores: repouso tem 5 quadros; salto, 6; preparação, 7; ataque e dano, 3 cada. Cada quadro tem 40 × 40 px.
- A pasta `Boss` é o nome do pacote original. Sua presença não define uma mecânica de chefe para o projeto. Da mesma forma, as animações de ataque não tornam combate obrigatório em Coleta.
- Configurei na Godot as colisões, as animações e a coleta usadas no jogo. Os sprites restantes ficam disponíveis para avaliar depois.
- O terreno usa principalmente peças de 16 × 16 px, mas há imagens e objetos de outros tamanhos. `TilesetFloor.png` tem altura original de 417 px; confira a região útil ao configurar o atlas, sem presumir que toda a imagem seja uma grade exata.
- Escolhi o Hunter como jogador, o sapo pequeno como inimigo e a TeaLeaf como coletável.

## Origem do download

Não consegui acessar a página oficial por causa do proxy do ambiente. Baixei a seleção de `Assets/NinjaAdventure` no espelho público `MarioLDD/Kuroshiro-adventure`, commit `0476a561d5e6da477d5d2de2e738f0595754adbb`. Conferi os autores e a licença no README original e mantive os dois arquivos junto dos sprites.
