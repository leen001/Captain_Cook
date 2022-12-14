# Koch mit deinem Kühlschrank - Rezepte für deine Reste *(Captain Cook)*
Dokumentation für das Projekt *Captain Cook* im Rahmen des Kurses *Advanced Software Engineering* 2022 (DHBW Mannheim)
Gruppenmitglieder: Arne Kapell, Finn Callies, Irina Jörg, Akshaya Jeyaraj, Gurleen Kaur Saini
---

# Inhaltsverzeichnis
- [Gruppenmitglieder: Arne Kapell, Finn Callies, Irina Jörg, Akshaya Jeyaraj, Gurleen Kaur Saini](#gruppenmitglieder-arne-kapell-finn-callies-irina-jörg-akshaya-jeyaraj-gurleen-kaur-saini)
- [Motivation](#motivation)
- [Architektur](#architektur)
  - [Komponentendiagramm](#komponentendiagramm)
  - [Konzept: Externer ID-Provider](#konzept-externer-id-provider)
  - [Konzept: DB-Zugriff absichern](#konzept-db-zugriff-absichern)
  - [Architektur-Entscheidungen](#architektur-entscheidungen)
  - [Funktionale Anforderungen](#funktionale-anforderungen)
  - [Nicht-funktionale Anforderungen](#nicht-funktionale-anforderungen)
  - [Domain-Driven-Design](#domain-driven-design)
  - [Observability](#observability)
  - [Weitere Diagramme](#weitere-diagramme)
- [Deployment und Operations](#deployment-und-operations)
  - [Deployment](#deployment)
  - [Operations](#operations)
  - [Statischer Code-Report](#statischer-code-report)


## Motivation
---
Die grundsätzliche Motivation des Projektes besteht darin dazu beizutragen, die Lebensmittelverschwendung zu verringern. Dies erfolgt indem z. B. Rezepte vorgeschlagen werden, die auf den zu Hause verbliebenen Resten basieren, und die Menschen durch leckere Rezeptempfehlungen dazu ermutigt, diese zu verwerten.

Oft bereiten Kunden eine Mahlzeit mithilfe von Koch-Websites oder Kochbüchern zu. Doch nicht immer haben sie die benötigten Zutaten zur Hand. Daher basieren die Empfehlungen des Empfehlungssystems auf Produkten, die der Kunde entweder zu Hause im Kühlschrank und im Vorratsschrank hat oder die er gerade im örtlichen Supermarkt gekauft hat. Sollte doch einmal etwas fehlen, lassen sich einzelne Zutaten direkt auf die Einkaufsliste setzen, sodass die bereits vorhandenen optimal genutzt werden können.

## Architektur
---

### Komponentendiagramm
![Komponentendiagramm](architecture.drawio.png)

Die Architektur der Anwendung ist im oberen Diagramm dargestellt. Die Anwendung besteht aus einem Backend, welches in Python mit dem Flask-Framework implementiert wurde. Das Backend stellt eine REST-API zur Verfügung, die von einem Frontend aus genutzt wird. Das Frontend wurde dabei mit dem Flutter-Framework implementiert. Die Daten werden in einer MariaDB-Datenbank gespeichert und die Kommunikation zwischen den Komponenten erfolgt über HTTP-Requests.

Zusätzlich zu den Komponenten der Anwendung gibt es noch einen externen ID-Provider, der für die Authentifizierung der Benutzer zuständig ist. Die Kommunikation zwischen dem Frontend und dem ID-Provider erfolgt über OAuth2. Die erhaltenen Tokens werden von dem Backend für die Authentifizierung der Benutzer mit Hilfe der selben OAuth2-Schnittstelle validiert.

<!-- TODO: einzelne Komponenten genauer beschreiben -->

### Konzept: Externer ID-Provider
Wie bereits im [Komponentendiagramm](#komponentendiagramm) beschrieben, wird für die Authentifizierung der Benutzer ein externer ID-Provider verwendet. Konkret fiel die Entscheidung zu Gunsten von Google als ID-Provider aus, da hier eine große Anzahl an bereits registrierten Benutzern vorhanden ist und die Anbindung mit Hilfe bestehender Bibliotheken und Standard-Schnittstellen sehr einfach ist. Die Anbindung erfolgt über die OAuth2-Schnittstelle, die von Google bereitgestellt wird.

Im Frontend (Flutter) wird das Dart-Package [google_sign_in]([https://pub.dev/packages/google_sign_in) verwendet, um die Anmeldung zu ermöglichen und den aktuellen Status des Benutzers vorzuhalten. 
Auf der API-Seite (Flask) wird das Python-Package wird der Token aus dem Frontend überprüft und die Authentizität des Benutzers und seiner Session geprüft.

Dieses Konzept erlaubt es der Anwendung ohne eigenes Session-Management auszukommen, was den Aufwand für die Implementierung deutlich reduziert. Außerdem ist es möglich, die Anwendung mit einem bestehenden Google-Account zu nutzen, was die Anmeldung vereinfacht. Schließlich führt diese Entscheidung auch zur Reduktion der Angriffsfläche, da die Anwendung nicht selbst für die Authentifizierung der Benutzer verantwortlich ist und somit nicht selbst die Passwörter der Benutzer speichern muss.

### Konzept: DB-Zugriff absichern
Um die Datenbank von unerlaubten Zugriffen zu schützen, werden die Vorteile im Container-Umfeld genutzt. Dafür lohnt sich ein Blick in die [Definition des Docker-Stacks (für die Produktiv-Umgebung)](../docker-compose.prod.yml). Vereinfacht lässt sich sagen, dass dort zwei Netzwerke existieren: ein Stack-internes (`default`) und eines für die Kommunikation nach außen (`web`). Die Datenbank ist nur im internen Netzwerk erreichbar, sodass sie nicht von außen direkt angesprochen werden kann. Die Kommunikation zwischen dem Backend und der Datenbank erfolgt über das interne Netzwerk. 

### Architektur-Entscheidungen
*Warum Flask, Flutter und MariaDB? (Vergleich zu anderen Stacks)*
Es gibt viele Faktoren, die die Architekturentscheidungen in einem Projekt beeinflussen können, darunter die spezifischen Anforderungen des Projekts, die Fähigkeiten und Erfahrungen des Entwicklungsteams und die verfügbaren Ressourcen. Im Allgemeinen ist es jedoch wichtig, die verschiedenen Optionen sorgfältig zu berücksichtigen und die Werkzeuge und Technologien auszuwählen, die am besten für das anstehende Projekt geeignet sind.

Eine mögliche Architektur für ein Projekt könnte den Einsatz von Flutter für die Front-End, Flask für die Back-End und MariaDB für die Datenbank beinhalten.

Flutter ist ein beliebtes Open-Source-Mobile-Application-Development-Framework von Google. Es ermöglicht Entwicklern, native kompilierte Anwendungen für Mobilgeräte, Web und Desktop aus einem Codebasis zu erstellen. Flutter ist bekannt für seinen schnellen Entwicklungszyklus und seine Fähigkeit, schöne und expressive Benutzeroberflächen zu erstellen.

Flask ist ein Microweb-Framework für Python, das eine einfache Möglichkeit bietet um Webanwendungen zu erstellen. Es ist bekannt für seine Einfachheit und seine Flexibilität, wodurch es eine gute Wahl für das schnelle Entwickeln von Prototypen und die Erstellung kleiner bis mittelgroßer Webanwendungen ist. Flask verfügt desweiteren über eine große und aktive Community, mit vielen Bibliotheken und Plugins von Drittanbietern, die seine Fähigkeiten erweitern. Es wird verwendet, um eine API zu erstellen, die die Datenbank abfragt und die Daten an die App sendet, in der diese dann angezeigt werden. 

MariaDB ist ein Fork des beliebten Datenbank-Management-Systems MySQL. Es ist bekannt für seine Kompatibilität mit MySQL sowie für seine Leistung und Zuverlässigkeit. MariaDB bietet eine Vielzahl von Funktionen und Werkzeugen zur Verwaltung und Abfrage von Daten und ist daher für viele Anwendungen geeignet.

Zusammen bieten diese Technologien eine leistungsstarke und flexible Architektur für unser Projekt. Flutter kann verwendet werden, um benutzerfreundliche und ansprechende Interfaces zu erstellen. Flask bietet einen einfachen und skalierbaren Back-End und MariaDB kann als zuverlässige und leistungsstarke Datenbank dienen.

### Funktionale Anforderungen
*Use-Cases/User-Stories*
Für die funktionalen Anforderungen wurden vier Use-Cases 
definiert. Diese sind:
- Die Anwendung muss es Benutzern ermöglichen, Rezepte abzufragen.
- Die Anwendung muss es Benutzern ermöglichen, Bewertungen für Rezepte hinzuzufügen.
- Die Anwendung muss es Benutzern ermöglichen, eine Einkaufsliste zu benutzen/bearbeiten.
- Die Anwendung muss es Benutzern ermöglichen, sich an- und abzumelden.


### Nicht-funktionale Anforderungen
*Skalierbarkeit, Authorization, jeweils mit Implementierung*

### Domain-Driven-Design
*EDA (Event-Driven-Architecture), SOA (Service-Oriented-Architecture)*

### Observability
*Logging, Monitoring, Tracing*

### Weitere Diagramme
*Zustandsdiagramm: Benutzer, Sequenzdiagramm: Benutzer löschen, System-Konsistenz*

## Deployment und Operations
---

### Deployment
*Model, B&D-Pipeline*
GitHub Actions ist ein Tool von GitHub, das es Entwicklern ermöglicht, automatisierte Workflows für die Verwaltung und Bereitstellung ihres Codes zu erstellen. Mit GitHub Actions können Entwickler verschiedene Schritte in ihren Deployment-Workflows automatisieren, wie zum Beispiel das Builden, Testen und Veröffentlichen von Code.

Um Deployment mit GitHub Actions zu nutzen, müssen Entwickler zunächst einen Workflow in ihrem GitHub-Repository erstellen. Dieser Workflow besteht aus einer Reihe von Schritten, die in einer bestimmten Reihenfolge ausgeführt werden, um den Code bereitzustellen. Jeder Schritt kann dabei ein eigenes Skript oder eine Aktion von GitHub sein, die eine bestimmte Aufgabe ausführt.

Unser Deployment-Workflow mit GitHub Actions sieht wie folgt aus:

1. Code auf GitHub pushen
2. Testen des Codes mithilfe von CI Tools gefolgt von 

### Operations
*Model*

### Statischer Code-Report
*SonarQube*
SonarQube ist eine Plattform für statische Codeanalyse, die Entwicklern dabei hilft, die Qualität und Sicherheit ihres Codes zu verbessern. Es bietet eine Reihe von Werkzeugen und Plugins, die es Entwicklern ermöglichen, ihren Code auf Fehler, Schwachstellen und potenzielle Verbesserungen zu überprüfen.

SonarQube unterstützt eine Vielzahl von Programmiersprachen, darunter Java, C#, C/C++, JavaScript und viele mehr. Es bietet auch eine integrierte Oberfläche, in der Entwickler die Ergebnisse der Codeanalyse anzeigen und verstehen können.

Eines der Hauptmerkmale von SonarQube ist seine Fähigkeit, Entwicklern zu helfen, die Qualität und Zuverlässigkeit ihres Codes zu verbessern, indem es sie auffordernde Regeln und Best Practices für die Code-Entwicklung hinweist. Dies kann dazu beitragen, dass der Code sauberer, wartbarer und zuverlässiger wird.

Insgesamt ist SonarQube eine leistungsstarke Plattform für die statische Codeanalyse, die Entwicklern dabei hilft, die Qualität und Sicherheit ihres Codes zu verbessern und gleichzeitig die Effizienz ihrer Entwicklungsprozesse zu steigern.