[![Deploy to VPS](https://github.com/leen001/Captain_Cook/actions/workflows/deploy.yml/badge.svg)](https://github.com/leen001/Captain_Cook/actions/workflows/deploy.yml)
# Koch mit deinem Kühlschrank - Rezepte für deine Reste *(Captain Cook)*
Dokumentation für das Projekt *Captain Cook* im Rahmen des Kurses *Advanced Software Engineering* 2022 (DHBW Mannheim)
Gruppenmitglieder: Arne Kapell, Finn Callies, Irina Jörg, Akshaya Jeyaraj, Gurleen Kaur Saini
---

# Inhaltsverzeichnis
- [Gruppenmitglieder: Arne Kapell, Finn Callies, Irina Jörg, Akshaya Jeyaraj, Gurleen Kaur Saini](#gruppenmitglieder-arne-kapell-finn-callies-irina-jörg-akshaya-jeyaraj-gurleen-kaur-saini)
- [Motivation](#motivation)
  - [Akteure](#akteure)
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
    - [Build \& Deployment Pipeline](#build--deployment-pipeline)
  - [Operations](#operations)
  - [Statischer Code-Report](#statischer-code-report)


## Motivation
---
Die grundsätzliche Motivation des Projektes besteht darin dazu beizutragen, die Lebensmittelverschwendung zu verringern. Dies erfolgt indem z. B. Rezepte vorgeschlagen werden, die auf den zu Hause verbliebenen Resten basieren, und die Menschen durch leckere Rezeptempfehlungen dazu ermutigt, diese zu verwerten.

Oft bereiten Kunden eine Mahlzeit mithilfe von Koch-Websites oder Kochbüchern zu. Doch nicht immer haben sie die benötigten Zutaten zur Hand. Daher basieren die Empfehlungen des Empfehlungssystems auf Produkten, die der Kunde entweder zu Hause im Kühlschrank und im Vorratsschrank hat oder die er gerade im örtlichen Supermarkt gekauft hat. Sollte doch einmal etwas fehlen, lassen sich einzelne Zutaten direkt auf die Einkaufsliste setzen, sodass die bereits vorhandenen optimal genutzt werden können.

### Akteure

Die Architekten entscheiden über Designs und neue Funktionen des Produkts, die in Zukunft die Anwendung 
erweitern.

Die Programmierer setzten die Design und Funktionsvorschläge auf die sich die Architekten geeinigt 
haben in Code um.

Die Endnutzer sind die tatsächliche Zielgruppe der Anwendung und interagieren mit dieser um die 
veröffentlichten Funktionen für sich zu verwenden. Hier kann in zwei Arten unterscheiden werden:
  
  1. Nutzer die lediglich den öffentlichen Teil der Anwendung (Rezeptsuche) verwenden
  2. Nutzer die eine Einkaufsliste verwalten möchten und sich hierzu mit einem Google Konto authentifizieren müssen

Google OAuth und öffentliche API zur Token Validierung

Hosting Service (VPS) damit die Anwendung im Internet über eine Webadresse erreichbar ist wird 

Die Datenbank speichert alle Daten und stellt diese wenn nötig dem Nutzer über die API und das Frontend
zur Verfügung. In diesem Fall handelt es sich um eine MariaDB.

Die API ist die Schnittstelle zwischen dem vom Nutzer verwendeten UI und der Datenbank um Eingaben des 
Nutzers in dieser zu speichern und bei Gelegenheit wieder aus der Datenbank abzurufen.

??? GitHub Actions, SonarQube ???

<!-- TODO -->

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

Die genutzen Container-Technologien ermöglichen ein einfaches Skalieren von UI und API. 
Mit MariaDB Entwerprise ist die Anzahl der Kerne, der Arbeitsspeicher und die Speicherkapazität leicht zu erhöhen.
Um eine horizontale Skalierung zu gewährleisten können auch mehrere Instanzen genutzt werden.
Das nicht vorhandene Budget für dieses Projekt verhindert allerdings den Einsatz einer MariaDB Enterprise Lizenz.

MariaDB ist eine Open-Source-Datenbank, die skalierbar ist, indem sie die Verwendung von Clustering und Replikation ermöglicht, um die Leistung und Verfügbarkeit zu verbessern. Dies bedeutet, dass MariaDB in der Lage ist, Daten auf mehreren Servern zu speichern und zu verarbeiten, um die Belastung zu verteilen und die Leistung zu erhöhen.

Flask ist ein leichtgewichtiges Web-Framework für Python, das skalierbar ist, indem es die Verwendung von Front-End-Caching und Load Balancing ermöglicht. Dies bedeutet, dass Flask in der Lage ist, die Last auf mehrere Server zu verteilen und gecachte Daten zu verwenden, um die Leistung zu verbessern.

Flutter ist ein Open-Source-Framework für die Entwicklung von mobilen Anwendungen, das skalierbar ist, indem es die Verwendung von Hot Reload und Hot Restart ermöglicht. Dies bedeutet, dass Flutter in der Lage ist, schnell Änderungen im Code zu übernehmen und die Anwendung ohne Verlust des Zustands neu zu starten, wodurch die Entwicklungszeit verkürzt und die Leistung verbessert wird.

Insgesamt sind MariaDB, Flask und Flutter in der Lage, in einem Container skaliert zu werden, indem verschiedene Techniken und Funktionen verwendet werden, um die Leistung und Verfügbarkeit zu verbessern. Die genauen Details und Möglichkeiten hängen jedoch von der spezifischen Implementierung und den Anforderungen der Anwendung ab.

Um registrierten Nutzern eine Datensichherheit zu bieten wird HTTPS für für Basis-Verschlüsselung zwischen Client und Server (UI und API) genutzt.
Um weitere (Web-)Schwachstellen abzudecken, soll sich an der OWASP Top 10 als Katalog orientiert.
  
Eine weitere wichtige Nicht-funktionale Anforderung ist die Benutzerfreundlichkeit. Diese soll durch eine intuitive, einfache und übersichtliche UI umgesetzt werden. Daraus resultierend soll auch der Funktionsumfang auf das minimale beschränlkt werden.

Ausfallsicherheit und Redundanz ist über Backups sowie Notfall-Instanzen der Datenbank abgedeckt, falls die Haupt Instanz ausfallen sollte. 
### Domain-Driven-Design
*EDA (Event-Driven-Architecture), SOA (Service-Oriented-Architecture)*
![Domain-Driven-Design](domain-driven.drawio.png)

### Observability
*Logging, Monitoring, Tracing*
Das Logging wird mithilfe von Docker Compose realisiert. Dabei werden logs von  den einzelnen services gesammelt.
Prometheus ist ein Open-source Tool das zum
Jaeger
logstash
Beobachtet werden sollen zusätzlich die Antwortzeiten der Service

### Weitere Diagramme
*Zustandsdiagramm: Benutzer*
![Zustandsdiagramm](StatusDiagramUser.drawio.png) 

*Sequenzdiagramm: Benutzer löschen ,System-Konsistenz*
![Aktivitätsdiagramm](ActivityDiagramUser.drawio.png)

Zur  Erhaltung der Konsistenz bei der Entfernung eines Benutzers werden Datenbank Einträge gelöscht. Dabei sind Komponenten wie die Einkaufsliste oder Bewertungen von der Enfernung des Users betroffen. Da die Einkaufsliste nicht zwischne Usern geteilt wird, bleibt bei der Löschung dieser die Konsistenz erhalten. Bei  Bewertungen werden Ersteller durch "Entfernter Benutzer" ersetzt um eine sauber Trennung zu ermöglichen.
## Deployment und Operations
---

### Deployment
Für das Deployment haben wir uns für einen VPS als Zielumgebung entschieden. Ein VPS (Virtual Private Server) ist ein virtueller Server, der in einer Cloud-Umgebung betrieben wird. Im Gegensatz zu einem physischen Server teilt sich ein VPS eine Hardware-Infrastruktur mit anderen VPS, wodurch er kostengünstiger und flexibler ist. Ein VPS bietet die Leistung und Kontrolle eines dedizierten Servers, ist aber weniger teuer und einfacher zu verwalten.

Beim Deployment der Anwendung auf einem VPS wird die Anwendung zunächst auf einem lokalen Entwicklungssystem entwickelt und getestet (siehe [docker-compose.yml](../docker-compose.yml)). Sobald die Anwendung bereit ist, wird sie auf den VPS hochgeladen und dort installiert. Der VPS bietet eine gesicherte und isolierte Umgebung, in der alle Komponenten der App betrieben werden können. Die Anwendung kann dann über das Internet von jedem Endgerät aus aufgerufen werden.

Um die einzelnen Services (Frontend, API, Datenbank) gemeinsam zu starten, verwenden wir Docker-Compose. Docker-Compose ist ein Tool, das es Entwicklern ermöglicht, mehrere Docker-Container zu starten und zu verwalten. Docker-Compose verwendet dabei eine Konfigurationsdatei, in der die einzelnen Container definiert werden. Auf diese Weise wird das Deployment der Anwendung vereinfacht und beschleunigt.
#### Build & Deployment Pipeline
Die Build & Deployment Pipeline für dieses Projekt wurde mit Hilfe von GitHub Actions realisiert. GitHub Actions ist ein Tool, mit dem man automatisierte Workflows erstellen kann, die auf Ereignisse in einem GitHub-Repository ausgelöst werden. Dadurch kann man zum Beispiel automatisch einen Build-Prozess starten, wenn Änderungen in einem bestimmten Branch vorgenommen werden. Die erstellte Build-Version kann dann auf einem VPS oder in einer Cloud-Umgebung bereitgestellt werden, wobei auch hier wieder automatisierte Workflows genutzt werden können. GitHub Actions erleichtert das Erstellen und Verwalten von Build- und Deployment-Pipelines, indem es möglich ist, alles in einem GitHub-Repository zu konfigurieren und zu verwalten.

Um Deployment mit GitHub Actions zu nutzen, müssen Entwickler zunächst einen Workflow in ihrem GitHub-Repository erstellen. Dieser Workflow besteht aus einer Reihe von Schritten, die in einer bestimmten Reihenfolge ausgeführt werden, um den Code bereitzustellen. Jeder Schritt kann dabei ein eigenes Skript oder eine Aktion von GitHub sein, die eine bestimmte Aufgabe ausführt.

Unser Deployment-Workflow mit GitHub Actions sieht wie folgt aus:
```mermaid
graph LR
  PUSH[Push auf den Branch main]
  SQ[SonarQube-Scan]
  subgraph VPS
    COPY[Source-Code kopieren]
    BUILD[Image-Build]
    UP[Stack starten]
  end
  PUSH --> SQ
  PUSH --> COPY
  COPY --> BUILD
  BUILD --> UP
```

### Operations
*Operational Model*
![Operationsmodel](operationalModelFinal.png)

### Statischer Code-Report
*SonarQube* ist eine Plattform für statische Codeanalyse, die Entwicklern dabei hilft, die Qualität und Sicherheit ihres Codes zu verbessern. Es bietet eine Reihe von Werkzeugen und Plugins, die es Entwicklern ermöglichen, ihren Code auf Fehler, Schwachstellen und potenzielle Verbesserungen zu überprüfen.

SonarQube unterstützt eine Vielzahl von Programmiersprachen, darunter Java, C#, C/C++, JavaScript und viele mehr. Es bietet auch eine integrierte Oberfläche, in der Entwickler die Ergebnisse der Codeanalyse anzeigen und verstehen können.

Eines der Hauptmerkmale von SonarQube ist seine Fähigkeit, Entwicklern zu helfen, die Qualität und Zuverlässigkeit ihres Codes zu verbessern, indem es sie auffordernde Regeln und Best Practices für die Code-Entwicklung hinweist. Dies kann dazu beitragen, dass der Code sauberer, wartbarer und zuverlässiger wird.

Insgesamt ist SonarQube eine leistungsstarke Plattform für die statische Codeanalyse, die Entwicklern dabei hilft, die Qualität und Sicherheit ihres Codes zu verbessern und gleichzeitig die Effizienz ihrer Entwicklungsprozesse zu steigern.