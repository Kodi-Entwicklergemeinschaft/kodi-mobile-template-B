import 'package:flutter/material.dart';

class NetiquetteScreen extends StatelessWidget {
  const NetiquetteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Netiquette'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: RichText(
                    text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium!,
                        children: const [
                          TextSpan(
                              text:
                                  '• Wir sind gemeinsam für eine gute Kommunikation verantwortlich. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Tragen Sie Ihren Teil dazu bei und nehmen Sie es ernst, so wie wir es tun.\n'),
                          TextSpan(
                              text: '• Wir alle sind Menschen. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Auf der anderen Seite des Bildschirms befindet sich eine Person, deren Einschätzung ihrer Sicht auf die Welt sich genauso richtig anfühlt, wie Ihre.\n'),
                          TextSpan(
                              text: '• Wir sind authentisch. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Verstecken Sie sich nicht hinter Anonymität, benutzen Sie wenn möglich Ihren richtigen Namen. Bitte dennoch keine persönlichen Informationen, Telefonnummern oder Werbung in der öffentlichen Kommunikation.\n'),
                          TextSpan(
                              text: '• Wir sind konstruktiv. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Es ist besser, mit klarem Kopf zu schreiben. Intensive Gefühle können ein starker Antrieb sein, aber sie helfen selten, auf Distanz gut zu kommunizieren.\n'),
                          TextSpan(
                              text: '• Wir hinterfragen uns selbst. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Lesen Sie immer noch einmal selbstkritisch durch, was Sie geschrieben haben und versuchen Sie sich in die Lage einer Person mit einer anderen Perspektive zu versetzen.\n'),
                          TextSpan(
                              text: '• Wir sind verständlich. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Vermeiden Sie bitte Zynismus, Ironie und Sarkasmus - das alternative Modell ist Klarheit.\n'),
                          TextSpan(
                              text: '• Wir sind wertschätzend. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Diskriminierung, sexistische oder rassistische Parolen machen unsere Welt nur schlimmer. Verwenden Sie bitte auch keine Schimpfwörter, Abwertungen, Klischees und Verallgemeinerungen.\n'),
                          TextSpan(
                              text: '• Wir sind wohlwollend. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Eine Alternative zur negativen Eskalationsspirale besteht immer darin, ein wenig wohlwollender als Ihr Gegenüber zu kommunizieren.\n'),
                          TextSpan(
                              text: '• Wir sind ehrlich. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Wenn Sie etwas zitieren, machen Sie es deutlich erkennbar und beziehen Sie sich auf die Autorin bzw. den Autor.\n'),
                          TextSpan(
                              text: '• Wir sind privat unterwegs. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Nutzen Sie die News und Gruppen nicht für Werbung (kommerzieller oder politischer Art). Eine Ausnahme bilden Inhalte der Kategorie „Suche & Biete“.\n'),
                          TextSpan(
                              text: '• Wir sind fair. ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'Jede Person hat die Möglichkeit zu kommunizieren. Um aber allen die gleichen Möglichkeiten zu geben, schreibt den gleichen Kommentar nicht mehrfach. Deine Meinung ist wichtig, aber die der anderen auch. #bleibtfair\n'),
                        ]),
                  )),
              RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium!,
                    children: const [
                      TextSpan(
                          text:
                              "Beiträge, die diese Regeln absichtlich missachten, wird von der Plattform ausgeschlossen. Unsere Admins wurden von den Ortsvertretungen der Ortschaften selbst gewählt. Sie sind berechtigt Beiträge und Gruppen freizugeben und im Falle von Fehlern, auf diese hinzuweisen und um Änderung zu bitten, bspw. die Angabe einer falschen Ortschaft in einem Beitrag, etc. Die Admins sind zudem berechtigt Beiträge von der Veröffentlichung auszuschließen, wenn diese der Netiquette wiedersprechen.\n"),
                      TextSpan(
                          text:
                              "Die Admins können nur Beiträge und Gruppen in ihren eignen Ortschaften freischalten. Soll ein Beitrag in mehreren Ortschaften sichtbar sein, so muss er von allen betroffenen Administratoren genehmigt werden.\n"),
                      TextSpan(
                          text:
                              "News mit der Kategorie „Eilmeldung“ sind lediglich für dringende Informationen durch die Ortschaftsvertretungen, die Bürgermeisterin, die Feuerwehr, die Polizei zu veröffentlichten. Im Falle dieser Nachrichten erhalten die User eine Push-Nachricht – wenn diese aktiviert wurde. Alle Inhaber:innen von Gruppen sind dazu aufgerufen, sich ebenfalls an die Richtlinien der Netiquette zu halten und für deren Einhaltung zu sorgen. Ausnahmen sind natürlich nicht ausgeschlossen."),
                    ]),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
