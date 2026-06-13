# frozen_string_literal: true

#
# Builds themed vocabulary collections for the language pairs
#   uk -> pl, pl -> en, pl -> es, en -> es
# reusing the curated "uk -> en" concept set already in the database.
#
# The Ukrainian and English text is read straight from the existing
# "<Theme> (uk->en)" collections (authoritative). The Polish and Spanish
# translations below are hand-written and joined to each concept by
# [theme, english]. A concept with no matching translation is reported and
# skipped, so the script is safe and self-checking.
#
# Idempotent: re-running creates anything missing and never duplicates.
#
#   bin/rails runner db/seeds/curated_pairs.rb

# --- hand-written pl / es translations, keyed by theme then english ------------
# Format under each "# Theme" header:  english <TAB> polish <TAB> spanish
TRANSLATIONS = <<~TSV
  # Actions
  to talk	mówić	hablar
  to eat	jeść	comer
  to drink	pić	beber
  to run	biegać	correr
  to swim	pływać	nadar
  to write	pisać	escribir
  to read	czytać	leer
  to sleep	spać	dormir
  to walk	chodzić	caminar
  to see	widzieć	ver
  to listen	słuchać	escuchar
  to work	pracować	trabajar
  to sing	śpiewać	cantar
  to dance	tańczyć	bailar
  to play	grać	jugar
  to buy	kupować	comprar
  to sell	sprzedawać	vender
  to open	otwierać	abrir
  to close	zamykać	cerrar
  to think	myśleć	pensar

  # Adjectives
  big	duży	grande
  small	mały	pequeño
  tall	wysoki	alto
  low	niski	bajo
  long	długi	largo
  short	krótki	corto
  new	nowy	nuevo
  old	stary	viejo
  good	dobry	bueno
  bad	zły	malo
  easy	łatwy	fácil
  hard	trudny	difícil
  fast	szybki	rápido
  slow	wolny	lento
  strong	silny	fuerte
  weak	słaby	débil
  clean	czysty	limpio
  dirty	brudny	sucio
  expensive	drogi	caro
  cheap	tani	barato

  # Animals
  dog	pies	perro
  cat	kot	gato
  horse	koń	caballo
  cow	krowa	vaca
  bird	ptak	pájaro
  fish	ryba	pez
  hen	kura	gallina
  pig	świnia	cerdo
  sheep	owca	oveja
  mouse	mysz	ratón
  lion	lew	león
  animal	zwierzę	animal
  rabbit	królik	conejo
  duck	kaczka	pato
  turtle	żółw	tortuga
  snake	wąż	serpiente
  bear	niedźwiedź	oso
  wolf	wilk	lobo
  tiger	tygrys	tigre
  elephant	słoń	elefante

  # Body
  head	głowa	cabeza
  hand	ręka	mano
  foot	stopa	pie
  eye	oko	ojo
  mouth	usta	boca
  nose	nos	nariz
  ear	ucho	oreja
  tooth	ząb	diente
  tongue	język	lengua
  finger	palec	dedo
  heart	serce	corazón
  hair	włosy	pelo
  neck	szyja	cuello
  back	plecy	espalda
  stomach	brzuch	estómago
  knee	kolano	rodilla
  shoulder	ramię	hombro
  face	twarz	cara
  skin	skóra	piel
  blood	krew	sangre

  # City
  city	miasto	ciudad
  street	ulica	calle
  square	plac	plaza
  park	park	parque
  shop	sklep	tienda
  market	rynek	mercado
  bank	bank	banco
  hospital	szpital	hospital
  church	kościół	iglesia
  restaurant	restauracja	restaurante
  museum	muzeum	museo
  library	biblioteka	biblioteca
  cinema	kino	cine
  bridge	most	puente
  building	budynek	edificio
  corner	róg	esquina

  # Clothing
  clothes	ubrania	ropa
  shirt	koszula	camisa
  pants	spodnie	pantalones
  shoes	buty	zapatos
  dress	sukienka	vestido
  skirt	spódnica	falda
  coat	płaszcz	abrigo
  hat	kapelusz	sombrero
  sock	skarpetka	calcetín
  glove	rękawiczka	guante
  scarf	szalik	bufanda
  belt	pasek	cinturón
  tie	krawat	corbata
  jacket	kurtka	chaqueta
  button	guzik	botón
  pocket	kieszeń	bolsillo

  # Colors
  red	czerwony	rojo
  blue	niebieski	azul
  green	zielony	verde
  yellow	żółty	amarillo
  black	czarny	negro
  white	biały	blanco
  gray	szary	gris
  pink	różowy	rosa
  orange	pomarańczowy	naranja
  brown	brązowy	marrón
  purple	fioletowy	morado
  color	kolor	color
  gold	złoty	dorado
  silver	srebrny	plateado
  light	jasny	claro
  dark	ciemny	oscuro
  bright	jaskrawy	brillante
  pale	blady	pálido
  beige	beżowy	beige
  turquoise	turkusowy	turquesa

  # Days
  Monday	poniedziałek	lunes
  Tuesday	wtorek	martes
  Wednesday	środa	miércoles
  Thursday	czwartek	jueves
  Friday	piątek	viernes
  Saturday	sobota	sábado
  Sunday	niedziela	domingo
  weekend	weekend	fin de semana
  holiday	święto	día festivo
  calendar	kalendarz	calendario

  # Directions
  left	w lewo	izquierda
  right	w prawo	derecha
  up	w górę	arriba
  down	w dół	abajo
  forward	naprzód	adelante
  back	z powrotem	atrás
  near	blisko	cerca
  far	daleko	lejos
  here	tutaj	aquí
  there	tam	allí
  inside	wewnątrz	dentro
  outside	na zewnątrz	fuera
  north	północ	norte
  south	południe	sur
  east	wschód	este
  west	zachód	oeste

  # Drinks
  drink	napój	bebida
  juice	sok	zumo
  beer	piwo	cerveza
  wine	wino	vino
  tea	herbata	té
  soda	napój gazowany	refresco
  milkshake	koktajl mleczny	batido
  chocolate	czekolada	chocolate
  wine glass	kieliszek	copa
  cup	filiżanka	taza
  bottle	butelka	botella
  glass	szklanka	vaso
  cocktail	koktajl	cóctel
  champagne	szampan	champán

  # Emotions
  happy	szczęśliwy	feliz
  sad	smutny	triste
  angry	zły	enfadado
  tired	zmęczony	cansado
  scared	przestraszony	asustado
  surprised	zaskoczony	sorprendido
  bored	znudzony	aburrido
  nervous	zdenerwowany	nervioso
  content	zadowolony	contento
  proud	dumny	orgulloso
  jealous	zazdrosny	celoso
  calm	spokojny	tranquilo
  love	miłość	amor
  fear	strach	miedo
  joy	radość	alegría
  sadness	smutek	tristeza

  # Family
  father	ojciec	padre
  mother	matka	madre
  son	syn	hijo
  daughter	córka	hija
  brother	brat	hermano
  sister	siostra	hermana
  grandfather	dziadek	abuelo
  grandmother	babcia	abuela
  husband	mąż	esposo
  wife	żona	esposa
  child	dziecko	niño
  family	rodzina	familia
  girl	dziewczynka	niña
  uncle	wujek	tío
  aunt	ciotka	tía
  cousin (m)	kuzyn	primo
  cousin (f)	kuzynka	prima
  grandson	wnuk	nieto
  granddaughter	wnuczka	nieta
  baby	niemowlę	bebé

  # Food
  bread	chleb	pan
  water	woda	agua
  meat	mięso	carne
  milk	mleko	leche
  fruit	owoc	fruta
  vegetable	warzywo	verdura
  egg	jajko	huevo
  cheese	ser	queso
  rice	ryż	arroz
  fish	ryba	pescado
  coffee	kawa	café
  apple	jabłko	manzana
  salt	sól	sal
  sugar	cukier	azúcar
  oil	olej	aceite
  butter	masło	mantequilla
  soup	zupa	sopa
  salad	sałatka	ensalada
  chicken	kurczak	pollo
  sandwich	kanapka	sándwich

  # Fruits and Vegetables
  banana	banan	plátano
  orange	pomarańcza	naranja
  grapes	winogrona	uvas
  strawberry	truskawka	fresa
  lemon	cytryna	limón
  pear	gruszka	pera
  watermelon	arbuz	sandía
  melon	melon	melón
  tomato	pomidor	tomate
  potato	ziemniak	patata
  onion	cebula	cebolla
  carrot	marchewka	zanahoria
  lettuce	sałata	lechuga
  cucumber	ogórek	pepino
  garlic	czosnek	ajo
  corn	kukurydza	maíz

  # Greetings
  hello	cześć	hola
  goodbye	do widzenia	adiós
  thank you	dziękuję	gracias
  please	proszę	por favor
  sorry	przepraszam	perdón
  good morning	dzień dobry	buenos días
  good afternoon	dzień dobry	buenas tardes
  good night	dobranoc	buenas noches
  welcome	witamy	bienvenido
  you're welcome	nie ma za co	de nada
  see you later	do zobaczenia	hasta luego
  of course	oczywiście	por supuesto
  okay	dobrze	vale
  cheers	na zdrowie	salud

  # Health
  health	zdrowie	salud
  illness	choroba	enfermedad
  pain	ból	dolor
  medicine	lekarstwo	medicina
  fever	gorączka	fiebre
  flu	grypa	gripe
  cough	kaszel	tos
  wound	rana	herida
  vaccine	szczepionka	vacuna
  pill	tabletka	pastilla
  doctor	lekarz	médico
  dentist	dentysta	dentista
  pharmacy	apteka	farmacia
  appointment	wizyta	cita
  prescription	recepta	receta
  ambulance	karetka	ambulancia

  # Home
  house	dom	casa
  door	drzwi	puerta
  window	okno	ventana
  table	stół	mesa
  chair	krzesło	silla
  bed	łóżko	cama
  kitchen	kuchnia	cocina
  bathroom	łazienka	baño
  room	pokój	habitación
  floor	podłoga	suelo
  wall	ściana	pared
  key	klucz	llave
  ceiling	sufit	techo
  stairs	schody	escaleras
  garden	ogród	jardín
  garage	garaż	garaje
  furniture	meble	muebles
  lamp	lampa	lámpara
  mirror	lustro	espejo
  sofa	kanapa	sofá

  # Jobs
  doctor	lekarz	médico
  teacher	nauczyciel	maestro
  professor	profesor	profesor
  engineer	inżynier	ingeniero
  lawyer	prawnik	abogado
  police officer	policjant	policía
  firefighter	strażak	bombero
  cook	kucharz	cocinero
  waiter	kelner	camarero
  nurse	pielęgniarz	enfermero
  driver	kierowca	conductor
  seller	sprzedawca	vendedor
  farmer	rolnik	granjero
  artist	artysta	artista
  scientist	naukowiec	científico
  boss	szef	jefe

  # Kitchen
  plate	talerz	plato
  spoon	łyżka	cuchara
  fork	widelec	tenedor
  knife	nóż	cuchillo
  pot	garnek	olla
  frying pan	patelnia	sartén
  oven	piekarnik	horno
  fridge	lodówka	nevera
  sink	zlew	fregadero
  napkin	serwetka	servilleta
  tablecloth	obrus	mantel
  jug	dzbanek	jarra
  tray	taca	bandeja
  bowl	miska	cuenco

  # Money
  money	pieniądze	dinero
  price	cena	precio
  coin	moneta	moneda
  card	karta	tarjeta
  purchase	zakup	compra
  sale	sprzedaż	venta
  customer	klient	cliente
  offer	oferta	oferta
  discount	zniżka	descuento
  receipt	paragon	recibo
  bill	rachunek	cuenta
  change	reszta	cambio
  cash	gotówka	efectivo
  free	za darmo	gratis
  rich	bogaty	rico
  poor	biedny	pobre

  # Months
  January	styczeń	enero
  February	luty	febrero
  March	marzec	marzo
  April	kwiecień	abril
  May	maj	mayo
  June	czerwiec	junio
  July	lipiec	julio
  August	sierpień	agosto
  September	wrzesień	septiembre
  October	październik	octubre
  November	listopad	noviembre
  December	grudzień	diciembre

  # Music
  music	muzyka	música
  song	piosenka	canción
  guitar	gitara	guitarra
  piano	pianino	piano
  violin	skrzypce	violín
  drum	bęben	tambor
  singer	piosenkarz	cantante
  orchestra	orkiestra	orquesta
  concert	koncert	concierto
  movie	film	película
  theater	teatr	teatro
  painting	obraz	cuadro
  dance	taniec	baile
  rhythm	rytm	ritmo
  voice	głos	voz

  # Nature
  sun	słońce	sol
  moon	księżyc	luna
  sky	niebo	cielo
  sea	morze	mar
  river	rzeka	río
  mountain	góra	montaña
  tree	drzewo	árbol
  flower	kwiat	flor
  rain	deszcz	lluvia
  wind	wiatr	viento
  fire	ogień	fuego
  earth	ziemia	tierra
  cloud	chmura	nube
  snow	śnieg	nieve
  ice	lód	hielo
  lake	jezioro	lago
  island	wyspa	isla
  forest	las	bosque
  beach	plaża	playa
  stone	kamień	piedra

  # Numbers
  one	jeden	uno
  two	dwa	dos
  three	trzy	tres
  four	cztery	cuatro
  five	pięć	cinco
  six	sześć	seis
  seven	siedem	siete
  eight	osiem	ocho
  nine	dziewięć	nueve
  ten	dziesięć	diez
  hundred	sto	cien
  thousand	tysiąc	mil
  eleven	jedenaście	once
  twelve	dwanaście	doce
  twenty	dwadzieścia	veinte
  thirty	trzydzieści	treinta
  forty	czterdzieści	cuarenta
  fifty	pięćdziesiąt	cincuenta
  zero	zero	cero
  million	milion	millón

  # Office
  office	biuro	oficina
  meeting	spotkanie	reunión
  document	dokument	documento
  report	raport	informe
  project	projekt	proyecto
  contract	kontrakt	contrato
  salary	pensja	salario
  employee	pracownik	empleado
  company	firma	empresa
  planner	terminarz	agenda
  printer	drukarka	impresora
  desk	biurko	escritorio
  folder	teczka	carpeta
  stamp	pieczęć	sello
  signature	podpis	firma

  # People
  man	mężczyzna	hombre
  woman	kobieta	mujer
  person	osoba	persona
  people	ludzie	gente
  friend	przyjaciel	amigo
  female friend	przyjaciółka	amiga
  neighbor	sąsiad	vecino
  boyfriend	chłopak	novio
  girlfriend	dziewczyna	novia
  sir	pan	señor
  madam	pani	señora
  adult	dorosły	adulto
  young man	młodzieniec	joven
  couple	para	pareja

  # Questions
  what	co	qué
  who	kto	quién
  where	gdzie	dónde
  when	kiedy	cuándo
  how	jak	cómo
  why	dlaczego	por qué
  which	który	cuál
  how much	ile	cuánto
  yes	tak	sí
  no	nie	no
  maybe	może	quizás
  because	ponieważ	porque

  # School
  school	szkoła	escuela
  book	książka	libro
  pencil	ołówek	lápiz
  pen	długopis	bolígrafo
  notebook	zeszyt	cuaderno
  paper	papier	papel
  board	tablica	pizarra
  pupil	uczeń	alumno
  student	student	estudiante
  exam	egzamin	examen
  lesson	lekcja	lección
  task	zadanie	tarea
  ruler	linijka	regla
  eraser	gumka	goma
  backpack	plecak	mochila
  grade	ocena	nota

  # Sports
  sport	sport	deporte
  football	piłka nożna	fútbol
  basketball	koszykówka	baloncesto
  tennis	tenis	tenis
  swimming	pływanie	natación
  cycling	kolarstwo	ciclismo
  boxing	boks	boxeo
  gym	siłownia	gimnasio
  team	drużyna	equipo
  player	gracz	jugador
  ball	piłka	pelota
  match	mecz	partido
  winner	zwycięzca	ganador
  coach	trener	entrenador
  medal	medal	medalla
  champion	mistrz	campeón

  # Technology
  computer	komputer	ordenador
  telephone	telefon	teléfono
  mobile phone	telefon komórkowy	teléfono móvil
  internet	internet	internet
  screen	ekran	pantalla
  keyboard	klawiatura	teclado
  camera	kamera	cámara
  battery	bateria	batería
  program	program	programa
  app	aplikacja	aplicación
  file	plik	archivo
  password	hasło	contraseña
  email	e-mail	correo electrónico
  message	wiadomość	mensaje
  network	sieć	red
  cable	kabel	cable

  # Time
  day	dzień	día
  night	noc	noche
  week	tydzień	semana
  month	miesiąc	mes
  year	rok	año
  hour	godzina	hora
  minute	minuta	minuto
  morning	poranek	mañana
  evening	wieczór	tarde
  today	dzisiaj	hoy
  yesterday	wczoraj	ayer
  time	czas	tiempo
  second	sekunda	segundo
  moment	chwila	momento
  century	wiek	siglo
  now	teraz	ahora
  early	wcześnie	temprano
  always	zawsze	siempre
  never	nigdy	nunca
  soon	wkrótce	pronto

  # Travel
  trip	podróż	viaje
  car	samochód	coche
  bus	autobus	autobús
  train	pociąg	tren
  plane	samolot	avión
  ship	statek	barco
  bicycle	rower	bicicleta
  taxi	taksówka	taxi
  ticket	bilet	billete
  suitcase	walizka	maleta
  passport	paszport	pasaporte
  hotel	hotel	hotel
  airport	lotnisko	aeropuerto
  road	droga	carretera
  map	mapa	mapa
  border	granica	frontera

  # Verbs II
  to come	przychodzić	venir
  to go out	wychodzić	salir
  to enter	wchodzić	entrar
  to arrive	przybywać	llegar
  to put	kłaść	poner
  to give	dawać	dar
  to take	brać	tomar
  to leave	zostawiać	dejar
  to carry	nieść	llevar
  to start	zaczynać	empezar
  to finish	kończyć	terminar
  to win	wygrywać	ganar
  to lose	przegrywać	perder
  to help	pomagać	ayudar
  to wait	czekać	esperar
  to find	znajdować	encontrar
  to search	szukać	buscar
  to live	żyć	vivir

  # Verbs III
  to want	chcieć	querer
  to need	potrzebować	necesitar
  to know	wiedzieć	saber
  to get to know	poznawać	conocer
  to believe	wierzyć	creer
  to understand	rozumieć	entender
  to remember	pamiętać	recordar
  to forget	zapominać	olvidar
  to feel	czuć	sentir
  to say	mówić	decir
  to ask	pytać	preguntar
  to answer	odpowiadać	responder
  to call	dzwonić	llamar
  to show	pokazywać	mostrar
  to change	zmieniać	cambiar
  to use	używać	usar

  # Weather
  climate	klimat	clima
  heat	upał	calor
  cold	zimno	frío
  temperature	temperatura	temperatura
  storm	burza	tormenta
  fog	mgła	niebla
  thunder	grzmot	trueno
  lightning	błyskawica	relámpago
  humid	wilgotny	húmedo
  dry	suchy	seco
  sunny	słoneczny	soleado
  cloudy	pochmurny	nublado
  hail	grad	granizo
  rainbow	tęcza	arcoíris
  season	pora roku	estación
  degree	stopień	grado
TSV

# --- parse the translation table into trans[theme][english] = [pl, es] ---------
trans = Hash.new { |h, k| h[k] = {} }
current_theme = nil
TRANSLATIONS.each_line do |raw|
  line = raw.rstrip
  next if line.empty?
  if line.start_with?("#")
    current_theme = line.sub(/\A#\s*/, "")
  else
    en, pl, es = line.split("\t")
    trans[current_theme][en] = [ pl, es ]
  end
end

# --- read the authoritative uk/en concepts from the existing uk->en decks ------
uk_en_cols = Collection.joins(:language)
                       .where(languages: { code: "uk" })
                       .where("collections.name LIKE ?", "%(uk->en)%")
                       .order(:name)

concepts = []   # { theme:, uk:, en:, pl:, es: }
missing  = []
uk_en_cols.each do |col|
  theme = col.name.sub(/\s*\(uk->en\)\z/, "")
  col.cards.kept.order(:id).each do |card|
    pl, es = trans.dig(theme, card.back_text)
    if pl.nil? || es.nil?
      missing << "#{theme} / #{card.back_text}"
    else
      concepts << { theme: theme, uk: card.front_text, en: card.back_text, pl: pl, es: es }
    end
  end
end

if missing.any?
  warn "Missing pl/es translations for #{missing.size} concepts:"
  missing.each { |m| warn "  - #{m}" }
  abort "Aborting without writing. Add the translations above and re-run."
end

# --- build the four pairs ------------------------------------------------------
owner = User.where(admin: true).order(:id).first || User.order(:id).first
abort "No user available to own the collections." unless owner

langs = %w[uk en pl es].index_with { |code| Language.find_by!(code: code) }

# [source code, target code, source key, target key]
pairs = [
  [ "uk", "pl", :uk, :pl ],
  [ "pl", "en", :pl, :en ],
  [ "pl", "es", :pl, :es ],
  [ "en", "es", :en, :es ]
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
