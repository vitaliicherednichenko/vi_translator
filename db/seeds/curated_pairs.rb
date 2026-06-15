# frozen_string_literal: true

#
# Builds themed vocabulary collections for the language pairs
#   uk -> pl, pl -> en, pl -> es, en -> es,
#   en -> fr, es -> fr, uk -> fr, pl -> fr
# reusing the curated "uk -> en" concept set already in the database.
#
# The Ukrainian and English text is read straight from the existing
# "<Theme> (uk->en)" collections (authoritative). The Polish, Spanish and
# French translations below are hand-written and joined to each concept by
# [theme, english]. A concept with no matching translation is reported and
# skipped, so the script is safe and self-checking.
#
# Idempotent: re-running creates anything missing and never duplicates.
#
#   bin/rails runner db/seeds/curated_pairs.rb

# --- hand-written translations, keyed by theme then english -------------------
# Format under each "# Theme" header:  english <TAB> polish <TAB> spanish <TAB> french
TRANSLATIONS = <<~TSV
  # Actions
  to talk	mówić	hablar	parler
  to eat	jeść	comer	manger
  to drink	pić	beber	boire
  to run	biegać	correr	courir
  to swim	pływać	nadar	nager
  to write	pisać	escribir	écrire
  to read	czytać	leer	lire
  to sleep	spać	dormir	dormir
  to walk	chodzić	caminar	marcher
  to see	widzieć	ver	voir
  to listen	słuchać	escuchar	écouter
  to work	pracować	trabajar	travailler
  to sing	śpiewać	cantar	chanter
  to dance	tańczyć	bailar	danser
  to play	grać	jugar	jouer
  to buy	kupować	comprar	acheter
  to sell	sprzedawać	vender	vendre
  to open	otwierać	abrir	ouvrir
  to close	zamykać	cerrar	fermer
  to think	myśleć	pensar	penser

  # Adjectives
  big	duży	grande	grand
  small	mały	pequeño	petit
  tall	wysoki	alto	haut
  low	niski	bajo	bas
  long	długi	largo	long
  short	krótki	corto	court
  new	nowy	nuevo	nouveau
  old	stary	viejo	vieux
  good	dobry	bueno	bon
  bad	zły	malo	mauvais
  easy	łatwy	fácil	facile
  hard	trudny	difícil	difficile
  fast	szybki	rápido	rapide
  slow	wolny	lento	lent
  strong	silny	fuerte	fort
  weak	słaby	débil	faible
  clean	czysty	limpio	propre
  dirty	brudny	sucio	sale
  expensive	drogi	caro	cher
  cheap	tani	barato	bon marché

  # Animals
  dog	pies	perro	chien
  cat	kot	gato	chat
  horse	koń	caballo	cheval
  cow	krowa	vaca	vache
  bird	ptak	pájaro	oiseau
  fish	ryba	pez	poisson
  hen	kura	gallina	poule
  pig	świnia	cerdo	cochon
  sheep	owca	oveja	mouton
  mouse	mysz	ratón	souris
  lion	lew	león	lion
  animal	zwierzę	animal	animal
  rabbit	królik	conejo	lapin
  duck	kaczka	pato	canard
  turtle	żółw	tortuga	tortue
  snake	wąż	serpiente	serpent
  bear	niedźwiedź	oso	ours
  wolf	wilk	lobo	loup
  tiger	tygrys	tigre	tigre
  elephant	słoń	elefante	éléphant

  # Body
  head	głowa	cabeza	tête
  hand	ręka	mano	main
  foot	stopa	pie	pied
  eye	oko	ojo	œil
  mouth	usta	boca	bouche
  nose	nos	nariz	nez
  ear	ucho	oreja	oreille
  tooth	ząb	diente	dent
  tongue	język	lengua	langue
  finger	palec	dedo	doigt
  heart	serce	corazón	cœur
  hair	włosy	pelo	cheveux
  neck	szyja	cuello	cou
  back	plecy	espalda	dos
  stomach	brzuch	estómago	ventre
  knee	kolano	rodilla	genou
  shoulder	ramię	hombro	épaule
  face	twarz	cara	visage
  skin	skóra	piel	peau
  blood	krew	sangre	sang

  # City
  city	miasto	ciudad	ville
  street	ulica	calle	rue
  square	plac	plaza	place
  park	park	parque	parc
  shop	sklep	tienda	magasin
  market	rynek	mercado	marché
  bank	bank	banco	banque
  hospital	szpital	hospital	hôpital
  church	kościół	iglesia	église
  restaurant	restauracja	restaurante	restaurant
  museum	muzeum	museo	musée
  library	biblioteka	biblioteca	bibliothèque
  cinema	kino	cine	cinéma
  bridge	most	puente	pont
  building	budynek	edificio	bâtiment
  corner	róg	esquina	coin

  # Clothing
  clothes	ubrania	ropa	vêtements
  shirt	koszula	camisa	chemise
  pants	spodnie	pantalones	pantalon
  shoes	buty	zapatos	chaussures
  dress	sukienka	vestido	robe
  skirt	spódnica	falda	jupe
  coat	płaszcz	abrigo	manteau
  hat	kapelusz	sombrero	chapeau
  sock	skarpetka	calcetín	chaussette
  glove	rękawiczka	guante	gant
  scarf	szalik	bufanda	écharpe
  belt	pasek	cinturón	ceinture
  tie	krawat	corbata	cravate
  jacket	kurtka	chaqueta	veste
  button	guzik	botón	bouton
  pocket	kieszeń	bolsillo	poche

  # Colors
  red	czerwony	rojo	rouge
  blue	niebieski	azul	bleu
  green	zielony	verde	vert
  yellow	żółty	amarillo	jaune
  black	czarny	negro	noir
  white	biały	blanco	blanc
  gray	szary	gris	gris
  pink	różowy	rosa	rose
  orange	pomarańczowy	naranja	orange
  brown	brązowy	marrón	marron
  purple	fioletowy	morado	violet
  color	kolor	color	couleur
  gold	złoty	dorado	doré
  silver	srebrny	plateado	argenté
  light	jasny	claro	clair
  dark	ciemny	oscuro	foncé
  bright	jaskrawy	brillante	vif
  pale	blady	pálido	pâle
  beige	beżowy	beige	beige
  turquoise	turkusowy	turquesa	turquoise

  # Days
  Monday	poniedziałek	lunes	lundi
  Tuesday	wtorek	martes	mardi
  Wednesday	środa	miércoles	mercredi
  Thursday	czwartek	jueves	jeudi
  Friday	piątek	viernes	vendredi
  Saturday	sobota	sábado	samedi
  Sunday	niedziela	domingo	dimanche
  weekend	weekend	fin de semana	week-end
  holiday	święto	día festivo	jour férié
  calendar	kalendarz	calendario	calendrier

  # Directions
  left	w lewo	izquierda	gauche
  right	w prawo	derecha	droite
  up	w górę	arriba	en haut
  down	w dół	abajo	en bas
  forward	naprzód	adelante	en avant
  back	z powrotem	atrás	en arrière
  near	blisko	cerca	près
  far	daleko	lejos	loin
  here	tutaj	aquí	ici
  there	tam	allí	là
  inside	wewnątrz	dentro	dedans
  outside	na zewnątrz	fuera	dehors
  north	północ	norte	nord
  south	południe	sur	sud
  east	wschód	este	est
  west	zachód	oeste	ouest

  # Drinks
  drink	napój	bebida	boisson
  juice	sok	zumo	jus
  beer	piwo	cerveza	bière
  wine	wino	vino	vin
  tea	herbata	té	thé
  soda	napój gazowany	refresco	soda
  milkshake	koktajl mleczny	batido	milk-shake
  chocolate	czekolada	chocolate	chocolat
  wine glass	kieliszek	copa	verre à vin
  cup	filiżanka	taza	tasse
  bottle	butelka	botella	bouteille
  glass	szklanka	vaso	verre
  cocktail	koktajl	cóctel	cocktail
  champagne	szampan	champán	champagne

  # Emotions
  happy	szczęśliwy	feliz	heureux
  sad	smutny	triste	triste
  angry	zły	enfadado	en colère
  tired	zmęczony	cansado	fatigué
  scared	przestraszony	asustado	effrayé
  surprised	zaskoczony	sorprendido	surpris
  bored	znudzony	aburrido	ennuyé
  nervous	zdenerwowany	nervioso	nerveux
  content	zadowolony	contento	satisfait
  proud	dumny	orgulloso	fier
  jealous	zazdrosny	celoso	jaloux
  calm	spokojny	tranquilo	calme
  love	miłość	amor	amour
  fear	strach	miedo	peur
  joy	radość	alegría	joie
  sadness	smutek	tristeza	tristesse

  # Family
  father	ojciec	padre	père
  mother	matka	madre	mère
  son	syn	hijo	fils
  daughter	córka	hija	fille
  brother	brat	hermano	frère
  sister	siostra	hermana	sœur
  grandfather	dziadek	abuelo	grand-père
  grandmother	babcia	abuela	grand-mère
  husband	mąż	esposo	mari
  wife	żona	esposa	femme
  child	dziecko	niño	enfant
  family	rodzina	familia	famille
  girl	dziewczynka	niña	fille
  uncle	wujek	tío	oncle
  aunt	ciotka	tía	tante
  cousin (m)	kuzyn	primo	cousin
  cousin (f)	kuzynka	prima	cousine
  grandson	wnuk	nieto	petit-fils
  granddaughter	wnuczka	nieta	petite-fille
  baby	niemowlę	bebé	bébé

  # Food
  bread	chleb	pan	pain
  water	woda	agua	eau
  meat	mięso	carne	viande
  milk	mleko	leche	lait
  fruit	owoc	fruta	fruit
  vegetable	warzywo	verdura	légume
  egg	jajko	huevo	œuf
  cheese	ser	queso	fromage
  rice	ryż	arroz	riz
  fish	ryba	pescado	poisson
  coffee	kawa	café	café
  apple	jabłko	manzana	pomme
  salt	sól	sal	sel
  sugar	cukier	azúcar	sucre
  oil	olej	aceite	huile
  butter	masło	mantequilla	beurre
  soup	zupa	sopa	soupe
  salad	sałatka	ensalada	salade
  chicken	kurczak	pollo	poulet
  sandwich	kanapka	sándwich	sandwich

  # Fruits and Vegetables
  banana	banan	plátano	banane
  orange	pomarańcza	naranja	orange
  grapes	winogrona	uvas	raisins
  strawberry	truskawka	fresa	fraise
  lemon	cytryna	limón	citron
  pear	gruszka	pera	poire
  watermelon	arbuz	sandía	pastèque
  melon	melon	melón	melon
  tomato	pomidor	tomate	tomate
  potato	ziemniak	patata	pomme de terre
  onion	cebula	cebolla	oignon
  carrot	marchewka	zanahoria	carotte
  lettuce	sałata	lechuga	laitue
  cucumber	ogórek	pepino	concombre
  garlic	czosnek	ajo	ail
  corn	kukurydza	maíz	maïs

  # Greetings
  hello	cześć	hola	bonjour
  goodbye	do widzenia	adiós	au revoir
  thank you	dziękuję	gracias	merci
  please	proszę	por favor	s'il vous plaît
  sorry	przepraszam	perdón	pardon
  good morning	dzień dobry	buenos días	bonjour
  good afternoon	dzień dobry	buenas tardes	bon après-midi
  good night	dobranoc	buenas noches	bonne nuit
  welcome	witamy	bienvenido	bienvenue
  you're welcome	nie ma za co	de nada	de rien
  see you later	do zobaczenia	hasta luego	à bientôt
  of course	oczywiście	por supuesto	bien sûr
  okay	dobrze	vale	d'accord
  cheers	na zdrowie	salud	santé

  # Health
  health	zdrowie	salud	santé
  illness	choroba	enfermedad	maladie
  pain	ból	dolor	douleur
  medicine	lekarstwo	medicina	médicament
  fever	gorączka	fiebre	fièvre
  flu	grypa	gripe	grippe
  cough	kaszel	tos	toux
  wound	rana	herida	blessure
  vaccine	szczepionka	vacuna	vaccin
  pill	tabletka	pastilla	comprimé
  doctor	lekarz	médico	médecin
  dentist	dentysta	dentista	dentiste
  pharmacy	apteka	farmacia	pharmacie
  appointment	wizyta	cita	rendez-vous
  prescription	recepta	receta	ordonnance
  ambulance	karetka	ambulancia	ambulance

  # Home
  house	dom	casa	maison
  door	drzwi	puerta	porte
  window	okno	ventana	fenêtre
  table	stół	mesa	table
  chair	krzesło	silla	chaise
  bed	łóżko	cama	lit
  kitchen	kuchnia	cocina	cuisine
  bathroom	łazienka	baño	salle de bains
  room	pokój	habitación	chambre
  floor	podłoga	suelo	sol
  wall	ściana	pared	mur
  key	klucz	llave	clé
  ceiling	sufit	techo	plafond
  stairs	schody	escaleras	escalier
  garden	ogród	jardín	jardin
  garage	garaż	garaje	garage
  furniture	meble	muebles	meubles
  lamp	lampa	lámpara	lampe
  mirror	lustro	espejo	miroir
  sofa	kanapa	sofá	canapé

  # Jobs
  doctor	lekarz	médico	médecin
  teacher	nauczyciel	maestro	enseignant
  professor	profesor	profesor	professeur
  engineer	inżynier	ingeniero	ingénieur
  lawyer	prawnik	abogado	avocat
  police officer	policjant	policía	policier
  firefighter	strażak	bombero	pompier
  cook	kucharz	cocinero	cuisinier
  waiter	kelner	camarero	serveur
  nurse	pielęgniarz	enfermero	infirmier
  driver	kierowca	conductor	chauffeur
  seller	sprzedawca	vendedor	vendeur
  farmer	rolnik	granjero	agriculteur
  artist	artysta	artista	artiste
  scientist	naukowiec	científico	scientifique
  boss	szef	jefe	patron

  # Kitchen
  plate	talerz	plato	assiette
  spoon	łyżka	cuchara	cuillère
  fork	widelec	tenedor	fourchette
  knife	nóż	cuchillo	couteau
  pot	garnek	olla	casserole
  frying pan	patelnia	sartén	poêle
  oven	piekarnik	horno	four
  fridge	lodówka	nevera	réfrigérateur
  sink	zlew	fregadero	évier
  napkin	serwetka	servilleta	serviette
  tablecloth	obrus	mantel	nappe
  jug	dzbanek	jarra	pichet
  tray	taca	bandeja	plateau
  bowl	miska	cuenco	bol

  # Money
  money	pieniądze	dinero	argent
  price	cena	precio	prix
  coin	moneta	moneda	pièce
  card	karta	tarjeta	carte
  purchase	zakup	compra	achat
  sale	sprzedaż	venta	vente
  customer	klient	cliente	client
  offer	oferta	oferta	offre
  discount	zniżka	descuento	réduction
  receipt	paragon	recibo	reçu
  bill	rachunek	cuenta	facture
  change	reszta	cambio	monnaie
  cash	gotówka	efectivo	espèces
  free	za darmo	gratis	gratuit
  rich	bogaty	rico	riche
  poor	biedny	pobre	pauvre

  # Months
  January	styczeń	enero	janvier
  February	luty	febrero	février
  March	marzec	marzo	mars
  April	kwiecień	abril	avril
  May	maj	mayo	mai
  June	czerwiec	junio	juin
  July	lipiec	julio	juillet
  August	sierpień	agosto	août
  September	wrzesień	septiembre	septembre
  October	październik	octubre	octobre
  November	listopad	noviembre	novembre
  December	grudzień	diciembre	décembre

  # Music
  music	muzyka	música	musique
  song	piosenka	canción	chanson
  guitar	gitara	guitarra	guitare
  piano	pianino	piano	piano
  violin	skrzypce	violín	violon
  drum	bęben	tambor	tambour
  singer	piosenkarz	cantante	chanteur
  orchestra	orkiestra	orquesta	orchestre
  concert	koncert	concierto	concert
  movie	film	película	film
  theater	teatr	teatro	théâtre
  painting	obraz	cuadro	tableau
  dance	taniec	baile	danse
  rhythm	rytm	ritmo	rythme
  voice	głos	voz	voix

  # Nature
  sun	słońce	sol	soleil
  moon	księżyc	luna	lune
  sky	niebo	cielo	ciel
  sea	morze	mar	mer
  river	rzeka	río	rivière
  mountain	góra	montaña	montagne
  tree	drzewo	árbol	arbre
  flower	kwiat	flor	fleur
  rain	deszcz	lluvia	pluie
  wind	wiatr	viento	vent
  fire	ogień	fuego	feu
  earth	ziemia	tierra	terre
  cloud	chmura	nube	nuage
  snow	śnieg	nieve	neige
  ice	lód	hielo	glace
  lake	jezioro	lago	lac
  island	wyspa	isla	île
  forest	las	bosque	forêt
  beach	plaża	playa	plage
  stone	kamień	piedra	pierre

  # Numbers
  one	jeden	uno	un
  two	dwa	dos	deux
  three	trzy	tres	trois
  four	cztery	cuatro	quatre
  five	pięć	cinco	cinq
  six	sześć	seis	six
  seven	siedem	siete	sept
  eight	osiem	ocho	huit
  nine	dziewięć	nueve	neuf
  ten	dziesięć	diez	dix
  hundred	sto	cien	cent
  thousand	tysiąc	mil	mille
  eleven	jedenaście	once	onze
  twelve	dwanaście	doce	douze
  twenty	dwadzieścia	veinte	vingt
  thirty	trzydzieści	treinta	trente
  forty	czterdzieści	cuarenta	quarante
  fifty	pięćdziesiąt	cincuenta	cinquante
  zero	zero	cero	zéro
  million	milion	millón	million

  # Office
  office	biuro	oficina	bureau
  meeting	spotkanie	reunión	réunion
  document	dokument	documento	document
  report	raport	informe	rapport
  project	projekt	proyecto	projet
  contract	kontrakt	contrato	contrat
  salary	pensja	salario	salaire
  employee	pracownik	empleado	employé
  company	firma	empresa	entreprise
  planner	terminarz	agenda	agenda
  printer	drukarka	impresora	imprimante
  desk	biurko	escritorio	bureau
  folder	teczka	carpeta	dossier
  stamp	pieczęć	sello	cachet
  signature	podpis	firma	signature

  # People
  man	mężczyzna	hombre	homme
  woman	kobieta	mujer	femme
  person	osoba	persona	personne
  people	ludzie	gente	gens
  friend	przyjaciel	amigo	ami
  female friend	przyjaciółka	amiga	amie
  neighbor	sąsiad	vecino	voisin
  boyfriend	chłopak	novio	petit ami
  girlfriend	dziewczyna	novia	petite amie
  sir	pan	señor	monsieur
  madam	pani	señora	madame
  adult	dorosły	adulto	adulte
  young man	młodzieniec	joven	jeune homme
  couple	para	pareja	couple

  # Questions
  what	co	qué	quoi
  who	kto	quién	qui
  where	gdzie	dónde	où
  when	kiedy	cuándo	quand
  how	jak	cómo	comment
  why	dlaczego	por qué	pourquoi
  which	który	cuál	quel
  how much	ile	cuánto	combien
  yes	tak	sí	oui
  no	nie	no	non
  maybe	może	quizás	peut-être
  because	ponieważ	porque	parce que

  # School
  school	szkoła	escuela	école
  book	książka	libro	livre
  pencil	ołówek	lápiz	crayon
  pen	długopis	bolígrafo	stylo
  notebook	zeszyt	cuaderno	cahier
  paper	papier	papel	papier
  board	tablica	pizarra	tableau
  pupil	uczeń	alumno	élève
  student	student	estudiante	étudiant
  exam	egzamin	examen	examen
  lesson	lekcja	lección	leçon
  task	zadanie	tarea	tâche
  ruler	linijka	regla	règle
  eraser	gumka	goma	gomme
  backpack	plecak	mochila	sac à dos
  grade	ocena	nota	note

  # Sports
  sport	sport	deporte	sport
  football	piłka nożna	fútbol	football
  basketball	koszykówka	baloncesto	basket-ball
  tennis	tenis	tenis	tennis
  swimming	pływanie	natación	natation
  cycling	kolarstwo	ciclismo	cyclisme
  boxing	boks	boxeo	boxe
  gym	siłownia	gimnasio	salle de sport
  team	drużyna	equipo	équipe
  player	gracz	jugador	joueur
  ball	piłka	pelota	ballon
  match	mecz	partido	match
  winner	zwycięzca	ganador	gagnant
  coach	trener	entrenador	entraîneur
  medal	medal	medalla	médaille
  champion	mistrz	campeón	champion

  # Technology
  computer	komputer	ordenador	ordinateur
  telephone	telefon	teléfono	téléphone
  mobile phone	telefon komórkowy	teléfono móvil	téléphone portable
  internet	internet	internet	internet
  screen	ekran	pantalla	écran
  keyboard	klawiatura	teclado	clavier
  camera	kamera	cámara	caméra
  battery	bateria	batería	batterie
  program	program	programa	programme
  app	aplikacja	aplicación	application
  file	plik	archivo	fichier
  password	hasło	contraseña	mot de passe
  email	e-mail	correo electrónico	e-mail
  message	wiadomość	mensaje	message
  network	sieć	red	réseau
  cable	kabel	cable	câble

  # Time
  day	dzień	día	jour
  night	noc	noche	nuit
  week	tydzień	semana	semaine
  month	miesiąc	mes	mois
  year	rok	año	an
  hour	godzina	hora	heure
  minute	minuta	minuto	minute
  morning	poranek	mañana	matin
  evening	wieczór	tarde	soir
  today	dzisiaj	hoy	aujourd'hui
  yesterday	wczoraj	ayer	hier
  time	czas	tiempo	temps
  second	sekunda	segundo	seconde
  moment	chwila	momento	moment
  century	wiek	siglo	siècle
  now	teraz	ahora	maintenant
  early	wcześnie	temprano	tôt
  always	zawsze	siempre	toujours
  never	nigdy	nunca	jamais
  soon	wkrótce	pronto	bientôt

  # Travel
  trip	podróż	viaje	voyage
  car	samochód	coche	voiture
  bus	autobus	autobús	bus
  train	pociąg	tren	train
  plane	samolot	avión	avion
  ship	statek	barco	bateau
  bicycle	rower	bicicleta	vélo
  taxi	taksówka	taxi	taxi
  ticket	bilet	billete	billet
  suitcase	walizka	maleta	valise
  passport	paszport	pasaporte	passeport
  hotel	hotel	hotel	hôtel
  airport	lotnisko	aeropuerto	aéroport
  road	droga	carretera	route
  map	mapa	mapa	carte
  border	granica	frontera	frontière

  # Verbs II
  to come	przychodzić	venir	venir
  to go out	wychodzić	salir	sortir
  to enter	wchodzić	entrar	entrer
  to arrive	przybywać	llegar	arriver
  to put	kłaść	poner	mettre
  to give	dawać	dar	donner
  to take	brać	tomar	prendre
  to leave	zostawiać	dejar	laisser
  to carry	nieść	llevar	porter
  to start	zaczynać	empezar	commencer
  to finish	kończyć	terminar	finir
  to win	wygrywać	ganar	gagner
  to lose	przegrywać	perder	perdre
  to help	pomagać	ayudar	aider
  to wait	czekać	esperar	attendre
  to find	znajdować	encontrar	trouver
  to search	szukać	buscar	chercher
  to live	żyć	vivir	vivre

  # Verbs III
  to want	chcieć	querer	vouloir
  to need	potrzebować	necesitar	avoir besoin
  to know	wiedzieć	saber	savoir
  to get to know	poznawać	conocer	connaître
  to believe	wierzyć	creer	croire
  to understand	rozumieć	entender	comprendre
  to remember	pamiętać	recordar	se souvenir
  to forget	zapominać	olvidar	oublier
  to feel	czuć	sentir	sentir
  to say	mówić	decir	dire
  to ask	pytać	preguntar	demander
  to answer	odpowiadać	responder	répondre
  to call	dzwonić	llamar	appeler
  to show	pokazywać	mostrar	montrer
  to change	zmieniać	cambiar	changer
  to use	używać	usar	utiliser

  # Weather
  climate	klimat	clima	climat
  heat	upał	calor	chaleur
  cold	zimno	frío	froid
  temperature	temperatura	temperatura	température
  storm	burza	tormenta	tempête
  fog	mgła	niebla	brouillard
  thunder	grzmot	trueno	tonnerre
  lightning	błyskawica	relámpago	éclair
  humid	wilgotny	húmedo	humide
  dry	suchy	seco	sec
  sunny	słoneczny	soleado	ensoleillé
  cloudy	pochmurny	nublado	nuageux
  hail	grad	granizo	grêle
  rainbow	tęcza	arcoíris	arc-en-ciel
  season	pora roku	estación	saison
  degree	stopień	grado	degré
TSV

# --- parse the translation table into trans[theme][english] = [pl, es, fr] -----
trans = Hash.new { |h, k| h[k] = {} }
current_theme = nil
TRANSLATIONS.each_line do |raw|
  line = raw.rstrip
  next if line.empty?
  if line.start_with?("#")
    current_theme = line.sub(/\A#\s*/, "")
  else
    en, pl, es, fr = line.split("\t")
    trans[current_theme][en] = [ pl, es, fr ]
  end
end

# --- read the authoritative uk/en concepts from the existing uk->en decks ------
uk_en_cols = Collection.joins(:language)
                       .where(languages: { code: "uk" })
                       .where("collections.name LIKE ?", "%(uk->en)%")
                       .order(:name)

concepts = []   # { theme:, uk:, en:, pl:, es:, fr: }
missing  = []
uk_en_cols.each do |col|
  theme = col.name.sub(/\s*\(uk->en\)\z/, "")
  col.cards.kept.order(:id).each do |card|
    en = card.back_text
    pl, es, fr = trans.dig(theme, en)
    if pl.nil? || es.nil? || fr.nil?
      lacking = [ ("pl" if pl.nil?), ("es" if es.nil?), ("fr" if fr.nil?) ].compact.join(", ")
      missing << "#{theme} / #{en} (#{lacking})"
    else
      concepts << { theme: theme, uk: card.front_text, en: en, pl: pl, es: es, fr: fr }
    end
  end
end

if missing.any?
  warn "Missing translations for #{missing.size} concepts:"
  missing.each { |m| warn "  - #{m}" }
  abort "Aborting without writing. Add the translations above and re-run."
end

# --- build the pairs -----------------------------------------------------------
owner = User.where(admin: true).order(:id).first || User.order(:id).first
abort "No user available to own the collections." unless owner

langs = %w[uk en pl es fr].index_with { |code| Language.find_by!(code: code) }

# [source code, target code, source key, target key]
pairs = [
  [ "uk", "pl", :uk, :pl ],
  [ "pl", "en", :pl, :en ],
  [ "pl", "es", :pl, :es ],
  [ "en", "es", :en, :es ],
  [ "en", "fr", :en, :fr ],
  [ "es", "fr", :es, :fr ],
  [ "uk", "fr", :uk, :fr ],
  [ "pl", "fr", :pl, :fr ]
]

cols_created = cards_created = 0

pairs.each do |src_code, tgt_code, src_key, tgt_key|
  src_lang = langs[src_code]
  tgt_lang = langs[tgt_code]

  concepts.group_by { |c| c[:theme] }.each do |theme, items|
    name = "#{theme} (#{src_code}->#{tgt_code})"
    col = Collection.find_or_create_by!(name: name, user: owner) do |c|
      c.language    = src_lang
      c.description  = "#{theme}: #{src_code} → #{tgt_code}"
    end
    col.update!(language: src_lang) unless col.language_id == src_lang.id
    cols_created += 1 if col.previously_new_record?

    items.each do |concept|
      front = concept[src_key]
      back  = concept[tgt_key]
      next if front.blank? || back.blank?

      card = col.cards.find_or_initialize_by(front_text: front, back_text: back)
      next unless card.new_record?

      card.user            = owner
      card.source_language = src_lang
      card.target_language = tgt_lang
      card.save!
      cards_created += 1
    end
  end
end

puts "Owner: #{owner.email}"
puts "Concepts: #{concepts.size} across #{concepts.map { |c| c[:theme] }.uniq.size} themes"
puts "Collections created: #{cols_created} (#{pairs.size} pairs × #{concepts.map { |c| c[:theme] }.uniq.size} themes)"
puts "Cards created: #{cards_created}"
