# Marcador de Truco

Aplicativo para marcar os pontos no jogo de truco criado para disciplina de Programação Mobile.

Tutorial de criação deste app: http://bit.ly/2MDO6ww

<p align="center">
    <img src="https://miro.medium.com/max/1440/1*UhBQQqZamLVMRhYtkKnhpA.png" width="800"/>
</p>

## Como clonar e importar

-   Faça um fork do projeto
-   Abra o terminal do Visual Studio Code
-   Digite (troque kleberandrade pelo nome do seu usuários): git clone https://github.com/kleberandrade/marcador-truco-aulas-flutter.git marcador_truco

## Desafios

- Não deixar que seja possível ficar com pontos negativos ao clicar em (-1) e também não pode ultrapassar 12 pontos.
- Permitir de alguma forma que a partida seja reiniciada, sem zerar o número de vitórias
- Transformar o AlertDialog em modal para que somente desapareça da tela ao clicar em CANCEL ou OK. Uma dia, precisa utilizar o atributo barrierDismissible
- Trocar os nomes dos usuários ao clicar em cima do nome (Text). Pode-se utilizar um GestureDetector e exibir um AlertDialog com um TextField. [Exemplo de AlertDialog com TextField](https://inducesmile.com/google-flutter/how-to-add-textfield-input-in-an-alert-dialog-in-flutter/).
- Exibir uma notificação da mão de ferro: é a Mão de Onze especial, quando as duas duplas conseguem chegar a 11 pontos na partida. Todos os jogadores recebem as cartas “cobertas”, isto é, viradas para baixo, e deverão jogar assim. Quem vencer a mão, vence a partida
- Instale o plugin [Screen](https://pub.dev/packages/screen#-readme-tab-) e adicione um código para deixar a tela sempre ativa enquanto joga.

## Licença

    Copyright 2019 Kleber de Oliveira Andrade
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
