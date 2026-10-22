# Catálogo da seleção — Ninja Adventure

Autores: **Pixel-boy e AAA**. Licença: **CC0 1.0 Universal**.

- [Página oficial](https://pixel-boy.itch.io/ninja-adventure-asset-pack)
- [README original do pacote](README.original.md)
- [Licença original integral](LICENSE.txt)
- [Proveniência, medidas e SHA256 por arquivo](PROVENIENCIA.json)

Os PNGs foram copiados sem redimensionamento, recorte ou recoloração. A estrutura e os nomes internos do pacote foram preservados. Não foram incorporados scripts, cenas ou metadados Unity do espelho.

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
- A arte ainda precisa ser importada e configurada na Godot. Estes arquivos, por si só, não criam colisões, animações, coleta ou efeitos de veneno.
- O terreno usa principalmente peças de 16 × 16 px, mas há imagens e objetos de outros tamanhos. `TilesetFloor.png` tem altura original de 417 px; confira a região útil ao configurar o atlas, sem presumir que toda a imagem seja uma grade exata.
- O personagem e os ícones são alternativas para avaliação. A escolha final do jogador e do item coletável ainda não foi definida.

## Origem do download

A página oficial não pôde ser acessada neste ambiente por restrição do proxy. A seleção veio de `Assets/NinjaAdventure` no espelho público `MarioLDD/Kuroshiro-adventure`, commit `0476a561d5e6da477d5d2de2e738f0595754adbb`. O README do pacote identifica os autores, aponta a página oficial e declara CC0; a licença integral acompanha a seleção.
