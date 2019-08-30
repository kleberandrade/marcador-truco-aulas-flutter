import 'package:flutter/material.dart';
import 'package:marcador_truco/models/player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _playerOne = Player(name: "Nós", score: 0, victories: 0);
  var _playerTwo = Player(name: "Eles", score: 0, victories: 0);

  @override
  void initState() {
    super.initState();
    _resetPlayers();
    
  }

  void _resetPlayer({Player player, bool resetVictories = true}) {
    setState(() {
      player.score = 0;
      if (resetVictories) player.victories = 0;
    });
  }

  void _resetPlayers({bool resetVictories = true}) {
    _resetPlayer(player: _playerOne, resetVictories: resetVictories);
    _resetPlayer(player: _playerTwo, resetVictories: resetVictories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text("Marcador Pontos (Truco!)"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _showDialog(
                  title: 'Zerar',
                  message:
                      'Tem certeza que deseja começar novamente a pontuação?',
                  confirm: () {
                    _resetPlayers();
                  });
            },
            icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: Container(padding: EdgeInsets.all(20.0), child: _showPlayers()),
    );
  }

  Widget _showPlayerBoard(Player player) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _showPlayerName(player.name),
          _showPlayerScore(player.score),
          _showPlayerVictories(player.victories),
          _showScoreButtons(player),
        ],
      ),
    );
  }

  Widget _showPlayers() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _showPlayerBoard(_playerOne),
        _showPlayerBoard(_playerTwo),
      ],
    );
  }

  Widget _showPlayerName(String name) {
    return Text(
      name.toUpperCase(),
      style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: Colors.deepOrange),
    );
  }

  Widget _showPlayerVictories(int victories) {
    return Text(
      "vitórias ( $victories )",
      style: TextStyle(fontWeight: FontWeight.w300),
    );
  }

  Widget _showPlayerScore(int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52.0),
      child: Text(
        "$score",
        style: TextStyle(fontSize: 120.0),
      ),
    );
  }

  Widget _buildRoundedButton(
      {String text, double size = 52.0, Color color, Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: Container(
          color: color,
          height: size,
          width: size,
          child: Center(
              child: Text(
            text,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }

  Widget _showScoreButtons(Player player) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildRoundedButton(
          text: '-1',
          color: Colors.black.withOpacity(0.1),
          onTap: () {
            setState(() {
              player.score--;
            });
          },
        ),
        _buildRoundedButton(
          text: '+1',
          color: Colors.deepOrangeAccent,
          onTap: () {
            setState(() {
              player.score++;
            });

            if (player.score == 12) {
              _showDialog(
                  title: 'Fim do jogo',
                  message: '${player.name} ganhou!',
                  confirm: () {
                    setState(() {
                      player.victories++;
                    });

                    _resetPlayers(resetVictories: false);
                  },
                  cancel: () {
                    setState(() {
                      player.score--;
                    });
                  });
            }
          },
        ),
      ],
    );
  }

  void _showDialog(
      {String title, String message, Function confirm, Function cancel}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
                if (cancel != null) cancel();
              },
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (confirm != null) confirm();
              },
            ),
          ],
        );
      },
    );
  }
}
