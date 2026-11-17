# Revisão preparada — Criando um marcador de truco em Flutter

Artigo: https://medium.com/flutter-comunidade-br/criando-um-marcador-de-truco-em-flutter-e50669f21f03
Autor: Kleber Andrade. Publicação original: 26/08/2019.

Lido no Chrome em 17/11/2026. A página oferece Sign in/Sign up, sem sessão editorial; nenhuma alteração foi publicada. O endereço curto http://bit.ly/2MDO6ww redireciona para esse artigo. Preservar título, autoria, publicação, URL e introdução histórica original. Substituir as seções técnicas abaixo; manter os créditos e o link do código. A referência ao aplicativo da Play Store deve ser identificada como versão histórica separada, sem afirmar que esta atualização foi publicada na loja.

## Criando e executando o projeto

Estas notas foram atualizadas para Flutter 3.41.9 e Dart 3.11.5 com null safety. Para acompanhar a implementação completa:

```sh
git clone https://github.com/kleberandrade/marcador-truco-aulas-flutter.git
cd marcador-truco-aulas-flutter
flutter pub get
flutter run -d chrome
```

A atualização do aplicativo foi enviada à branch master do repositório. No VS Code, escolha Chrome para executar a aplicação. Android exige licenças e configuração de SDK próprias; iOS exige Xcode. Esta revisão foi executada na Web, sem alegação de teste em celular.

## Estrutura do projeto

A antiga classe Player mutável foi substituída por Match em `lib/domain/match.dart`. A partida contém duas listas imutáveis de nomes, pontos e vitórias. Há exatamente duas equipes. `validName` valida nomes na entrada; `decode` valida versão, tipos, limites e impede dois vencedores ao carregar dados externos.

```dart
var partida = Match.initial();
partida = partida.rename(0, 'Amigos');
partida = partida.point(0, 1);
```

`point` aceita somente +1 ou −1, limita pontos a 0–12 e bloqueia alterações quando há vencedor pendente. Ao confirmar a vitória, `confirmWin` soma uma vitória e zera ambos os placares. `cancelWin` devolve o vencedor a 11; `restart` preserva vitórias, ou as apaga quando `clearWins: true`.

## Persistência e programa principal

O `pubspec.yaml` usa Dart >=3.11.0 <4.0.0, Flutter e `shared_preferences: ^2.5.4` (lockfile verificado resolve 2.5.6). As ferramentas de desenvolvimento são flutter_test e flutter_lints ^6.0.0. Não precisamos de cupertino_icons nem do antigo plugin Screen.

`main.dart` chama `WidgetsFlutterBinding.ensureInitialized()` e abre `TrucoApp`. A inicialização de SharedPreferences aparece com indicador de carregamento ou erro. `MatchStore` grava JSON versionado na chave `truco.match.v1`; nomes, pontos e vitórias são retomados. A versão original não persistia dados, portanto não há arquivo antigo para converter. Dados inválidos geram aviso e permanecem armazenados até uma ação explícita do usuário.

## Classe HomePage

A tela usa Material 3, cartões de equipe com pontos grandes, progresso até 12, nomes editáveis e controles OutlinedButton/FilledButton. Em telas estreitas os cartões ficam empilhados; em telas largas ficam lado a lado. A lógica de pontuação fica no domínio; a tela coordena diálogos e salvamento.

Substitua os antigos FlatButton por TextButton ou FilledButton. Botões Material oferecem foco de teclado e estados desabilitados; GestureDetector sozinho não oferece essas características. A confirmação de vitória/reinício usa `showDialog<bool>` com `barrierDismissible: false` e `PopScope(canPop: false)` para exigir decisão explícita.

Durante gravação, os controles ficam desabilitados para impedir escritas concorrentes. Falhas de gravação aparecem na tela com opção de tentar salvar novamente. Ao chegar a 12, a confirmação é retomada mesmo se o app tiver sido fechado antes da decisão.

## Resultado e verificação

```sh
flutter analyze
flutter test --coverage
flutter build web
```

Os testes cobrem limites, vitória, cancelamento, reinício, validação, persistência e interação dos widgets. É um marcador manual até 12; não misturamos automaticamente variantes regionais de truco. A indicação de 11–11 lembra a mesa de combinar regras da mão de ferro.

## Desafios atualizados

Limites, reinício preservando vitórias, confirmação modal e edição de nomes já estão implementados. Como exercícios adicionais, implemente uma política explícita de variantes regionais, exportação/restauração com migração de esquema e tela sempre ativa usando um plugin mantido e compatível. Não use automaticamente o antigo pacote Screen destas notas. Teste cada comportamento novo antes de integrá-lo.
