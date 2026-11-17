# Criando um marcador de truco em Flutter

## Notas de aula do prof. Kleber de Oliveira Andrade

Nesta aula, vamos construir e explorar o Mesa de Truco: um marcador local para duas equipes, com nomes editáveis, pontos de 0 a 12 e histórico de vitórias da sessão. O objetivo é aprender a separar regras, armazenamento e interface em um aplicativo pequeno, que você consegue testar.

Esta é a atualização das notas publicadas em 2019. Usaremos Flutter 3.41.9, Dart 3.11.5 com null safety e Material 3. O endereço e a autoria da aula continuam os mesmos; as imagens mostram a implementação atual, não a antiga versão da Play Store.

[IMAGEM DE CAPA: preview-desktop.jpg]

Legenda: Mesa de Truco executando no Chrome. Os dois cartões representam equipes; a marcação é manual e o placar fica salvo no dispositivo.

## 1. O que vamos aprender

Ao terminar, você deverá conseguir modelar uma partida sem depender de widgets, validar dados na entrada, salvar uma fotografia do estado e desenhar uma tela que se adapta à largura disponível. Também vamos observar como testes de domínio, widgets e integração respondem a perguntas diferentes.

O truco tem diversas variantes regionais. Nosso aplicativo preserva o escopo da aula original: marcação manual até 12 pontos, confirmação de vitória e contagem de partidas vencidas. Ele não distribui cartas nem decide o valor de uma mão. Combinem as regras na mesa e usem +1 quantas vezes forem necessárias. Em 11 × 11, o app apenas lembra de combinar a mão de ferro, sem impor regras de uma região.

## 2. Preparando o ambiente e executando

Instale o Flutter e confira o ambiente com flutter doctor. O projeto foi verificado com Flutter 3.41.9 e seu Dart 3.11.5. Para executar exatamente a implementação desta aula, clone o repositório existente:

```sh
git clone https://github.com/kleberandrade/marcador-truco-aulas-flutter.git
cd marcador-truco-aulas-flutter
flutter pub get
flutter run -d chrome
```

Você também pode abrir a pasta no VS Code, escolher Chrome e iniciar a depuração. Não crie um projeto vazio e cole somente os trechos abaixo: eles são recortes explicados do projeto completo, cujo código é a referência executável.

Em pubspec.yaml, a dependência de execução adicional é shared_preferences ^2.5.6. Flutter e flutter_test vêm do SDK; flutter_lints ^6.0.0 ajuda na análise. integration_test também vem do SDK e executa o fluxo dentro do simulador. O lockfile registra as versões resolvidas. Não use dependency_overrides para forçar dependências transitivas incompatíveis com o Flutter instalado.

## 3. Entendendo a organização

Comece por lib/domain/match.dart: ali estão os nomes, os pontos, as vitórias e as transições da partida. Depois leia lib/data/match_store.dart, que conversa com o armazenamento local. lib/views/home_page.dart coordena a interação e os diálogos; lib/widgets/team_board.dart desenha o cartão reutilizável de uma equipe. Por fim, lib/main.dart inicializa o aplicativo e o tema.

Essa separação é útil porque mudar a cor de um cartão não deve alterar quem ganhou. Da mesma forma, uma regra de pontuação pode ser testada sem abrir uma tela ou acessar o disco.

## 4. Modelando a partida antes da tela

A antiga classe Player era mutável e a lógica ficava dentro de setState. Nesta versão, Match guarda listas imutáveis de duas equipes. Uma operação devolve uma nova partida, em vez de alterar silenciosamente a anterior.

```dart
var partida = Match.initial();
partida = partida.rename(0, 'Amigos');
partida = partida.point(0, 1);
```

O índice 0 identifica a primeira equipe, e o índice 1, a segunda. O parâmetro delta aceita somente 1 ou −1. Observe o método completo de pontuação, retirado de Match:

```dart
Match point(int team, int delta) {
  RangeError.checkValidIndex(team, scores);
  if (delta != 1 && delta != -1) throw ArgumentError('Use +1 or -1');
  if (winner != null) return this;
  final s = [...scores];
  s[team] = (s[team] + delta).clamp(0, 12);
  return Match._(names, s, wins);
}
```

Há três decisões importantes. Primeiro, validamos a equipe e o delta na entrada. Depois, impedimos novos pontos enquanto uma vitória aguarda confirmação. Finalmente, clamp limita o resultado a 0–12. Desabilitar o botão −1 na tela melhora a experiência, mas o limite também precisa existir no domínio.

Experimente chamar point(0, −1) no placar inicial: o resultado continua em zero. Agora marque doze pontos e tente pontuar a outra equipe: a partida permanece bloqueada até a decisão sobre a vitória.

## 5. Vitória, cancelamento e reinício

Ao chegar a 12, winner informa qual equipe está aguardando confirmação. confirmWin soma uma vitória e devolve os dois placares a zero. cancelWin retorna o vencedor a 11, permitindo corrigir uma marcação acidental.

```dart
Match confirmWin() {
  if (winner == null) return this;
  final w = [...wins];
  w[winner!]++;
  return Match._(names, [0, 0], w);
}
```

O operador ! aqui vem depois da verificação de winner. Ele não é uma forma de ignorar dados nulos sem justificativa. A própria transição preserva os nomes e incrementa apenas a equipe vencedora.

Nova partida chama restart() e mantém as vitórias. Zerar sessão chama restart(clearWins: true) e também zera o histórico. Ambas as ações pedem confirmação. O diálogo usa barrierDismissible: false e PopScope(canPop: false), para que tocar fora ou voltar não deixe uma decisão ambígua. A tela possui botões explícitos para cancelar e confirmar.

## 6. Validando nomes e dados salvos

Ao tocar no nome de uma equipe, aparece um formulário. O nome é aparado com trim e deve ter de 1 a 24 caracteres. O mesmo validador é usado ao ler dados salvos: não confiamos em um texto só porque veio do armazenamento local.

Match.decode verifica a versão do formato, os tipos, as duas equipes, pontos entre 0 e 12, vitórias não negativas e a impossibilidade de dois vencedores simultâneos. Um arquivo inválido deve gerar erro compreensível; não deve se transformar silenciosamente em uma partida válida com dados perdidos.

## 7. Salvando e retomando a partida

MatchStore isola SharedPreferences. Salvamos uma única representação JSON sob a chave truco.match.v1, com version, names, scores e wins. Veja o serviço completo, sem imports:

```dart
class MatchStore {
  static const key = 'truco.match.v1';
  final SharedPreferences preferences;
  MatchStore(this.preferences);
  Match load() {
    final value = preferences.getString(key);
    return value == null ? Match.initial() : Match.decode(value);
  }

  Future<void> save(Match game) async {
    if (!await preferences.setString(key, game.encode())) {
      throw StateError('Save failed');
    }
  }
}
```

Enquanto salva, a interface desabilita os controles para evitar gravações concorrentes. Uma falha aparece com opção de tentar novamente. Dados inválidos são preservados até uma ação explícita de salvar ou jogar. Uma vitória pendente também é retomada quando o app é aberto novamente.

A versão de 2019 só mantinha dados em memória, portanto não existe armazenamento antigo para migrar. Para futuras mudanças de formato, escreva uma migração e testes antes de trocar a versão. SharedPreferences é adequado a esse pequeno estado local; não é um backup nem uma garantia contra falhas abruptas do dispositivo. Desinstalar o app ou limpar dados do navegador pode apagar o placar.

## 8. Desenhando os cartões e estados da tela

TeamBoard recebe a partida, a equipe e callbacks. HomePage decide quando pontuar, editar ou confirmar; o cartão apresenta nome, placar, vitórias e controles. Usamos FilledButton, OutlinedButton e TextButton, que oferecem foco e estados desabilitados. O antigo FlatButton não é usado.

A largura disponível define o arranjo: a partir de 650 pixels lógicos, os cartões ficam lado a lado; abaixo disso, ficam empilhados em uma área rolável. Os números grandes destacam o placar. O carregamento inicial e as falhas de armazenamento têm estados visíveis. A barra de progresso é decorativa e fica excluída da árvore de acessibilidade, para não agrupar indevidamente os botões.

[IMAGEM: ios-simulator.png]

Legenda: execução real no simulador iPhone 17 Pro, iOS 26.4.1. Em largura estreita, os cartões ficam empilhados; role a tela para acessar a segunda equipe e as ações de reinício.

## 9. Testando comportamento, não apenas aparência

Antes de mudar uma regra, descreva o resultado esperado. Um teste útil para o limite inferior é este exemplo didático:

```dart
test('não permite pontuação negativa', () {
  final partida = Match.initial().point(0, -1);
  expect(partida.scores, [0, 0]);
});
```

Os testes do repositório verificam limites, bloqueio com vencedor pendente, confirmação/cancelamento, reinício, validação, serialização e armazenamento. Os testes de widgets também exercitam nomes e cancelamento do reinício, além de uma tela de 390 pixels com texto ampliado a 150%.

```sh
flutter analyze
flutter test --coverage
flutter build web --no-wasm-dry-run
```

O teste integrado usa o armazenamento nativo real de um simulador de teste, remove apenas a chave desse placar e percorre edição, pontuação, vitória, reinício e reconstrução da tela. Para executá-lo, escolha o identificador do seu simulador na saída de flutter devices:

```sh
flutter devices
flutter test integration_test/scoreboard_test.dart -d IDENTIFICADOR_DO_SIMULADOR
```

## 10. Executando no simulador iOS

No macOS, configure o Xcode e inicialize um simulador. O projeto usa iOS mínimo 15. No ambiente desta atualização, Xcode 27.2 e Flutter 3.41.9 expuseram uma incompatibilidade na verificação de múltiplas arquiteturas feita por lipo. A configuração Debug.xcconfig limita somente o build Debug do simulador à arquitetura arm64 dos Macs Apple Silicon:

```text
ARCHS[sdk=iphonesimulator*] = arm64
```

Isso evita a chamada problemática com duas arquiteturas, sem modificar o SDK global e sem alterar os builds de dispositivo ou Release. Usamos arm64 explicitamente porque o Xcode iniciado como arm64e pode informar uma arquitetura nativa que o simulador não aceita. Em Macs Intel, adapte essa configuração Debug para x86_64; essa combinação não foi validada aqui. A configuração é local ao projeto e deve ser reavaliada quando o Flutter incorporar a correção. O empacotamento e a execução no simulador foram verificados; isso não equivale a validar um aparelho físico ou uma publicação na App Store.

```sh
flutter build ios --simulator --debug
flutter run -d IDENTIFICADOR_DO_SIMULADOR
```

Android continua dependendo da configuração e das licenças do SDK no computador de cada aluno. As licenças pendentes deste ambiente não foram aceitas automaticamente e não afirmamos validação em Android.

## 11. Exercícios para continuar

Primeiro, escreva um teste para cada novo comportamento. Depois escolha um exercício: exportar e restaurar uma partida com validação; criar uma migração da versão 1 para uma versão 2; oferecer uma política explícita de variantes regionais; ou manter a tela ativa com um pacote mantido e compatível. Não instale automaticamente o antigo pacote Screen citado na edição de 2019.

Para refletir: por que o domínio precisa limitar os pontos mesmo quando o botão está desabilitado? O que deve acontecer se o usuário fechar o aplicativo com a vitória pendente? Como distinguir nova partida de nova sessão sem apagar o histórico por engano?

## Código completo e créditos

O código executável, testes, comandos e limitações estão em https://github.com/kleberandrade/marcador-truco-aulas-flutter. As notas originais são de Kleber de Oliveira Andrade, de 2019; esta revisão mantém a finalidade didática e a licença MIT do repositório. As capturas são do próprio aplicativo atualizado. A versão anteriormente indicada na Play Store é histórica e separada deste código; não houve publicação nova nas lojas nesta aula.
