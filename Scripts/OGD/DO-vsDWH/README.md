# OGD DataWareHouse Visual Studio Project

Dit is een Visual Studio solution waarmee we het OGDW DataWareHouse (een SQL Server database) vanuit Visual Studio kunnen manipuleren.

## Inleiding

URL Git repository:
```
https://code.ogdsoftware.nl/Team-BIeR/vsDWH
```
Download een kopie van deze repo naar een lokale computer.

### Vooraf benodigd

* Een sys_ account (met admin rechten).
* Een Gitlab account met toegang tot genoemde repo.
* Een Git client, bv. [GitKraken](https://www.gitkraken.com).
* Visual Studio 2015 of beter.

### Installeren

Vraag bij de servicedesk een Pro licentie voor GitKraken aan. Deze is niet vereist ivm functionaliteit, wel ivm het gebruiksbeleid.

Als je gebruik wilt maken van authenticatie via SSH, stel dan in GitKraken de private en public keys in en kopieer de public key naar GitLab.
Als alternatief kun je ook iedere je Gitlab credentials invullen als GitKraken hier om vraagt.

* Vanuit GitKraken, kies File -> Clone. Er verschijnt een dialoogvenster.
* Kies Clone -> Clone with URL. Geef een lokale map op waarnaar je wilt klonen. 
Doe dit bij voorkeur in een map C:\Shared of zo, zodat je er zowel met je gewone netwerkaccount als met je sys_account bij kunt. 
Geef bij de URL de in de inleiding genoemde URL op.
Controleer de instellingen. Als de opgegeven lokale map niet bestaat, zal GitKraken hem maken.
Als de lokale map wel bestaat, moet die leeg zijn; GitKraken kan niet klonen naar een niet-lege map.
* Druk op "Clone the repo!". Je hebt nu een lokale kopie van de repo.

## Beschrijving van de projecten

In principe heeft iedere database zijn eigen project in de solution.
Alleen de MDS (Master Data Services) heeft geen project, omdat dit een door Microsoft opgezette database is. Deze wordt ingeladen middels een dacpac.
TODO

### Algemene componenten in ieder project

### LIFT_Archive

### LIFT_Staging

### LIFT_DW

### OGDW_Archive

### OGDW_Metadata

### OGDW_Staging

### TOPdesk_DW

## Hoe ontwikkelen?

TODO

## Nuttige weblinks

* [MarkDown Cheat Sheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) (voor het bijwerken van dit document)

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system
TODO: uitwerken hoe je wijzigingen naar acceptatie en naar live krijgt.

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspiration
* etc
