# Criando um marcador de truco em Flutter

## Notas de aula do prof. Kleber de Oliveira Andrade

[CAPA: medium-cover.png]

Capa editorial criada com auxílio de IA para esta aula. As figuras do aplicativo abaixo são capturas reais; a ilustração de capa não representa uma tela nem funcionalidades adicionais.

Nesta aula, vamos construir e explorar o Mesa de Truco: um marcador local para duas equipes, com nomes editáveis, pontos de 0 a 12 e histórico de vitórias da sessão. O objetivo é aprender a separar regras, armazenamento e interface em um aplicativo pequeno, que você consegue testar.

Esta é a atualização das notas publicadas em 2019. Usaremos Flutter 3.50.0, Dart 3.14.0 com null safety e Material 3. O endereço e a autoria da aula continuam os mesmos; as imagens mostram a implementação atual, não a antiga versão da Play Store.

[IMAGEM WEB: preview-desktop.jpg]

Legenda: Mesa de Truco executando no Chrome. Os dois cartões representam equipes; a marcação é manual e o placar fica salvo no dispositivo.

## 1. O que vamos aprender

Ao terminar, você deverá conseguir modelar uma partida sem depender de widgets, validar dados na entrada, salvar uma fotografia do estado e desenhar uma tela que se adapta à largura disponível. Também vamos observar como testes de domínio, widgets e integração respondem a perguntas diferentes.

O truco tem diversas variantes regionais. Nosso aplicativo preserva o escopo da aula original: marcação manual até 12 pontos, confirmação de vitória e contagem de partidas vencidas. Ele não distribui cartas nem decide o valor de uma mão. Combinem as regras na mesa e usem +1 quantas vezes forem necessárias. Em 11 × 11, o app apenas lembra de combinar a mão de ferro, sem impor regras de uma região.

## 2. Preparando o ambiente e executando

Pré-requisitos: classes, listas, funções, Future e widgets básicos. Reserve uma pasta de laboratório e um simulador descartável para o teste integrado. Instale ou selecione o Flutter indicado e confira o ambiente com flutter doctor. O arquivo .fvmrc fixa 3.50.0 para quem usa FVM; ele não muda automaticamente o comando flutter do terminal. Confirme flutter --version antes de resolver as dependências. O projeto foi verificado com Flutter 3.50.0 e seu Dart 3.14.0. Para executar exatamente a implementação desta aula, clone o repositório existente:

```sh
git clone https://github.com/kleberandrade/marcador-truco-aulas-flutter.git
cd marcador-truco-aulas-flutter
flutter --version
flutter pub get
flutter run -d chrome
```

Você também pode abrir a pasta no VS Code, escolher Chrome e iniciar a depuração. Não crie um projeto vazio e cole somente os trechos abaixo: eles são recortes explicados do projeto completo, cujo código é a referência executável.

O projeto usa shared_preferences ^2.5.6 para o pequeno estado local e material_ui ^1.11.1 para os componentes Material. No Flutter 3.50, importe package:material_ui/material_ui.dart no lugar do antigo package:flutter/material.dart, que foi descontinuado. Flutter, flutter_test e integration_test vêm do SDK; flutter_lints ^6.0.0 orienta a análise estática. A versão do app é 2.1.0+3; Flutter 3.50.0 e Dart 3.14.0 são versões das ferramentas, não do aplicativo.

O upgrade do SDK liberou as dependências transitivas antes bloqueadas. Duas versões ainda são fixadas pelo SDK: material_color_utilities e test_api. O manifesto adota overrides exatos 0.13.1 e 0.7.15, respectivamente, somente após análise, testes e builds nesta combinação. Um override altera a resolução; não prova compatibilidade sozinho. O primeiro participa das cores do tema, e o segundo, da infraestrutura dos testes. Ao trocar SDK ou versão desses pacotes, repita as validações e remova os overrides quando as restrições oficiais permitirem. Não aplique esse bloco automaticamente em outros projetos.

```sh
flutter pub outdated
flutter pub upgrade --major-versions
flutter pub outdated --no-dependency-overrides
```

O relatório com overrides mostra as versões selecionadas; o diagnóstico sem overrides mostra o que o SDK permitiria sem a exceção. Preserve pubspec.lock para reproduzir o laboratório. Atualizações futuras precisam passar novamente pelos testes, e não apenas terminar o download.

Checkpoint: a tela deve apresentar duas equipes e botões +1. Em tela estreita, role para ver a segunda equipe. O contador deve começar em zero quando ainda não existir partida salva.

## 3. Entendendo a organização

Comece por lib/domain/match.dart: ali estão os nomes, os pontos, as vitórias e as transições da partida. Depois leia lib/data/match_store.dart, que conversa com o armazenamento local. lib/views/home_page.dart coordena a interação e os diálogos; lib/widgets/team_board.dart desenha o cartão reutilizável de uma equipe. Por fim, lib/main.dart inicializa o aplicativo e o tema.

A leitura recomendada é domínio → armazenamento → cartão → tela → inicialização. Ao estudar cada arquivo, identifique o dado que entra, o resultado que sai e quem trata uma falha. Essa separação é útil porque mudar a cor de um cartão não deve alterar quem ganhou. Da mesma forma, uma regra de pontuação pode ser testada sem abrir uma tela ou acessar o disco.

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

Checkpoint de domínio: point(0, -1) no placar inicial mantém [0, 0]; doze chamadas point(0, 1) produzem [12, 0]; uma décima terceira chamada não altera o resultado. point(0, 3) é rejeitado: os botões atuais marcam um ponto por vez. Agora marque doze pontos e tente pontuar a outra equipe: a partida permanece bloqueada até a decisão sobre a vitória.

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

O operador ! aqui vem depois da verificação de winner. Ele não é uma forma de ignorar dados nulos sem justificativa. A própria transição preserva os nomes e incrementa apenas a equipe vencedora. Checkpoint: em [12, 8], cancelar deve produzir [11, 8] sem somar vitória; confirmar deve produzir [0, 0] e incrementar somente a primeira equipe. Confirmar de novo, sem vencedor pendente, não deve somar outra vitória.

Nova partida chama restart() e mantém as vitórias. Zerar sessão chama restart(clearWins: true) e também zera o histórico. Ambas as ações pedem confirmação. O diálogo usa barrierDismissible: false e PopScope(canPop: false), para que tocar fora ou voltar não deixe uma decisão ambígua. A tela possui botões explícitos para cancelar e confirmar.

## 6. Validando nomes e dados salvos

Ao tocar no nome de uma equipe, aparece um formulário. O nome é aparado com trim e deve ter de 1 a 24 caracteres. Experimente um nome com apenas espaços: o formulário deve manter o diálogo aberto e explicar o limite. O mesmo validador é usado ao ler dados salvos: não confiamos em um texto só porque veio do armazenamento local.

Match.decode verifica a versão do formato, os tipos, as duas equipes, pontos entre 0 e 12, vitórias não negativas e a impossibilidade de dois vencedores simultâneos. Um arquivo inválido deve gerar erro compreensível; não deve se transformar silenciosamente em uma partida válida com dados perdidos.

## 7. Salvando e retomando a partida

MatchStore isola SharedPreferences. Salvamos uma única representação JSON sob a chave truco.match.v1, com version, names, scores e wins. Leia o serviço completo, com os imports necessários:

```dart
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/match.dart';

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

Enquanto salva, a interface desabilita os controles para evitar gravações concorrentes. Uma falha aparece com opção de tentar novamente. Dados inválidos são preservados até uma ação explícita de salvar ou jogar. Uma vitória pendente também é retomada quando o app é aberto novamente. Para acompanhar o caminho completo: o botão chama point; HomePage recebe a nova Match, atualiza a tela e aguarda MatchStore.save; ao iniciar, MatchStore.load valida o JSON antes de entregar a partida à tela. Um aviso de falha de gravação significa que a alteração pode existir apenas na sessão atual.

A versão de 2019 só mantinha dados em memória, portanto não existe armazenamento antigo para migrar. Para futuras mudanças de formato, escreva uma migração e testes antes de trocar a versão. SharedPreferences é adequado a esse pequeno estado local; não é um backup nem uma garantia contra falhas abruptas do dispositivo. Desinstalar o app ou limpar dados do navegador pode apagar o placar.

## 8. Desenhando os cartões e estados da tela

TeamBoard recebe a partida, a equipe e callbacks. HomePage decide quando pontuar, editar ou confirmar; o cartão apresenta nome, placar, vitórias e controles. Usamos FilledButton, OutlinedButton e TextButton, que oferecem foco e estados desabilitados. O antigo FlatButton não é usado.

A largura disponível define o arranjo: a partir de 650 pixels lógicos, os cartões ficam lado a lado; abaixo disso, ficam empilhados em uma área rolável. Os números grandes destacam o placar. O carregamento inicial e as falhas de armazenamento têm estados visíveis. Checkpoint de interface: navegue pelos controles por teclado na Web, tente diminuir zero e amplie o texto. O número deve continuar legível e os controles devem permanecer alcançáveis por rolagem. A barra de progresso é decorativa e fica excluída da árvore de acessibilidade, para não agrupar indevidamente os botões.

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

Para rodar o exemplo isolado, importe flutter_test e package:marcador_truco/domain/match.dart em um arquivo dentro de test/. O teste chama uma operação e compara o efeito observável; não precisa abrir a tela nem usar SharedPreferences. Os testes do repositório verificam limites, bloqueio com vencedor pendente, confirmação/cancelamento, reinício, validação, serialização e armazenamento. Os testes de widgets também exercitam nomes e cancelamento do reinício, além de uma tela de 390 pixels com texto ampliado a 150%.

```sh
flutter analyze
flutter test --coverage
flutter build web --no-wasm-dry-run
```

No laboratório verificado, os sete testes locais e o teste integrado passaram. Os testes de armazenamento locais usam dados controlados; não gravam a partida pessoal do usuário. O teste integrado usa o armazenamento nativo real de um simulador de teste, remove apenas a chave desse placar e percorre edição, pontuação, vitória, reinício e reconstrução da tela. Para executá-lo, escolha o identificador do seu simulador na saída de flutter devices:

```sh
flutter devices
flutter test integration_test/scoreboard_test.dart -d IDENTIFICADOR_DO_SIMULADOR
```

## 10. Executando no simulador iOS

No macOS, configure o Xcode e inicialize um simulador. O projeto usa iOS mínimo 15. No ambiente desta atualização, Xcode 27.2 e Flutter 3.50.0 expuseram uma incompatibilidade na verificação de múltiplas arquiteturas feita por lipo. A configuração Debug.xcconfig limita somente o build Debug do simulador à arquitetura arm64 dos Macs Apple Silicon:

```text
ARCHS[sdk=iphonesimulator*] = arm64
```

Isso evita a chamada problemática com duas arquiteturas, sem modificar o SDK global e sem alterar os builds de dispositivo ou Release. Usamos arm64 explicitamente porque o Xcode iniciado como arm64e pode informar uma arquitetura nativa que o simulador não aceita. Em Macs Intel, adapte essa configuração Debug para x86_64; essa combinação não foi validada aqui. A configuração é local ao projeto e deve ser reavaliada quando o Flutter incorporar a correção. O empacotamento e o fluxo integrado no simulador foram verificados novamente com as dependências atualizadas; isso não equivale a validar um aparelho físico ou uma publicação na App Store.

```sh
flutter build ios --simulator --debug
flutter run -d IDENTIFICADOR_DO_SIMULADOR
```

O APK Android debug também compilou nesta combinação, depois de alinhar os arquivos Gradle ao template Flutter 3.50 (Gradle 9.5.0 e Android Gradle Plugin 9.3.1). A compilação não equivale a testar interação no Android: não executamos esse alvo em telefone ou emulador nesta revisão. Algumas licenças continuam pendentes no ambiente e não foram aceitas automaticamente. No iOS, o projeto mantém o Podfile personalizado e a configuração Swift Package Manager adicionada pelo migrador; esse arranjo compilou e executou o teste integrado, embora o Flutter ainda sugira concluir a migração manual para remover CocoaPods.

## Código completo e créditos

O código executável, testes, comandos e limitações estão em https://github.com/kleberandrade/marcador-truco-aulas-flutter. As notas originais são de Kleber de Oliveira Andrade, de 2019; esta revisão mantém a finalidade didática e a licença MIT do repositório. A capa foi criada com auxílio de IA em estilo editorial; as capturas são do próprio aplicativo atualizado. A referência visual da série é a aula Consultando CEPs com Flutter: https://medium.com/flutter-comunidade-br/consultando-ceps-com-flutter-a395b86ce34a. As decisões de pontuação, persistência e interface deste texto correspondem ao código deste projeto. A versão anteriormente indicada na Play Store é histórica e separada deste código; não houve publicação nova nas lojas nesta aula.


## 11. Cinco exercícios para evoluir o projeto

Os cinco desafios abaixo ainda não estão implementados. Faça cada um em uma branch separada a partir da versão desta aula. Primeiro escreva um teste que falha pelo comportamento ausente; depois implemente a menor solução e execute a suíte completa. Entregue o código, os testes e um registro do resultado observado. Não marque como concluído só porque a tela mudou.

### 1. Tema claro, escuro e do sistema

Objetivo: praticar estado de apresentação sem alterar as regras da partida. Comece em TrucoApp e crie um seletor de ThemeMode com rótulos acessíveis; mantenha a configuração em um serviço próprio, separado do JSON da partida. Preserve nomes, pontos e vitórias ao trocar o tema. Critérios de entrega: os três modos funcionam por teclado, os placares e botões têm contraste legível e a preferência volta após reiniciar. Testes: alternar com uma partida 11–8 em andamento não muda Match; uma preferência salva inválida usa o modo do sistema. Registre capturas nos temas claro e escuro.

### 2. Exportar e restaurar uma partida com segurança

Objetivo: trabalhar a fronteira entre dados externos e domínio. Reutilize Match.encode/decode; ofereça exportação do JSON e uma prévia antes de substituir a partida atual. Para começar, use texto selecionável e um campo de importação, sem depender de seletor de arquivos. Critérios de entrega: importar uma partida válida preserva nomes, pontos e vitórias; cancelar mantém o estado original; JSON malformado, versão desconhecida ou dois vencedores não alteram o armazenamento. Testes: round-trip de docs/example-match.json, importação de [12, 8] retomando a confirmação e falha ao salvar comunicada ao usuário. Não sobrescreva dados antes de validar e confirmar.

### 3. Desfazer a última marcação de ponto

Objetivo: modelar histórico sem misturar UI e pontuação. Acrescente uma operação de domínio para desfazer somente o último +1 ou -1 efetivo da partida atual. Uma tentativa de diminuir zero não deve criar histórico. Para manter o exercício delimitado, limpe o histórico ao confirmar vitória ou reiniciar; não desfaça vitórias já confirmadas. Critérios de entrega: o botão só está habilitado quando existe ação reversível e não interfere no diálogo de vitória pendente. Testes: 8 → 9 → desfazer retorna a 8; diminuir zero continua em zero; após reinício ou vitória confirmada, desfazer fica indisponível. Declare se o histórico é apenas da sessão ou também persistido e teste essa escolha.

### 4. Evoluir o formato salvo sem perder a versão 1

Objetivo: escrever uma migração, em vez de simplesmente trocar uma chave. Crie um formato versão 2 acrescentando um identificador de sessão. Mantenha um leitor de versão 1 e transforme os dados com uma função pura; use uma fixture real do formato atual. Critérios de entrega: a primeira leitura migra sem perder nomes, pontos, vitórias nem vencedor pendente; executar a migração de novo não duplica dados; versão futura desconhecida permanece preservada. Testes: versão 1 → 2, abertura repetida, dado inválido e falha de gravação mantendo o registro antigo. Só remova a chave antiga depois de confirmar a gravação da nova representação.

### 5. Manter a tela ativa com controle do usuário

Objetivo: integrar um recurso de plataforma com ciclo de vida e testes. Escolha um pacote mantido, confira a compatibilidade com o SDK desta aula e isole suas chamadas atrás de uma interface injetável. Ofereça uma opção explícita para manter a tela ativa durante a partida; não reutilize automaticamente o antigo pacote Screen. Critérios de entrega: ativar/desativar funciona nas plataformas escolhidas, falhas recebem mensagem clara e o recurso é liberado ao encerrar seu uso. Testes: use uma implementação falsa para verificar habilitação, desabilitação e descarte; depois valide em um emulador ou dispositivo suportado, registrando a plataforma e os limites. Não apresente um teste falso como prova do comportamento nativo.
