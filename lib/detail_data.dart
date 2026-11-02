import 'models/media_model.dart';

// ============================================================
// DATA CONTOH UNTUK HALAMAN DETAIL
// Nanti semua ini bisa dipindah ke database (Firebase).
// Judul yang belum diisi akan memakai data kosong (fallback).
// ============================================================

class CastMember {
  /// Film/Series: nama aktor. Anime: nama karakter.
  final String name;

  /// Film/Series: nama peran. Anime: "Main" / "Supporting".
  final String role;

  /// Khusus anime: nama voice actor dan bahasanya.
  final String? voiceActor;
  final String? language;

  const CastMember({
    required this.name,
    required this.role,
    this.voiceActor,
    this.language,
  });
}

class MediaDetail {
  final String synopsis;
  final String? duration; // contoh: "120 min" atau "12 episodes"
  final int? episodes; // untuk batas progress (series/anime)
  final String creditLabel; // Director / Creator / Studio
  final String? credit;
  final List<String> genres;
  final List<CastMember> cast;

  const MediaDetail({
    required this.synopsis,
    this.duration,
    this.episodes,
    this.creditLabel = 'Director',
    this.credit,
    this.genres = const [],
    this.cast = const [],
  });
}

const Map<String, MediaDetail> _detailByTitle = {
  'oldboy': MediaDetail(
    synopsis:
        'Oh Dae-su diculik dan dikurung selama lima belas tahun tanpa tahu '
        'alasannya. Begitu dibebaskan, ia hanya punya lima hari untuk '
        'menemukan orang yang memenjarakannya.',
    duration: '120 min',
    creditLabel: 'Director',
    credit: 'Park Chan-wook',
    genres: ['Action', 'Drama', 'Mystery'],
    cast: [
      CastMember(name: 'Choi Min-sik', role: 'Oh Dae-su'),
      CastMember(name: 'Yoo Ji-tae', role: 'Lee Woo-jin'),
      CastMember(name: 'Kang Hye-jeong', role: 'Mi-do'),
      CastMember(name: 'Kim Byeong-ok', role: 'Mr. Han'),
    ],
  ),
  'the boys': MediaDetail(
    synopsis:
        'Sekelompok vigilante nekat berusaha menjatuhkan para superhero '
        'korup yang disponsori sebuah korporasi raksasa.',
    creditLabel: 'Creator',
    credit: 'Eric Kripke',
    genres: ['Action', 'Comedy', 'Crime'],
    cast: [
      CastMember(name: 'Karl Urban', role: 'Billy Butcher'),
      CastMember(name: 'Jack Quaid', role: 'Hughie Campbell'),
      CastMember(name: 'Antony Starr', role: 'Homelander'),
      CastMember(name: 'Erin Moriarty', role: 'Starlight'),
    ],
  ),
  'barakamon': MediaDetail(
    synopsis:
        'Seishu Handa, kaligrafer muda yang keras kepala, dikirim ke Pulau '
        'Goto untuk menenangkan diri dan mencari inspirasi baru. Hidup di '
        'desa dan bertemu penduduk yang unik, terutama anak kecil bernama '
        'Naru, pelan-pelan mengubah cara pandangnya.',
    duration: '12 episodes',
    episodes: 12,
    creditLabel: 'Studio',
    credit: 'Kinema Citrus',
    genres: ['Comedy', 'Slice of Life'],
    cast: [
      CastMember(
        name: 'Seishu Handa',
        role: 'Main',
        voiceActor: 'Daisuke Ono',
        language: 'Japanese',
      ),
      CastMember(
        name: 'Naru Kotoishi',
        role: 'Main',
        voiceActor: 'Suzuko Hara',
        language: 'Japanese',
      ),
      CastMember(
        name: 'Miwa Yamamura',
        role: 'Supporting',
        voiceActor: 'Nozomi Furuki',
        language: 'Japanese',
      ),
      CastMember(
        name: 'Tamako Arai',
        role: 'Supporting',
        voiceActor: 'Rumi Okubo',
        language: 'Japanese',
      ),
      CastMember(
        name: 'Hiroshi Kido',
        role: 'Supporting',
        voiceActor: 'Koki Uchiyama',
        language: 'Japanese',
      ),
    ],
  ),
  "fight club": MediaDetail(
    synopsis:
        "Seorang pekerja kantoran yang menderita insomnia bertemu penjual sabun yang karismatik. Keduanya mendirikan klub tarung bawah tanah yang pelan-pelan berubah menjadi sesuatu yang jauh lebih berbahaya.",
    duration: "139 min",
    creditLabel: 'Director',
    credit: "David Fincher",
    genres: ["Drama"],
    cast: [
      CastMember(name: "Brad Pitt", role: "Tyler Durden"),
      CastMember(name: "Edward Norton", role: "The Narrator"),
      CastMember(name: "Helena Bonham Carter", role: "Marla Singer"),
      CastMember(name: "Meat Loaf", role: "Robert Paulson"),
    ],
  ),
  "the truman show": MediaDetail(
    synopsis:
        "Truman Burbank menjalani hidup yang tampak biasa, tanpa tahu bahwa seluruh hidupnya adalah acara televisi yang disiarkan ke seluruh dunia. Ia mulai curiga bahwa dunianya tidak senyata yang ia kira.",
    duration: "103 min",
    creditLabel: 'Director',
    credit: "Peter Weir",
    genres: ["Comedy", "Drama"],
    cast: [
      CastMember(name: "Jim Carrey", role: "Truman Burbank"),
      CastMember(name: "Laura Linney", role: "Meryl Burbank"),
      CastMember(name: "Noah Emmerich", role: "Marlon"),
      CastMember(name: "Ed Harris", role: "Christof"),
    ],
  ),
  "hereditary": MediaDetail(
    synopsis:
        "Setelah kematian sang nenek, keluarga Graham mulai menemukan hal-hal yang semakin mengerikan tentang garis keturunan mereka dan nasib yang menunggu.",
    duration: "127 min",
    creditLabel: 'Director',
    credit: "Ari Aster",
    genres: ["Drama", "Horror", "Mystery"],
    cast: [
      CastMember(name: "Toni Collette", role: "Annie Graham"),
      CastMember(name: "Alex Wolff", role: "Peter Graham"),
      CastMember(name: "Milly Shapiro", role: "Charlie Graham"),
      CastMember(name: "Gabriel Byrne", role: "Steve Graham"),
    ],
  ),
  "the dark knight": MediaDetail(
    synopsis:
        "Batman, Jim Gordon, dan Harvey Dent berusaha membersihkan Gotham dari kejahatan terorganisir. Namun muncul penjahat baru yang menyebarkan kekacauan dan menguji batas mereka semua.",
    duration: "152 min",
    creditLabel: 'Director',
    credit: "Christopher Nolan",
    genres: ["Action", "Crime", "Drama"],
    cast: [
      CastMember(name: "Christian Bale", role: "Bruce Wayne / Batman"),
      CastMember(name: "Heath Ledger", role: "Joker"),
      CastMember(name: "Aaron Eckhart", role: "Harvey Dent"),
      CastMember(name: "Michael Caine", role: "Alfred Pennyworth"),
    ],
  ),
  "midsommar": MediaDetail(
    synopsis:
        "Dani yang sedang berduka ikut pacarnya dan teman-temannya ke festival musim panas di desa terpencil di Swedia. Perayaan yang tampak damai itu perlahan berubah menjadi mimpi buruk.",
    duration: "148 min",
    creditLabel: 'Director',
    credit: "Ari Aster",
    genres: ["Drama", "Horror", "Mystery"],
    cast: [
      CastMember(name: "Florence Pugh", role: "Dani"),
      CastMember(name: "Jack Reynor", role: "Christian"),
      CastMember(name: "William Jackson Harper", role: "Josh"),
      CastMember(name: "Vilhelm Blomgren", role: "Pelle"),
    ],
  ),
  "500 days of summer": MediaDetail(
    synopsis:
        "Tom, penulis kartu ucapan yang romantis, jatuh cinta pada Summer yang tidak percaya cinta sejati. Film ini menelusuri hubungan mereka selama 500 hari dengan urutan waktu yang melompat-lompat.",
    duration: "95 min",
    creditLabel: 'Director',
    credit: "Marc Webb",
    genres: ["Comedy", "Drama", "Romance"],
    cast: [
      CastMember(name: "Joseph Gordon-Levitt", role: "Tom Hansen"),
      CastMember(name: "Zooey Deschanel", role: "Summer Finn"),
      CastMember(name: "Geoffrey Arend", role: "McKenzie"),
      CastMember(name: "Chloe Grace Moretz", role: "Rachel Hansen"),
    ],
  ),
  "the shawshank redemption": MediaDetail(
    synopsis:
        "Andy Dufresne, bankir yang dihukum penjara seumur hidup, menjalin persahabatan dengan sesama napi bernama Red. Selama puluhan tahun mereka bertahan dan menjaga harapan di balik tembok penjara.",
    duration: "142 min",
    creditLabel: 'Director',
    credit: "Frank Darabont",
    genres: ["Drama"],
    cast: [
      CastMember(name: "Tim Robbins", role: "Andy Dufresne"),
      CastMember(name: "Morgan Freeman", role: "Ellis Boyd Redding"),
      CastMember(name: "Bob Gunton", role: "Warden Norton"),
      CastMember(name: "William Sadler", role: "Heywood"),
    ],
  ),
  "the godfather": MediaDetail(
    synopsis:
        "Patriark keluarga mafia Corleone menyerahkan kekuasaan kepada putra bungsunya yang awalnya enggan terlibat. Sang putra perlahan berubah menjadi pemimpin yang dingin.",
    duration: "175 min",
    creditLabel: 'Director',
    credit: "Francis Ford Coppola",
    genres: ["Crime", "Drama"],
    cast: [
      CastMember(name: "Marlon Brando", role: "Vito Corleone"),
      CastMember(name: "Al Pacino", role: "Michael Corleone"),
      CastMember(name: "James Caan", role: "Sonny Corleone"),
      CastMember(name: "Robert Duvall", role: "Tom Hagen"),
    ],
  ),
  "pulp fiction": MediaDetail(
    synopsis:
        "Beberapa kisah kriminal di Los Angeles saling bersilangan: dua pembunuh bayaran, seorang petinju, dan istri seorang bos gangster dengan urutan cerita yang tidak lurus.",
    duration: "154 min",
    creditLabel: 'Director',
    credit: "Quentin Tarantino",
    genres: ["Crime", "Drama"],
    cast: [
      CastMember(name: "John Travolta", role: "Vincent Vega"),
      CastMember(name: "Samuel L. Jackson", role: "Jules Winnfield"),
      CastMember(name: "Uma Thurman", role: "Mia Wallace"),
      CastMember(name: "Bruce Willis", role: "Butch Coolidge"),
    ],
  ),
  "forrest gump": MediaDetail(
    synopsis:
        "Forrest, pria baik hati dengan IQ rendah, tanpa sengaja ikut dalam banyak peristiwa besar Amerika selama beberapa dekade, sambil terus mencintai teman masa kecilnya, Jenny.",
    duration: "142 min",
    creditLabel: 'Director',
    credit: "Robert Zemeckis",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Tom Hanks", role: "Forrest Gump"),
      CastMember(name: "Robin Wright", role: "Jenny Curran"),
      CastMember(name: "Gary Sinise", role: "Lt. Dan Taylor"),
      CastMember(name: "Sally Field", role: "Mrs. Gump"),
    ],
  ),
  "inception": MediaDetail(
    synopsis:
        "Dom Cobb adalah pencuri yang mencuri rahasia lewat mimpi. Ia mendapat tawaran terakhir yang mustahil: bukan mencuri ide, melainkan menanamkannya ke pikiran seseorang.",
    duration: "148 min",
    creditLabel: 'Director',
    credit: "Christopher Nolan",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Leonardo DiCaprio", role: "Dom Cobb"),
      CastMember(name: "Joseph Gordon-Levitt", role: "Arthur"),
      CastMember(name: "Elliot Page", role: "Ariadne"),
      CastMember(name: "Tom Hardy", role: "Eames"),
    ],
  ),
  "interstellar": MediaDetail(
    synopsis:
        "Saat Bumi semakin tidak layak huni, seorang mantan pilot memimpin ekspedisi lewat lubang cacing untuk mencari planet baru bagi umat manusia.",
    duration: "169 min",
    creditLabel: 'Director',
    credit: "Christopher Nolan",
    genres: ["Adventure", "Drama", "Sci-Fi"],
    cast: [
      CastMember(name: "Matthew McConaughey", role: "Joseph Cooper"),
      CastMember(name: "Anne Hathaway", role: "Brand"),
      CastMember(name: "Jessica Chastain", role: "Murph"),
      CastMember(name: "Michael Caine", role: "Professor Brand"),
    ],
  ),
  "the matrix": MediaDetail(
    synopsis:
        "Seorang peretas bernama Neo mengetahui bahwa dunia yang ia tinggali adalah simulasi, lalu bergabung dengan pemberontak yang melawan para pengendalinya.",
    duration: "136 min",
    creditLabel: 'Director',
    credit: "Lana Wachowski, Lilly Wachowski",
    genres: ["Action", "Sci-Fi"],
    cast: [
      CastMember(name: "Keanu Reeves", role: "Neo"),
      CastMember(name: "Laurence Fishburne", role: "Morpheus"),
      CastMember(name: "Carrie-Anne Moss", role: "Trinity"),
      CastMember(name: "Hugo Weaving", role: "Agent Smith"),
    ],
  ),
  "parasite": MediaDetail(
    synopsis:
        "Keluarga miskin Kim satu per satu menyusup bekerja di rumah keluarga kaya Park. Hubungan yang tampak menguntungkan itu mulai berubah menjadi tak terduga.",
    duration: "132 min",
    creditLabel: 'Director',
    credit: "Bong Joon Ho",
    genres: ["Drama", "Thriller"],
    cast: [
      CastMember(name: "Song Kang-ho", role: "Kim Ki-taek"),
      CastMember(name: "Choi Woo-shik", role: "Kim Ki-woo"),
      CastMember(name: "Park So-dam", role: "Kim Ki-jung"),
      CastMember(name: "Lee Sun-kyun", role: "Park Dong-ik"),
    ],
  ),
  "gladiator": MediaDetail(
    synopsis:
        "Jenderal Romawi Maximus dikhianati dan dijadikan budak, lalu bangkit sebagai gladiator demi membalas dendam pada kaisar yang membunuh keluarganya.",
    duration: "155 min",
    creditLabel: 'Director',
    credit: "Ridley Scott",
    genres: ["Action", "Adventure", "Drama"],
    cast: [
      CastMember(name: "Russell Crowe", role: "Maximus"),
      CastMember(name: "Joaquin Phoenix", role: "Commodus"),
      CastMember(name: "Connie Nielsen", role: "Lucilla"),
      CastMember(name: "Oliver Reed", role: "Proximo"),
    ],
  ),
  "titanic": MediaDetail(
    synopsis:
        "Kisah cinta antara seniman miskin dan gadis bangsawan di atas kapal Titanic dalam pelayaran perdananya, sebelum kapal itu menabrak gunung es.",
    duration: "194 min",
    creditLabel: 'Director',
    credit: "James Cameron",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Leonardo DiCaprio", role: "Jack Dawson"),
      CastMember(name: "Kate Winslet", role: "Rose DeWitt Bukater"),
      CastMember(name: "Billy Zane", role: "Cal Hockley"),
      CastMember(name: "Kathy Bates", role: "Molly Brown"),
    ],
  ),
  "joker": MediaDetail(
    synopsis:
        "Arthur Fleck, badut yang hidup terpinggirkan di Gotham, perlahan terdorong oleh kota yang kejam hingga berubah menjadi sosok yang kelak dikenal sebagai Joker.",
    duration: "122 min",
    creditLabel: 'Director',
    credit: "Todd Phillips",
    genres: ["Crime", "Drama", "Thriller"],
    cast: [
      CastMember(name: "Joaquin Phoenix", role: "Arthur Fleck"),
      CastMember(name: "Robert De Niro", role: "Murray Franklin"),
      CastMember(name: "Zazie Beetz", role: "Sophie Dumond"),
      CastMember(name: "Frances Conroy", role: "Penny Fleck"),
    ],
  ),
  "la la land": MediaDetail(
    synopsis:
        "Mia yang bercita-cita jadi aktris dan Sebastian, pianis jazz, jatuh cinta di Los Angeles sambil mengejar impian masing-masing yang mulai menguji hubungan mereka.",
    duration: "128 min",
    creditLabel: 'Director',
    credit: "Damien Chazelle",
    genres: ["Comedy", "Drama", "Music"],
    cast: [
      CastMember(name: "Ryan Gosling", role: "Sebastian"),
      CastMember(name: "Emma Stone", role: "Mia"),
      CastMember(name: "John Legend", role: "Keith"),
      CastMember(name: "Rosemarie DeWitt", role: "Laura"),
    ],
  ),
  "whiplash": MediaDetail(
    synopsis:
        "Andrew, drummer muda yang ambisius, masuk ke konservatori ternama dan berhadapan dengan instruktur yang menekan murid-muridnya sampai batas.",
    duration: "106 min",
    creditLabel: 'Director',
    credit: "Damien Chazelle",
    genres: ["Drama", "Music"],
    cast: [
      CastMember(name: "Miles Teller", role: "Andrew Neiman"),
      CastMember(name: "J.K. Simmons", role: "Terence Fletcher"),
      CastMember(name: "Paul Reiser", role: "Jim Neiman"),
      CastMember(name: "Melissa Benoist", role: "Nicole"),
    ],
  ),
  "get out": MediaDetail(
    synopsis:
        "Chris, pria kulit hitam, berkunjung ke rumah orang tua pacarnya yang berkulit putih. Awalnya semua tampak ramah, tetapi ia mulai menemukan hal-hal yang janggal.",
    duration: "104 min",
    creditLabel: 'Director',
    credit: "Jordan Peele",
    genres: ["Horror", "Mystery", "Thriller"],
    cast: [
      CastMember(name: "Daniel Kaluuya", role: "Chris Washington"),
      CastMember(name: "Allison Williams", role: "Rose Armitage"),
      CastMember(name: "Catherine Keener", role: "Missy Armitage"),
      CastMember(name: "Bradley Whitford", role: "Dean Armitage"),
    ],
  ),
  "se7en": MediaDetail(
    synopsis:
        "Dua detektif, satu veteran yang hampir pensiun dan satu yang baru, memburu pembunuh berantai yang menjadikan tujuh dosa mematikan sebagai pola kejahatannya.",
    duration: "127 min",
    creditLabel: 'Director',
    credit: "David Fincher",
    genres: ["Crime", "Drama", "Mystery"],
    cast: [
      CastMember(name: "Morgan Freeman", role: "William Somerset"),
      CastMember(name: "Brad Pitt", role: "David Mills"),
      CastMember(name: "Gwyneth Paltrow", role: "Tracy Mills"),
      CastMember(name: "Kevin Spacey", role: "John Doe"),
    ],
  ),
  "schindler's list": MediaDetail(
    synopsis:
        "Pengusaha Oskar Schindler menyelamatkan lebih dari seribu orang Yahudi dengan mempekerjakan mereka di pabriknya selama Perang Dunia II.",
    duration: "195 min",
    creditLabel: 'Director',
    credit: "Steven Spielberg",
    genres: ["Biography", "Drama", "History"],
    cast: [
      CastMember(name: "Liam Neeson", role: "Oskar Schindler"),
      CastMember(name: "Ben Kingsley", role: "Itzhak Stern"),
      CastMember(name: "Ralph Fiennes", role: "Amon Goeth"),
      CastMember(name: "Caroline Goodall", role: "Emilie Schindler"),
    ],
  ),
  "léon: the professional": MediaDetail(
    synopsis:
        "Léon, pembunuh bayaran yang hidup menyendiri, menampung Mathilda, gadis 12 tahun yang keluarganya dibunuh polisi korup. Ia pun mengajarinya cara bertahan hidup.",
    duration: "110 min",
    creditLabel: 'Director',
    credit: "Luc Besson",
    genres: ["Action", "Crime", "Drama"],
    cast: [
      CastMember(name: "Jean Reno", role: "Léon"),
      CastMember(name: "Gary Oldman", role: "Norman Stansfield"),
      CastMember(name: "Natalie Portman", role: "Mathilda"),
      CastMember(name: "Danny Aiello", role: "Tony"),
    ],
  ),
  "eternal sunshine of the spotless mind": MediaDetail(
    synopsis:
        "Setelah putus, Joel mengetahui mantannya menghapus ingatan tentang dirinya lewat prosedur medis. Ia memutuskan melakukan hal yang sama, tetapi di tengah proses ia mulai menyesal.",
    duration: "108 min",
    creditLabel: 'Director',
    credit: "Michel Gondry",
    genres: ["Drama", "Romance", "Sci-Fi"],
    cast: [
      CastMember(name: "Jim Carrey", role: "Joel Barish"),
      CastMember(name: "Kate Winslet", role: "Clementine Kruczynski"),
      CastMember(name: "Kirsten Dunst", role: "Mary"),
      CastMember(name: "Mark Ruffalo", role: "Stan"),
    ],
  ),
  "everything everywhere all at once": MediaDetail(
    synopsis:
        "Evelyn, pemilik binatu yang kewalahan mengurus pajak dan keluarga, tiba-tiba harus menjelajahi berbagai semesta paralel untuk menyelamatkan dunia.",
    duration: "139 min",
    creditLabel: 'Director',
    credit: "Daniel Kwan, Daniel Scheinert",
    genres: ["Action", "Adventure", "Comedy"],
    cast: [
      CastMember(name: "Michelle Yeoh", role: "Evelyn Wang"),
      CastMember(name: "Stephanie Hsu", role: "Joy Wang"),
      CastMember(name: "Ke Huy Quan", role: "Waymond Wang"),
      CastMember(name: "Jamie Lee Curtis", role: "Deirdre Beaubeirdre"),
    ],
  ),
  "oppenheimer": MediaDetail(
    synopsis:
        "Kisah J. Robert Oppenheimer, fisikawan yang memimpin Proyek Manhattan untuk menciptakan bom atom, dan beban moral serta politik yang ia hadapi sesudahnya.",
    duration: "180 min",
    creditLabel: 'Director',
    credit: "Christopher Nolan",
    genres: ["Biography", "Drama", "History"],
    cast: [
      CastMember(name: "Cillian Murphy", role: "J. Robert Oppenheimer"),
      CastMember(name: "Emily Blunt", role: "Kitty Oppenheimer"),
      CastMember(name: "Matt Damon", role: "Leslie Groves"),
      CastMember(name: "Robert Downey Jr.", role: "Lewis Strauss"),
    ],
  ),
  "dune": MediaDetail(
    synopsis:
        "Paul Atreides, pewaris keluarga bangsawan, dikirim ke planet gurun Arrakis yang menjadi sumber rempah paling berharga di alam semesta, dan terseret ke dalam perebutan kekuasaan.",
    duration: "155 min",
    creditLabel: 'Director',
    credit: "Denis Villeneuve",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Timothée Chalamet", role: "Paul Atreides"),
      CastMember(name: "Rebecca Ferguson", role: "Lady Jessica"),
      CastMember(name: "Oscar Isaac", role: "Duke Leto Atreides"),
      CastMember(name: "Zendaya", role: "Chani"),
    ],
  ),
  "train to busan": MediaDetail(
    synopsis:
        "Wabah zombie menyebar ke seluruh Korea Selatan saat sekelompok penumpang berada di kereta cepat menuju Busan, dan mereka harus bertahan hidup di dalamnya.",
    duration: "118 min",
    creditLabel: 'Director',
    credit: "Yeon Sang-ho",
    genres: ["Action", "Horror", "Thriller"],
    cast: [
      CastMember(name: "Gong Yoo", role: "Seok-woo"),
      CastMember(name: "Ma Dong-seok", role: "Sang-hwa"),
      CastMember(name: "Jung Yu-mi", role: "Seong-kyeong"),
      CastMember(name: "Kim Su-an", role: "Su-an"),
    ],
  ),
  "memories of murder": MediaDetail(
    synopsis:
        "Di sebuah desa di Korea tahun 1980-an, dua detektif dengan cara kerja berbeda memburu pembunuh berantai yang menghantui warga.",
    duration: "131 min",
    creditLabel: 'Director',
    credit: "Bong Joon Ho",
    genres: ["Crime", "Drama", "Mystery"],
    cast: [
      CastMember(name: "Song Kang-ho", role: "Park Doo-man"),
      CastMember(name: "Kim Sang-kyung", role: "Seo Tae-yoon"),
      CastMember(name: "Kim Roi-ha", role: "Cho Yong-koo"),
      CastMember(name: "Song Jae-ho", role: "Shin Dong-chul"),
    ],
  ),
  "pengabdi setan": MediaDetail(
    synopsis:
        "Sepeninggal sang ibu yang lama sakit, satu keluarga mulai diganggu kejadian-kejadian menyeramkan di rumah mereka.",
    duration: "107 min",
    creditLabel: 'Director',
    credit: "Joko Anwar",
    genres: ["Horror", "Mystery"],
    cast: [
      CastMember(name: "Tara Basro", role: "Rini"),
      CastMember(name: "Bront Palarae", role: "Bapak"),
      CastMember(name: "Endy Arfian", role: "Tony"),
      CastMember(name: "Ayu Laksmi", role: "Mawarni Suwono"),
    ],
  ),
  "laskar pelangi": MediaDetail(
    synopsis:
        "Di Belitung pada tahun 1970-an, sepuluh murid dan dua guru berjuang menjaga sekolah Muhammadiyah mereka tetap berdiri di tengah kemiskinan, sambil memelihara mimpi.",
    duration: "124 min",
    creditLabel: 'Director',
    credit: "Riri Riza",
    genres: ["Adventure", "Drama", "Family"],
    cast: [
      CastMember(name: "Cut Mini", role: "Bu Muslimah"),
      CastMember(name: "Ikranagara", role: "Pak Harfan"),
      CastMember(name: "Zulfanny", role: "Ikal"),
      CastMember(name: "Ferdian", role: "Lintang"),
    ],
  ),
  "ada apa dengan cinta?": MediaDetail(
    synopsis:
        "Cinta, siswi SMA yang aktif menulis, bertemu Rangga, cowok pendiam yang gemar puisi. Pertemuan mereka mengubah pandangan masing-masing tentang persahabatan dan cinta.",
    duration: "112 min",
    creditLabel: 'Director',
    credit: "Rudi Soedjarwo",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Dian Sastrowardoyo", role: "Cinta"),
      CastMember(name: "Nicholas Saputra", role: "Rangga"),
      CastMember(name: "Adinia Wirasti", role: "Karmen"),
      CastMember(name: "Titi Kamal", role: "Maura"),
    ],
  ),
  "before sunrise": MediaDetail(
    synopsis:
        "Jesse dan Celine, dua orang asing, bertemu di kereta dan menghabiskan satu malam berjalan keliling Wina sambil berbincang tentang hidup dan cinta.",
    duration: "101 min",
    creditLabel: 'Director',
    credit: "Richard Linklater",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Ethan Hawke", role: "Jesse"),
      CastMember(name: "Julie Delpy", role: "Céline"),
    ],
  ),
  "jatuh cinta seperti di film film": MediaDetail(
    synopsis:
        "Bagus, penulis skenario, bertemu kembali dengan Hana, teman SMA yang ia sukai dan masih berduka setelah kehilangan suaminya. Ia berharap bisa membuat Hana jatuh cinta lagi lewat naskah film yang ia tulis.",
    duration: "118 min",
    creditLabel: 'Director',
    credit: "Yandy Laurens",
    genres: ["Comedy", "Drama", "Romance"],
    cast: [
      CastMember(name: "Ringgo Agus Rahman", role: "Bagus"),
      CastMember(name: "Nirina Zubir", role: "Hana"),
      CastMember(name: "Sheila Dara", role: "Cheline"),
      CastMember(name: "Alex Abbad", role: "Yoram Andaman"),
    ],
  ),
 "twenty five twenty one": MediaDetail(
    synopsis:
        "Pada tahun 1998, Na Hee-do, atlet anggar remaja yang gigih, bertemu Baek Yi-jin, pemuda yang kehilangan segalanya karena krisis ekonomi. Persahabatan dan cinta mereka tumbuh di tengah mimpi dan kenyataan.",
    duration: "16 episodes",
    episodes: 16,
    creditLabel: "Director",
    credit: "Jung Ji-hyun",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Kim Tae-ri", role: "Na Hee-do"),
      CastMember(name: "Nam Joo-hyuk", role: "Baek Yi-jin"),
      CastMember(name: "Kim Ji-yeon (Bona)", role: "Ko Yu-Rim"),
      CastMember(name: "Choi Hyun-wook", role: "Moon Ji-woong"),
      CastMember(name: "Lee Joo-myung", role: "Ji Seung-wan"),
    ],
  ),
  "breaking bad": MediaDetail(
    synopsis:
        "Walter White, guru kimia SMA yang didiagnosis kanker paru-paru, mulai membuat dan menjual metamfetamin bersama mantan muridnya demi masa depan finansial keluarganya.",
    duration: "62 episodes",
    episodes: 62,
    creditLabel: "Creator",
    credit: "Vince Gilligan",
    genres: ["Crime", "Drama", "Thriller"],
    cast: [
      CastMember(name: "Bryan Cranston", role: "Walter White"),
      CastMember(name: "Aaron Paul", role: "Jesse Pinkman"),
      CastMember(name: "Anna Gunn", role: "Skyler White"),
      CastMember(name: "Dean Norris", role: "Hank Schrader"),
    ],
  ),
  "loki": MediaDetail(
    synopsis:
        "Setelah mencuri Tesseract, Loki ditangkap oleh Time Variance Authority, lembaga yang menjaga garis waktu. Ia ditawari pilihan: dihapus dari eksistensi atau membantu menghentikan ancaman yang lebih besar.",
    creditLabel: "Creator",
    credit: "Michael Waldron",
    genres: ["Action", "Adventure", "Fantasy"],
    cast: [
      CastMember(name: "Tom Hiddleston", role: "Loki"),
      CastMember(name: "Owen Wilson", role: "Mobius M. Mobius"),
      CastMember(name: "Sophia Di Martino", role: "Sylvie"),
      CastMember(name: "Gugu Mbatha-Raw", role: "Ravonna Renslayer"),
    ],
  ),
  "sherlock": MediaDetail(
    synopsis:
        "Detektif konsultan Sherlock Holmes dan mantan dokter militer John Watson memecahkan kasus-kasus rumit di London masa kini.",
    creditLabel: "Creator",
    credit: "Mark Gatiss, Steven Moffat",
    genres: ["Crime", "Drama", "Mystery"],
    cast: [
      CastMember(name: "Benedict Cumberbatch", role: "Sherlock Holmes"),
      CastMember(name: "Martin Freeman", role: "Dr. John Watson"),
      CastMember(name: "Una Stubbs", role: "Mrs. Hudson"),
      CastMember(name: "Rupert Graves", role: "Inspektur Lestrade"),
    ],
  ),
  "can this love be translated": MediaDetail(
    synopsis:
        "Seorang penerjemah poliglot bekerja untuk selebriti global. Saat mereka berkeliling dunia menggarap sebuah acara TV, hubungan profesional keduanya perlahan berubah menjadi romansa yang tak terduga.",
    duration: "12 episodes",
    episodes: 12,
    creditLabel: "Director",
    credit: "Yoo Young-eun",
    genres: ["Comedy", "Drama", "Romance"],
    cast: [
      CastMember(name: "Kim Seon-ho", role: "Joo Ho-jin"),
      CastMember(name: "Go Youn-jung", role: "Cha Mu-hee"),
      CastMember(name: "Sota Fukushi", role: "Hiro Kurosawa"),
      CastMember(name: "Lee Yi-dam", role: "Shin Ji-seon"),
    ],
  ),
  "teach you a lesson": MediaDetail(
    synopsis:
        "Saat rasa hormat di sekolah runtuh, para inspektur nonkonvensional dari lembaga perlindungan hak pendidikan turun tangan menegakkan ketertiban dengan pelajaran tegas yang tidak ada di buku. Diadaptasi dari webtoon populer.",
    duration: "10 episodes",
    episodes: 10,
    creditLabel: "Creator",
    credit: "Hong Jong-chan, Lee Nam-kyu, Kim Da-hee",
    genres: ["Action", "Drama"],
    cast: [
      CastMember(name: "Kim Mu-yeol", role: "Na Hwa-jin"),
      CastMember(name: "Lee Sung-min", role: "P.O"),
      CastMember(name: "Choi Ga-yoon", role: "Ha Young"),
    ],
  ),
  "peaky blinders": MediaDetail(
    synopsis:
        "Geng Peaky Blinders pimpinan Thomas Shelby merajai dunia kriminal Birmingham setelah Perang Dunia I, sambil terus mengincar kekuasaan yang lebih besar.",
    duration: "36 episodes",
    episodes: 36,
    creditLabel: "Creator",
    credit: "Steven Knight",
    genres: ["Crime", "Drama"],
    cast: [
      CastMember(name: "Cillian Murphy", role: "Thomas Shelby"),
      CastMember(name: "Paul Anderson", role: "Arthur Shelby"),
      CastMember(name: "Helen McCrory", role: "Polly Gray"),
      CastMember(name: "Sophie Rundle", role: "Ada Shelby"),
    ],
  ),
  "game of thrones": MediaDetail(
    synopsis:
        "Beberapa keluarga bangsawan di benua Westeros berebut Tahta Besi, sementara ancaman kuno bangkit dari utara.",
    duration: "73 episodes",
    episodes: 73,
    creditLabel: "Creator",
    credit: "David Benioff, D. B. Weiss",
    genres: ["Action", "Adventure", "Drama"],
    cast: [
      CastMember(name: "Emilia Clarke", role: "Daenerys Targaryen"),
      CastMember(name: "Kit Harington", role: "Jon Snow"),
      CastMember(name: "Peter Dinklage", role: "Tyrion Lannister"),
      CastMember(name: "Lena Headey", role: "Cersei Lannister"),
    ],
  ),
  "stranger things": MediaDetail(
    synopsis:
        "Di kota kecil Hawkins, hilangnya seorang anak membuka rahasia eksperimen pemerintah dan dimensi lain yang berbahaya, dan sekelompok anak bersama seorang gadis berkekuatan khusus berusaha menghentikannya.",
    creditLabel: "Creator",
    credit: "The Duffer Brothers",
    genres: ["Drama", "Fantasy", "Horror"],
    cast: [
      CastMember(name: "Millie Bobby Brown", role: "Eleven"),
      CastMember(name: "Finn Wolfhard", role: "Mike Wheeler"),
      CastMember(name: "Winona Ryder", role: "Joyce Byers"),
      CastMember(name: "David Harbour", role: "Jim Hopper"),
    ],
  ),
  "the last of us": MediaDetail(
    synopsis:
        "Dua puluh tahun setelah infeksi jamur mengubah manusia menjadi makhluk mematikan, Joel ditugasi mengantar gadis remaja bernama Ellie melintasi Amerika yang hancur.",
    creditLabel: "Creator",
    credit: "Craig Mazin, Neil Druckmann",
    genres: ["Action", "Adventure", "Drama"],
    cast: [
      CastMember(name: "Pedro Pascal", role: "Joel Miller"),
      CastMember(name: "Bella Ramsey", role: "Ellie"),
      CastMember(name: "Gabriel Luna", role: "Tommy Miller"),
      CastMember(name: "Anna Torv", role: "Tess"),
    ],
  ),
  "chernobyl": MediaDetail(
    synopsis:
        "Drama sejarah tentang bencana nuklir Chernobyl tahun 1986 dan upaya orang-orang yang berusaha mengendalikan dampaknya, serta pihak-pihak yang menutupi kebenaran.",
    duration: "5 episodes",
    episodes: 5,
    creditLabel: "Creator",
    credit: "Craig Mazin",
    genres: ["Drama", "History", "Thriller"],
    cast: [
      CastMember(name: "Jared Harris", role: "Valery Legasov"),
      CastMember(name: "Stellan Skarsgård", role: "Boris Shcherbina"),
      CastMember(name: "Emily Watson", role: "Ulana Khomyuk"),
      CastMember(name: "Jessie Buckley", role: "Lyudmilla Ignatenko"),
    ],
  ),
  "black mirror": MediaDetail(
    synopsis:
        "Serial antologi yang menyoroti sisi gelap teknologi modern. Tiap episode punya cerita dan pemeran berbeda.",
    creditLabel: "Creator",
    credit: "Charlie Brooker",
    genres: ["Drama", "Sci-Fi", "Thriller"],
  ),
  "the witcher": MediaDetail(
    synopsis:
        "Geralt dari Rivia, pemburu monster bayaran bermutasi, mencari tempatnya di dunia yang penuh intrik sambil takdirnya terikat dengan penyihir Yennefer dan putri Ciri.",
    creditLabel: "Creator",
    credit: "Lauren Schmidt Hissrich",
    genres: ["Action", "Adventure", "Fantasy"],
    cast: [
      CastMember(name: "Henry Cavill", role: "Geralt dari Rivia"),
      CastMember(name: "Anya Chalotra", role: "Yennefer"),
      CastMember(name: "Freya Allan", role: "Ciri"),
      CastMember(name: "Joey Batey", role: "Jaskier"),
    ],
  ),
  "squid game": MediaDetail(
    synopsis:
        "Ratusan orang yang terjerat utang menerima undangan misterius untuk ikut permainan anak-anak dengan hadiah uang besar, tetapi kalah berarti kehilangan nyawa.",
    creditLabel: "Creator",
    credit: "Hwang Dong-hyuk",
    genres: ["Action", "Drama", "Mystery"],
    cast: [
      CastMember(name: "Lee Jung-jae", role: "Seong Gi-hun"),
      CastMember(name: "Park Hae-soo", role: "Cho Sang-woo"),
      CastMember(name: "Wi Ha-joon", role: "Hwang Jun-ho"),
      CastMember(name: "HoYeon Jung", role: "Kang Sae-byeok"),
    ],
  ),
  "money heist": MediaDetail(
    synopsis:
        "Seorang pria misterius yang dijuluki Profesor merekrut delapan perampok untuk menjalankan perampokan paling berani di Percetakan Uang Kerajaan Spanyol.",
    creditLabel: "Creator",
    credit: "Álex Pina",
    genres: ["Action", "Crime", "Mystery"],
    cast: [
      CastMember(name: "Úrsula Corberó", role: "Tokyo"),
      CastMember(name: "Álvaro Morte", role: "Profesor"),
      CastMember(name: "Pedro Alonso", role: "Berlin"),
      CastMember(name: "Itziar Ituño", role: "Raquel Murillo"),
    ],
  ),
  "narcos": MediaDetail(
    synopsis:
        "Kisah nyata kebangkitan kartel narkoba di Kolombia dan pemburuan para gembong seperti Pablo Escobar oleh aparat penegak hukum.",
    creditLabel: "Creator",
    credit: "Chris Brancato, Carlo Bernard, Doug Miro",
    genres: ["Biography", "Crime", "Drama"],
    cast: [
      CastMember(name: "Wagner Moura", role: "Pablo Escobar"),
      CastMember(name: "Boyd Holbrook", role: "Steve Murphy"),
      CastMember(name: "Pedro Pascal", role: "Javier Peña"),
      CastMember(name: "Joanna Christie", role: "Connie Murphy"),
    ],
  ),
  "dark": MediaDetail(
    synopsis:
        "Hilangnya seorang anak di kota kecil Jerman membuka rahasia empat keluarga yang terhubung lintas generasi dan perjalanan waktu.",
    duration: "26 episodes",
    episodes: 26,
    creditLabel: "Creator",
    credit: "Baran bo Odar, Jantje Friese",
    genres: ["Crime", "Drama", "Mystery"],
    cast: [
      CastMember(name: "Louis Hofmann", role: "Jonas Kahnwald"),
      CastMember(name: "Lisa Vicari", role: "Martha Nielsen"),
      CastMember(name: "Oliver Masucci", role: "Ulrich Nielsen"),
      CastMember(name: "Karoline Eichhorn", role: "Charlotte Doppler"),
    ],
  ),
  "better call saul": MediaDetail(
    synopsis:
        "Kisah Jimmy McGill, pengacara kecil yang berjuang mencari nafkah, dan perubahannya menjadi pengacara licik Saul Goodman.",
    duration: "63 episodes",
    episodes: 63,
    creditLabel: "Creator",
    credit: "Vince Gilligan, Peter Gould",
    genres: ["Crime", "Drama"],
    cast: [
      CastMember(name: "Bob Odenkirk", role: "Jimmy McGill / Saul Goodman"),
      CastMember(name: "Jonathan Banks", role: "Mike Ehrmantraut"),
      CastMember(name: "Rhea Seehorn", role: "Kim Wexler"),
      CastMember(name: "Michael McKean", role: "Chuck McGill"),
    ],
  ),
  "the office (us)": MediaDetail(
    synopsis:
        "Kehidupan sehari-hari para pegawai kantor cabang perusahaan kertas di Scranton, dipotret ala dokumenter dengan humor canggung.",
    duration: "201 episodes",
    episodes: 201,
    creditLabel: "Creator",
    credit: "Greg Daniels",
    genres: ["Comedy"],
    cast: [
      CastMember(name: "Steve Carell", role: "Michael Scott"),
      CastMember(name: "Rainn Wilson", role: "Dwight Schrute"),
      CastMember(name: "John Krasinski", role: "Jim Halpert"),
      CastMember(name: "Jenna Fischer", role: "Pam Beesly"),
    ],
  ),
  "friends": MediaDetail(
    synopsis:
        "Enam sahabat di New York menjalani suka duka pekerjaan, persahabatan, dan percintaan.",
    duration: "236 episodes",
    episodes: 236,
    creditLabel: "Creator",
    credit: "David Crane, Marta Kauffman",
    genres: ["Comedy", "Romance"],
    cast: [
      CastMember(name: "Jennifer Aniston", role: "Rachel Green"),
      CastMember(name: "Courteney Cox", role: "Monica Geller"),
      CastMember(name: "Lisa Kudrow", role: "Phoebe Buffay"),
      CastMember(name: "Matt LeBlanc", role: "Joey Tribbiani"),
      CastMember(name: "Matthew Perry", role: "Chandler Bing"),
      CastMember(name: "David Schwimmer", role: "Ross Geller"),
    ],
  ),
  "succession": MediaDetail(
    synopsis:
        "Keluarga Roy yang mengendalikan konglomerat media global berebut kendali perusahaan saat sang patriark mulai menua.",
    duration: "39 episodes",
    episodes: 39,
    creditLabel: "Creator",
    credit: "Jesse Armstrong",
    genres: ["Comedy", "Drama"],
    cast: [
      CastMember(name: "Brian Cox", role: "Logan Roy"),
      CastMember(name: "Jeremy Strong", role: "Kendall Roy"),
      CastMember(name: "Sarah Snook", role: "Shiv Roy"),
      CastMember(name: "Kieran Culkin", role: "Roman Roy"),
    ],
  ),
  "the mandalorian": MediaDetail(
    synopsis:
        "Seorang pemburu bayaran Mandalorian di tepi galaksi mendapat tugas yang membuatnya melindungi sosok kecil misterius.",
    creditLabel: "Creator",
    credit: "Jon Favreau",
    genres: ["Action", "Adventure", "Fantasy"],
    cast: [
      CastMember(name: "Pedro Pascal", role: "Din Djarin"),
      CastMember(name: "Carl Weathers", role: "Greef Karga"),
      CastMember(name: "Giancarlo Esposito", role: "Moff Gideon"),
      CastMember(name: "Katee Sackhoff", role: "Bo-Katan Kryze"),
    ],
  ),
  "wandavision": MediaDetail(
    synopsis:
        "Wanda Maximoff dan Vision tampak menjalani kehidupan rumah tangga sempurna ala sitkom klasik, tetapi mereka mulai curiga ada yang tidak beres.",
    duration: "9 episodes",
    episodes: 9,
    creditLabel: "Creator",
    credit: "Jac Schaeffer",
    genres: ["Action", "Comedy", "Drama"],
    cast: [
      CastMember(name: "Elizabeth Olsen", role: "Wanda Maximoff"),
      CastMember(name: "Paul Bettany", role: "Vision"),
      CastMember(name: "Kathryn Hahn", role: "Agnes"),
      CastMember(name: "Teyonah Parris", role: "Monica Rambeau"),
    ],
  ),
  "wednesday": MediaDetail(
    synopsis:
        "Wednesday Addams masuk ke Nevermore Academy, sekolah khusus para murid yang berbeda, lalu menyelidiki misteri pembunuhan di sekitarnya.",
    creditLabel: "Creator",
    credit: "Alfred Gough, Miles Millar",
    genres: ["Comedy", "Crime", "Fantasy"],
    cast: [
      CastMember(name: "Jenna Ortega", role: "Wednesday Addams"),
      CastMember(name: "Gwendoline Christie", role: "Larissa Weems"),
      CastMember(name: "Riki Lindhome", role: "Dr. Valerie Kinbott"),
      CastMember(name: "Catherine Zeta-Jones", role: "Morticia Addams"),
    ],
  ),
  "vincenzo": MediaDetail(
    synopsis:
        "Vincenzo Cassano, penasihat mafia Italia keturunan Korea, kembali ke Korea Selatan dan bekerja sama dengan pengacara nyentrik untuk melawan konglomerat jahat.",
    duration: "20 episodes",
    episodes: 20,
    creditLabel: "Director",
    credit: "Kim Hee-won",
    genres: ["Action", "Comedy", "Crime"],
    cast: [
      CastMember(name: "Song Joong-ki", role: "Vincenzo Cassano"),
      CastMember(name: "Jeon Yeo-been", role: "Hong Cha-young"),
      CastMember(name: "Ok Taec-yeon", role: "Jang Han-seo"),
      CastMember(name: "Kim Yeo-jin", role: "Choi Myung-hee"),
    ],
  ),
  "crash landing on you": MediaDetail(
    synopsis:
        "Seorang pewaris konglomerat Korea Selatan mendarat darurat di Korea Utara setelah kecelakaan paralayang, lalu bertemu perwira yang menyembunyikannya.",
    duration: "16 episodes",
    episodes: 16,
    creditLabel: "Director",
    credit: "Lee Jung-hyo",
    genres: ["Comedy", "Drama", "Romance"],
    cast: [
      CastMember(name: "Hyun Bin", role: "Ri Jeong-hyeok"),
      CastMember(name: "Son Ye-jin", role: "Yoon Se-ri"),
      CastMember(name: "Seo Ji-hye", role: "Seo Dan"),
      CastMember(name: "Kim Jung-hyun", role: "Gu Seung-jun"),
    ],
  ),
  "reply 1988": MediaDetail(
    synopsis:
        "Lima keluarga bertetangga di Ssangmun-dong, Seoul, tahun 1988, menjalani persahabatan, cinta pertama, dan kehidupan sehari-hari yang hangat.",
    duration: "20 episodes",
    episodes: 20,
    creditLabel: "Director",
    credit: "Shin Won-ho",
    genres: ["Comedy", "Drama", "Romance"],
    cast: [
      CastMember(name: "Lee Hyeri", role: "Sung Deok-sun"),
      CastMember(name: "Park Bo-gum", role: "Choi Taek"),
      CastMember(name: "Ryu Jun-yeol", role: "Kim Jung-hwan"),
      CastMember(name: "Go Kyung-pyo", role: "Sung Sun-woo"),
    ],
  ),
  "guardian: the lonely and great god": MediaDetail(
    synopsis:
        "Goblin yang abadi mencari pengantin manusia untuk mengakhiri hidupnya, lalu bertemu seorang gadis yang bisa melihat hantu dan seorang malaikat maut yang ikut hidup serumah.",
    duration: "16 episodes",
    episodes: 16,
    creditLabel: "Director",
    credit: "Lee Eung-bok",
    genres: ["Drama", "Fantasy", "Romance"],
    cast: [
      CastMember(name: "Gong Yoo", role: "Kim Shin"),
      CastMember(name: "Kim Go-eun", role: "Ji Eun-tak"),
      CastMember(name: "Lee Dong-wook", role: "Grim Reaper"),
      CastMember(name: "Yoo In-na", role: "Sunny"),
    ],
  ),
  "itaewon class": MediaDetail(
    synopsis:
        "Park Sae-ro-yi, pemuda yang dipenjara karena membela diri, mendirikan restoran kecil di Itaewon dan bertekad menjatuhkan perusahaan makanan besar yang menghancurkan hidupnya.",
    duration: "16 episodes",
    episodes: 16,
    creditLabel: "Director",
    credit: "Kim Sung-yoon",
    genres: ["Drama"],
    cast: [
      CastMember(name: "Park Seo-joon", role: "Park Sae-ro-yi"),
      CastMember(name: "Kim Da-mi", role: "Jo Yi-seo"),
      CastMember(name: "Yoo Jae-myung", role: "Jang Dae-hee"),
      CastMember(name: "Kwon Nara", role: "Oh Soo-ah"),
    ],
  ),
  "all of us are dead": MediaDetail(
    synopsis:
        "Wabah virus zombie menyebar di sebuah SMA di Korea Selatan, dan sekelompok murid terjebak harus bertahan hidup sambil mencari jalan keluar.",
    creditLabel: "Director",
    credit: "Lee Jae-kyoo",
    genres: ["Action", "Drama", "Horror"],
    cast: [
      CastMember(name: "Park Ji-hu", role: "Nam On-jo"),
      CastMember(name: "Yoon Chan-young", role: "Lee Cheong-san"),
      CastMember(name: "Cho Yi-hyun", role: "Choi Nam-ra"),
      CastMember(name: "Lomon", role: "Lee Su-hyeok"),
    ],
  ),
  "true detective": MediaDetail(
    synopsis:
        "Serial antologi kriminal yang tiap musimnya mengikuti detektif berbeda dalam kasus berbeda. Daftar pemeran di bawah mengikuti Musim 1.",
    creditLabel: "Creator",
    credit: "Nic Pizzolatto",
    genres: ["Crime", "Drama", "Mystery"],
    cast: [
      CastMember(name: "Matthew McConaughey", role: "Rust Cohle (S1)"),
      CastMember(name: "Woody Harrelson", role: "Marty Hart (S1)"),
      CastMember(name: "Michelle Monaghan", role: "Maggie Hart (S1)"),
      CastMember(name: "Michael Potts", role: "Maynard Gilbough (S1)"),
    ],
  ),
  "house of the dragon": MediaDetail(
    synopsis:
        "Berlatar sekitar dua ratus tahun sebelum Game of Thrones, serial ini mengisahkan perang saudara keluarga Targaryen yang dikenal sebagai Dance of the Dragons.",
    creditLabel: "Creator",
    credit: "Ryan Condal, George R. R. Martin",
    genres: ["Action", "Adventure", "Drama"],
    cast: [
      CastMember(name: "Paddy Considine", role: "Raja Viserys I"),
      CastMember(name: "Emma D'Arcy", role: "Rhaenyra Targaryen"),
      CastMember(name: "Matt Smith", role: "Daemon Targaryen"),
      CastMember(name: "Olivia Cooke", role: "Alicent Hightower"),
    ],
  ),
  "the bear": MediaDetail(
    synopsis:
        "Seorang koki berbakat kembali ke Chicago untuk mengelola restoran sandwich milik keluarganya yang hampir bangkrut, dan harus menyatukan dapur yang penuh kekacauan.",
    creditLabel: "Creator",
    credit: "Christopher Storer",
    genres: ["Comedy", "Drama"],
    cast: [
      CastMember(name: "Jeremy Allen White", role: "Carmy Berzatto"),
      CastMember(name: "Ayo Edebiri", role: "Sydney Adamu"),
      CastMember(name: "Ebon Moss-Bachrach", role: "Richie Jerimovich"),
      CastMember(name: "Lionel Boyce", role: "Marcus"),
    ],
  ),
  "the good doctor": MediaDetail(
    synopsis:
        "Shindo Minato, seorang autis savant yang memiliki daya ingat dan kemampuan spasial luar biasa, mengalami kesulitan dalam berkomunikasi namun bercita-cita menjadi dokter anak. Ia bergabung dengan departemen pediatri sebuah rumah sakit sebagai residen untuk membantu meningkatkan kualitas hidup anak-anak.",
    duration: "10 episodes",   
    episodes: 10,
    creditLabel: "Creator",
    credit: "David Shore",
    genres: ["Drama"],
    cast: [
      CastMember(name: "Kento Yamazaki", role: "Minato Shindo"),
      CastMember(name: "Akira Emoto", role: "Akira Shiga"),
      CastMember(name: "Juri Ueno", role: "Natsumi Seto"),
      CastMember(name: "Naohito Fujiki", role: "Seiji Takayama"),
    ],
  ),
 "hōkago teibō nisshi": MediaDetail(
    synopsis:
        "Hina Tsurugi pindah ke kota pantai dan terpaksa bergabung dengan klub tanggul. Di sana ia belajar memancing, menyiapkan hasil tangkapan, dan menikmati hidup dekat laut bersama teman-teman barunya.",
    duration: "12 episodes",
    episodes: 12,
    creditLabel: 'Studio',
    credit: "Doga Kobo",
    genres: ["Slice of Life"],
    cast: [
      CastMember(name: "Hina Tsurugi", role: "Main", voiceActor: "Kanon Takao", language: "Japanese"),
      CastMember(name: "Yuuki Kuroiwa", role: "Main", voiceActor: "Yuu Sasahara", language: "Japanese"),
      CastMember(name: "Natsumi Hodaka", role: "Main", voiceActor: "Natsumi Kawaida", language: "Japanese"),
      CastMember(name: "Makoto Oono", role: "Supporting", voiceActor: "Satomi Akesaka", language: "Japanese"),
    ],
  ),
  "haikyuu!!": MediaDetail(
    synopsis:
        "Shoyo Hinata yang bertubuh pendek bermimpi menjadi pemain voli hebat. Ia bergabung dengan tim voli SMA Karasuno dan harus berpasangan dengan rival lamanya, Tobio Kageyama.",
    creditLabel: 'Studio',
    credit: "Production I.G",
    genres: ["Comedy", "Drama", "Sports"],
    cast: [
      CastMember(name: "Shoyo Hinata", role: "Main", voiceActor: "Ayumu Murase", language: "Japanese"),
      CastMember(name: "Tobio Kageyama", role: "Main", voiceActor: "Kaito Ishikawa", language: "Japanese"),
      CastMember(name: "Kei Tsukishima", role: "Main", voiceActor: "Uchiyama Kouki", language: "Japanese"),
      CastMember(name: "Koshi Sugawara", role: "Supporting", voiceActor: "Irino Miyu", language: "Japanese"),
    ],
  ),
  "angel beats!": MediaDetail(
    synopsis:
        "Otonashi kehilangan ingatannya dan terbangun di dunia setelah kematian, tempat para siswa yang meninggal muda melawan Tenshi yang mereka anggap sebagai ancaman.",
    duration: "13 episodes",
    episodes: 13,
    creditLabel: 'Studio',
    credit: "P.A. Works",
    genres: ["Action", "Comedy", "Drama", "Supernatural"],
    cast: [
      CastMember(name: "Yuzuru Otonashi", role: "Main", voiceActor: "Hiroshi Kamiya", language: "Japanese"),
      CastMember(name: "Yuri Nakamura", role: "Main", voiceActor: "Harumi Sakurai", language: "Japanese"),
      CastMember(name: "Kanade Tachibana", role: "Main", voiceActor: "Kana Hanazawa", language: "Japanese"),
      CastMember(name: "Hinata Hideki", role: "Supporting", voiceActor: "Ryouhei Kimura", language: "Japanese"),
    ],
  ),
  "erased": MediaDetail(
    synopsis:
        "Satoru, penulis manga yang kesulitan, punya kemampuan kembali ke masa lalu sesaat sebelum sebuah tragedi. Setelah ibunya dibunuh, ia terlempar ke masa kecilnya untuk mencegah kasus penculikan yang terjadi 18 tahun lalu.",
    duration: "12 episodes",
    episodes: 12,
    creditLabel: 'Studio',
    credit: "A-1 Pictures",
    genres: ["Drama", "Mystery", "Supernatural"],
    cast: [
      CastMember(name: "Satoru Fujinuma (29)", role: "Main", voiceActor: "Shinnosuke Mitsushima", language: "Japanese"),
      CastMember(name: "Satoru Fujinuma (10)", role: "Main", voiceActor: "Tao Tsuchiya", language: "Japanese"),
      CastMember(name: "Kayo Hinazuki", role: "Main", voiceActor: "Aoi Yuki", language: "Japanese"),
      CastMember(name: "Airi Katagiri", role: "Main", voiceActor: "Chinatsu Akasaki", language: "Japanese"),
    ],
  ),
  "non non byori": MediaDetail(
    synopsis:
        "Hotaru Ichijo pindah dari Tokyo ke desa kecil dan masuk ke sekolah cabang yang hanya punya beberapa murid dari berbagai usia. Ia perlahan terbiasa dengan hidup tenang di pedesaan.",
    creditLabel: 'Studio',
    credit: "Silver Link",
    genres: ["Comedy", "Slice of Life"],
    cast: [
      CastMember(name: "Renge Miyauchi", role: "Main", voiceActor: "Kotori Koiwai", language: "Japanese"),
      CastMember(name: "Hotaru Ichijo", role: "Main", voiceActor: "Rie Murakawa", language: "Japanese"),
      CastMember(name: "Natsumi Koshigaya", role: "Main", voiceActor: "Ayane Sakura", language: "Japanese"),
      CastMember(name: "Komari Koshigaya", role: "Main", voiceActor: "Kana Asumi", language: "Japanese"),
    ],
  ),
  "super cub": MediaDetail(
    synopsis:
        "Koguma, siswi SMA yang tidak punya orang tua, teman, atau hobi, membeli sebuah Honda Super Cub bekas. Motor itu perlahan membuka dunianya dan mempertemukannya dengan persahabatan.",
    duration: "12 episodes",
    episodes: 12,
    creditLabel: 'Studio',
    credit: "Studio KAI",
    genres: ["Slice of Life"],
    cast: [
      CastMember(name: "Koguma", role: "Main", voiceActor: "Yuki Yomichi", language: "Japanese"),
      CastMember(name: "Reiko", role: "Main", voiceActor: "Ayaka Nanase", language: "Japanese"),
    ],
  ),
  "wotakoi: love is hard for otaku": MediaDetail(
    synopsis:
        "Narumi, pegawai kantoran yang menyembunyikan kegemarannya pada fujoshi, bertemu kembali dengan teman masa kecilnya, Hirotaka, seorang gamer hardcore. Mereka mulai berpacaran, dan cinta antar otaku ternyata tidak semudah dugaan.",
    duration: "11 episodes",
    episodes: 11,
    creditLabel: 'Studio',
    credit: "A-1 Pictures",
    genres: ["Comedy", "Romance"],
    cast: [
      CastMember(name: "Narumi Momose", role: "Main", voiceActor: "Arisa Date", language: "Japanese"),
      CastMember(name: "Hirotaka Nifuji", role: "Main", voiceActor: "Kent Ito", language: "Japanese"),
      CastMember(name: "Hanako Koyanagi", role: "Main", voiceActor: "Miyuki Sawashiro", language: "Japanese"),
      CastMember(name: "Taro Kabakura", role: "Main", voiceActor: "Tomokazu Sugita", language: "Japanese"),
    ],
  ),
  "attack on titan": MediaDetail(
    synopsis:
        "Umat manusia hidup di balik tembok tinggi untuk bertahan dari para Titan pemakan manusia. Eren Yeager bersumpah membalas dendam dan memusnahkan mereka setelah tembok dijebol.",
    creditLabel: 'Studio',
    credit: "Wit Studio, MAPPA",
    genres: ["Action", "Drama", "Fantasy"],
    cast: [
      CastMember(name: "Eren Yeager", role: "Main", voiceActor: "Yuki Kaji", language: "Japanese"),
      CastMember(name: "Mikasa Ackerman", role: "Main", voiceActor: "Yui Ishikawa", language: "Japanese"),
      CastMember(name: "Armin Arlert", role: "Main", voiceActor: "Marina Inoue", language: "Japanese"),
      CastMember(name: "Levi Ackerman", role: "Main", voiceActor: "Hiroshi Kamiya", language: "Japanese"),
    ],
  ),
  "death note": MediaDetail(
    synopsis:
        "Siswa jenius Light Yagami menemukan buku catatan yang bisa membunuh siapa pun yang namanya ditulis di dalamnya. Ia pun mulai membersihkan dunia dari penjahat, sambil dikejar detektif misterius bernama L.",
    duration: "37 episodes",
    episodes: 37,
    creditLabel: 'Studio',
    credit: "Madhouse",
    genres: ["Mystery", "Supernatural", "Thriller"],
    cast: [
      CastMember(name: "Light Yagami", role: "Main", voiceActor: "Mamoru Miyano", language: "Japanese"),
      CastMember(name: "L", role: "Main", voiceActor: "Kappei Yamaguchi", language: "Japanese"),
      CastMember(name: "Misa Amane", role: "Main", voiceActor: "Aya Hirano", language: "Japanese"),
      CastMember(name: "Ryuk", role: "Main", voiceActor: "Shidou Nakamura", language: "Japanese"),
    ],
  ),
  "fullmetal alchemist: brotherhood": MediaDetail(
    synopsis:
        "Dua bersaudara Edward dan Alphonse Elric kehilangan tubuh mereka setelah percobaan alkimia terlarang. Mereka mencari Batu Bertuah untuk memulihkannya, dan terseret dalam konspirasi besar negara.",
    duration: "64 episodes",
    episodes: 64,
    creditLabel: 'Studio',
    credit: "Bones",
    genres: ["Action", "Adventure", "Drama", "Fantasy"],
    cast: [
      CastMember(name: "Edward Elric", role: "Main", voiceActor: "Romi Park", language: "Japanese"),
      CastMember(name: "Alphonse Elric", role: "Main", voiceActor: "Rie Kugimiya", language: "Japanese"),
      CastMember(name: "Roy Mustang", role: "Main", voiceActor: "Shinichiro Miki", language: "Japanese"),
      CastMember(name: "Riza Hawkeye", role: "Supporting", voiceActor: "Fumiko Orikasa", language: "Japanese"),
    ],
  ),
  "steins;gate": MediaDetail(
    synopsis:
        "Mahasiswa nyentrik Rintaro Okabe dan teman-temannya tanpa sengaja menemukan cara mengirim pesan ke masa lalu. Percobaan itu mengubah garis waktu dan menyeret mereka ke konsekuensi yang tidak terduga.",
    duration: "24 episodes",
    episodes: 24,
    creditLabel: 'Studio',
    credit: "White Fox",
    genres: ["Drama", "Sci-Fi", "Thriller"],
    cast: [
      CastMember(name: "Rintaro Okabe", role: "Main", voiceActor: "Mamoru Miyano", language: "Japanese"),
      CastMember(name: "Kurisu Makise", role: "Main", voiceActor: "Asami Imai", language: "Japanese"),
      CastMember(name: "Mayuri Shiina", role: "Main", voiceActor: "Kana Hanazawa", language: "Japanese"),
      CastMember(name: "Itaru Hashida", role: "Main", voiceActor: "Tomokazu Seki", language: "Japanese"),
    ],
  ),
  "cowboy bebop": MediaDetail(
    synopsis:
        "Kru pemburu hadiah di pesawat Bebop menjelajahi tata surya pada tahun 2071, mengejar buronan sambil menyimpan masa lalu masing-masing.",
    duration: "26 episodes",
    episodes: 26,
    creditLabel: 'Studio',
    credit: "Sunrise",
    genres: ["Action", "Sci-Fi"],
    cast: [
      CastMember(name: "Spike Spiegel", role: "Main", voiceActor: "Koichi Yamadera", language: "Japanese"),
      CastMember(name: "Jet Black", role: "Main", voiceActor: "Unsho Ishizuka", language: "Japanese"),
      CastMember(name: "Faye Valentine", role: "Main", voiceActor: "Megumi Hayashibara", language: "Japanese"),
      CastMember(name: "Edward", role: "Main", voiceActor: "Aoi Tada", language: "Japanese"),
    ],
  ),
  "naruto": MediaDetail(
    synopsis:
        "Naruto Uzumaki, remaja berisik yang dikucilkan karena roh rubah berekor sembilan di dalam tubuhnya, bermimpi menjadi Hokage, pemimpin desanya.",
    duration: "220 episodes",
    episodes: 220,
    creditLabel: 'Studio',
    credit: "Studio Pierrot",
    genres: ["Action", "Adventure"],
    cast: [
      CastMember(name: "Naruto Uzumaki", role: "Main", voiceActor: "Junko Takeuchi", language: "Japanese"),
      CastMember(name: "Sasuke Uchiha", role: "Main", voiceActor: "Noriaki Sugiyama", language: "Japanese"),
      CastMember(name: "Sakura Haruno", role: "Main", voiceActor: "Chie Nakamura", language: "Japanese"),
      CastMember(name: "Kakashi Hatake", role: "Main", voiceActor: "Kazuhiko Inoue", language: "Japanese"),
    ],
  ),
  "one piece": MediaDetail(
    synopsis:
        "Monkey D. Luffy dan kru bajak lautnya berlayar mengarungi Grand Line demi menemukan harta legendaris One Piece dan menjadi Raja Bajak Laut.",
    creditLabel: 'Studio',
    credit: "Toei Animation",
    genres: ["Action", "Adventure", "Fantasy"],
    cast: [
      CastMember(name: "Monkey D. Luffy", role: "Main", voiceActor: "Mayumi Tanaka", language: "Japanese"),
      CastMember(name: "Roronoa Zoro", role: "Main", voiceActor: "Kazuya Nakai", language: "Japanese"),
      CastMember(name: "Nami", role: "Main", voiceActor: "Akemi Okamura", language: "Japanese"),
      CastMember(name: "Usopp", role: "Main", voiceActor: "Kappei Yamaguchi", language: "Japanese"),
    ],
  ),
  "demon slayer": MediaDetail(
    synopsis:
        "Tanjiro Kamado menjadi pemburu iblis setelah keluarganya dibantai dan adiknya, Nezuko, berubah menjadi iblis. Ia berusaha mencari cara mengembalikan Nezuko menjadi manusia.",
    creditLabel: 'Studio',
    credit: "ufotable",
    genres: ["Action", "Fantasy"],
    cast: [
      CastMember(name: "Tanjiro Kamado", role: "Main", voiceActor: "Natsuki Hanae", language: "Japanese"),
      CastMember(name: "Nezuko Kamado", role: "Main", voiceActor: "Akari Kito", language: "Japanese"),
      CastMember(name: "Zenitsu Agatsuma", role: "Main", voiceActor: "Hiro Shimono", language: "Japanese"),
      CastMember(name: "Inosuke Hashibira", role: "Main", voiceActor: "Yoshitsugu Matsuoka", language: "Japanese"),
    ],
  ),
  "jujutsu kaisen": MediaDetail(
    synopsis:
        "Yuji Itadori menelan jari terkutuk milik Sukuna, raja kutukan, dan bergabung dengan sekolah penyihir jujutsu untuk melawan kutukan yang mengancam manusia.",
    creditLabel: 'Studio',
    credit: "MAPPA",
    genres: ["Action", "Supernatural"],
    cast: [
      CastMember(name: "Yuji Itadori", role: "Main", voiceActor: "Junya Enoki", language: "Japanese"),
      CastMember(name: "Megumi Fushiguro", role: "Main", voiceActor: "Yuma Uchida", language: "Japanese"),
      CastMember(name: "Nobara Kugisaki", role: "Main", voiceActor: "Asami Seto", language: "Japanese"),
      CastMember(name: "Satoru Gojo", role: "Main", voiceActor: "Yuichi Nakamura", language: "Japanese"),
    ],
  ),
  "your lie in april": MediaDetail(
    synopsis:
        "Kosei Arima, pianis berbakat yang berhenti bermain setelah kehilangan ibunya, bertemu pemain biola bebas bernama Kaori Miyazono yang membuatnya kembali menatap musik.",
    duration: "22 episodes",
    episodes: 22,
    creditLabel: 'Studio',
    credit: "A-1 Pictures",
    genres: ["Drama", "Music", "Romance"],
    cast: [
      CastMember(name: "Kosei Arima", role: "Main", voiceActor: "Natsuki Hanae", language: "Japanese"),
      CastMember(name: "Kaori Miyazono", role: "Main", voiceActor: "Risa Taneda", language: "Japanese"),
      CastMember(name: "Tsubaki Sawabe", role: "Main", voiceActor: "Ayane Sakura", language: "Japanese"),
    ],
  ),
  "clannad": MediaDetail(
    synopsis:
        "Tomoya Okazaki, siswa SMA yang malas dan merasa hampa, bertemu Nagisa Furukawa, gadis lemah yang ingin menghidupkan kembali klub drama. Pertemuan itu mengubah hidupnya.",
    creditLabel: 'Studio',
    credit: "Kyoto Animation",
    genres: ["Drama", "Romance", "Slice of Life"],
    cast: [
      CastMember(name: "Tomoya Okazaki", role: "Main", voiceActor: "Yuichi Nakamura", language: "Japanese"),
      CastMember(name: "Nagisa Furukawa", role: "Main", voiceActor: "Mai Nakahara", language: "Japanese"),
      CastMember(name: "Kyo Fujibayashi", role: "Main", voiceActor: "Ryo Hirohashi", language: "Japanese"),
      CastMember(name: "Tomoyo Sakagami", role: "Main", voiceActor: "Houko Kuwashima", language: "Japanese"),
    ],
  ),
  "violet evergarden": MediaDetail(
    synopsis:
        "Violet, mantan prajurit yang dibesarkan sebagai senjata, bekerja sebagai penulis surat pengganti sambil berusaha memahami arti kata terakhir dari majornya: 'aku mencintaimu'.",
    duration: "13 episodes",
    episodes: 13,
    creditLabel: 'Studio',
    credit: "Kyoto Animation",
    genres: ["Drama", "Fantasy"],
    cast: [
      CastMember(name: "Violet Evergarden", role: "Main", voiceActor: "Yui Ishikawa", language: "Japanese"),
      CastMember(name: "Claudia Hodgins", role: "Main", voiceActor: "Daisuke Namikawa", language: "Japanese"),
      CastMember(name: "Gilbert Bougainvillea", role: "Supporting", voiceActor: "Takehito Koyasu", language: "Japanese"),
    ],
  ),
  "hunter x hunter": MediaDetail(
    synopsis:
        "Gon Freecss mengikuti ujian Hunter untuk mencari ayahnya, Hunter legendaris. Dalam perjalanannya ia bertemu Killua, Kurapika, dan Leorio.",
    duration: "148 episodes",
    episodes: 148,
    creditLabel: 'Studio',
    credit: "Madhouse",
    genres: ["Action", "Adventure", "Fantasy"],
    cast: [
      CastMember(name: "Gon Freecss", role: "Main", voiceActor: "Megumi Han", language: "Japanese"),
      CastMember(name: "Killua Zoldyck", role: "Main", voiceActor: "Mariya Ise", language: "Japanese"),
      CastMember(name: "Kurapika", role: "Main", voiceActor: "Miyuki Sawashiro", language: "Japanese"),
    ],
  ),
  "code geass": MediaDetail(
    synopsis:
        "Lelouch, pangeran buangan yang mendapat kekuatan memerintah siapa pun, memimpin pemberontakan melawan Kekaisaran Britannia yang menguasai Jepang.",
    duration: "50 episodes",
    episodes: 50,
    creditLabel: 'Studio',
    credit: "Sunrise",
    genres: ["Action", "Drama", "Sci-Fi"],
    cast: [
      CastMember(name: "Lelouch Lamperouge", role: "Main", voiceActor: "Jun Fukuyama", language: "Japanese"),
      CastMember(name: "Suzaku Kururugi", role: "Main", voiceActor: "Takahiro Sakurai", language: "Japanese"),
      CastMember(name: "C.C.", role: "Main", voiceActor: "Yukana", language: "Japanese"),
      CastMember(name: "Kallen Stadtfeld", role: "Main", voiceActor: "Ami Koshimizu", language: "Japanese"),
    ],
  ),
  "neon genesis evangelion": MediaDetail(
    synopsis:
        "Shinji Ikari, remaja pendiam, dipaksa mengendalikan robot raksasa Eva untuk melawan makhluk misterius yang disebut Malaikat demi menyelamatkan umat manusia.",
    duration: "26 episodes",
    episodes: 26,
    creditLabel: 'Studio',
    credit: "Gainax, Tatsunoko Production",
    genres: ["Action", "Drama", "Sci-Fi"],
    cast: [
      CastMember(name: "Shinji Ikari", role: "Main", voiceActor: "Megumi Ogata", language: "Japanese"),
      CastMember(name: "Rei Ayanami", role: "Main", voiceActor: "Megumi Hayashibara", language: "Japanese"),
      CastMember(name: "Asuka Langley Soryu", role: "Main", voiceActor: "Yuko Miyamura", language: "Japanese"),
      CastMember(name: "Misato Katsuragi", role: "Main", voiceActor: "Kotono Mitsuishi", language: "Japanese"),
    ],
  ),
  "bocchi the rock!": MediaDetail(
    synopsis:
        "Hitori Gotoh, gadis pemalu yang jago bermain gitar, bergabung dengan band yang membuatnya perlahan keluar dari cangkangnya.",
    duration: "12 episodes",
    episodes: 12,
    creditLabel: 'Studio',
    credit: "CloverWorks",
    genres: ["Comedy", "Music"],
    cast: [
      CastMember(name: "Hitori Gotoh", role: "Main", voiceActor: "Yoshino Aoyama", language: "Japanese"),
      CastMember(name: "Nijika Ijichi", role: "Main", voiceActor: "Sayumi Suzushiro", language: "Japanese"),
      CastMember(name: "Ryo Yamada", role: "Main", voiceActor: "Saku Mizuno", language: "Japanese"),
      CastMember(name: "Ikuyo Kita", role: "Main", voiceActor: "Ikumi Hasegawa", language: "Japanese"),
    ],
  ),
  "frieren: beyond journey's end": MediaDetail(
    synopsis:
        "Setelah mengalahkan Raja Iblis, penyihir elf Frieren menyadari betapa singkatnya umur manusia dibanding hidupnya. Ia melakukan perjalanan baru untuk memahami arti hubungan yang pernah ia lalui.",
    creditLabel: 'Studio',
    credit: "Madhouse",
    genres: ["Adventure", "Drama", "Fantasy"],
    cast: [
      CastMember(name: "Frieren", role: "Main", voiceActor: "Atsumi Tanezaki", language: "Japanese"),
      CastMember(name: "Fern", role: "Main", voiceActor: "Kana Ichinose", language: "Japanese"),
      CastMember(name: "Stark", role: "Main", voiceActor: "Chiaki Kobayashi", language: "Japanese"),
      CastMember(name: "Himmel", role: "Supporting", voiceActor: "Nobuhiko Okamoto", language: "Japanese"),
    ],
  ),
  "spy x family": MediaDetail(
    synopsis:
        "Mata-mata andal Twilight harus membentuk keluarga palsu demi misinya. Ia mengadopsi anak yang ternyata bisa membaca pikiran dan menikahi seorang pembunuh bayaran tanpa saling tahu rahasia masing-masing.",
    creditLabel: 'Studio',
    credit: "Wit Studio, CloverWorks",
    genres: ["Action", "Comedy"],
    cast: [
      CastMember(name: "Loid Forger", role: "Main", voiceActor: "Takuya Eguchi", language: "Japanese"),
      CastMember(name: "Anya Forger", role: "Main", voiceActor: "Atsumi Tanezaki", language: "Japanese"),
      CastMember(name: "Yor Forger", role: "Main", voiceActor: "Saori Hayami", language: "Japanese"),
    ],
  ),
  "chainsaw man": MediaDetail(
    synopsis:
        "Denji, pemuda miskin yang melunasi utang ayahnya sebagai pemburu iblis, bergabung dengan iblis gergaji peliharaannya dan menjadi Chainsaw Man.",
    duration: "12 episodes",
    episodes: 12,
    creditLabel: 'Studio',
    credit: "MAPPA",
    genres: ["Action", "Horror"],
    cast: [
      CastMember(name: "Denji", role: "Main", voiceActor: "Kikunosuke Toya", language: "Japanese"),
      CastMember(name: "Power", role: "Main", voiceActor: "Ai Fairouz", language: "Japanese"),
      CastMember(name: "Aki Hayakawa", role: "Main", voiceActor: "Shogo Sakata", language: "Japanese"),
      CastMember(name: "Makima", role: "Main", voiceActor: "Tomori Kusunoki", language: "Japanese"),
    ],
  ),
  "mob psycho 100": MediaDetail(
    synopsis:
        "Shigeo Kageyama, remaja dengan kekuatan psikis luar biasa, berusaha menjalani hidup normal sambil mengendalikan emosinya.",
    creditLabel: 'Studio',
    credit: "Bones",
    genres: ["Action", "Comedy", "Supernatural"],
    cast: [
      CastMember(name: "Shigeo Kageyama", role: "Main", voiceActor: "Setsuo Ito", language: "Japanese"),
      CastMember(name: "Arataka Reigen", role: "Main", voiceActor: "Takahiro Sakurai", language: "Japanese"),
      CastMember(name: "Ritsu Kageyama", role: "Supporting", voiceActor: "Miyu Irino", language: "Japanese"),
    ],
  ),
  "one punch man": MediaDetail(
    synopsis:
        "Saitama, pahlawan yang bisa mengalahkan musuh apa pun dengan satu pukulan, justru bosan karena tidak ada lawan yang sepadan.",
    creditLabel: 'Studio',
    credit: "Madhouse, J.C.Staff",
    genres: ["Action", "Comedy"],
    cast: [
      CastMember(name: "Saitama", role: "Main", voiceActor: "Makoto Furukawa", language: "Japanese"),
      CastMember(name: "Genos", role: "Main", voiceActor: "Kaito Ishikawa", language: "Japanese"),
      CastMember(name: "Tatsumaki", role: "Supporting", voiceActor: "Aoi Yuki", language: "Japanese"),
    ],
  ),
  "made in abyss": MediaDetail(
    synopsis:
        "Riko, gadis yang bermimpi menjadi penjelajah, bersama robot bernama Reg turun ke Abyss, lubang raksasa penuh misteri dan bahaya, untuk mencari ibunya.",
    creditLabel: 'Studio',
    credit: "Kinema Citrus",
    genres: ["Adventure", "Fantasy", "Mystery"],
    cast: [
      CastMember(name: "Riko", role: "Main", voiceActor: "Miyu Tomita", language: "Japanese"),
      CastMember(name: "Reg", role: "Main", voiceActor: "Mariya Ise", language: "Japanese"),
      CastMember(name: "Nanachi", role: "Main", voiceActor: "Shiori Izawa", language: "Japanese"),
      CastMember(name: "Ozen", role: "Supporting", voiceActor: "Sayaka Ohara", language: "Japanese"),
    ],
  ),
  "mushishi": MediaDetail(
    synopsis:
        "Ginko, pengembara yang meneliti makhluk misterius bernama mushi, berkeliling dari desa ke desa untuk membantu orang-orang yang terganggu oleh makhluk itu.",
    duration: "26 episodes",
    episodes: 26,
    creditLabel: 'Studio',
    credit: "Artland",
    genres: ["Fantasy", "Slice of Life"],
    cast: [
      CastMember(name: "Ginko", role: "Main", voiceActor: "Yuto Nakano", language: "Japanese"),
      CastMember(name: "Adashino", role: "Supporting", voiceActor: "Yuji Ueda", language: "Japanese"),
      CastMember(name: "Nui", role: "Supporting", voiceActor: "Mika Doi", language: "Japanese"),
      CastMember(name: "Tanyu Karibusa", role: "Supporting", voiceActor: "Ai Kobayashi", language: "Japanese"),
    ],
  ),
  "monster": MediaDetail(
    synopsis:
        "Dr. Kenzo Tenma menyelamatkan nyawa seorang anak laki-laki bernama Johan. Bertahun-tahun kemudian, anak itu muncul sebagai pembunuh berantai, dan Tenma bertekad menghentikannya.",
    duration: "74 episodes",
    episodes: 74,
    creditLabel: 'Studio',
    credit: "Madhouse",
    genres: ["Drama", "Mystery", "Thriller"],
    cast: [
      CastMember(name: "Kenzo Tenma", role: "Main", voiceActor: "Hidenobu Kiuchi", language: "Japanese"),
      CastMember(name: "Johan Liebert", role: "Main", voiceActor: "Nozomu Sasaki", language: "Japanese"),
      CastMember(name: "Anna Liebert / Nina Fortner", role: "Main", voiceActor: "Mamiko Noto", language: "Japanese"),
    ],
  ),
  "yuru camp△": MediaDetail(
    synopsis:
        "Rin Shima gemar berkemah sendirian, sampai ia bertemu Nadeshiko yang baru pindah dan antusias. Bersama klub luar ruang sekolah, mereka menikmati hidangan dan pemandangan alam.",
    creditLabel: 'Studio',
    credit: "C-Station",
    genres: ["Comedy", "Slice of Life"],
    cast: [
      CastMember(name: "Rin Shima", role: "Main", voiceActor: "Nao Toyama", language: "Japanese"),
      CastMember(name: "Nadeshiko Kagamihara", role: "Main", voiceActor: "Yumiri Hanamori", language: "Japanese"),
      CastMember(name: "Aoi Inuyama", role: "Main", voiceActor: "Aki Toyosaki", language: "Japanese"),
      CastMember(name: "Chiaki Ogaki", role: "Main", voiceActor: "Sayuri Hara", language: "Japanese"),
    ],
  ),
  "kaguya-sama: love is war": MediaDetail(
    synopsis:
        "Ketua OSIS Miyuki Shirogane dan wakilnya Kaguya Shinomiya sama-sama jatuh cinta tetapi terlalu gengsi untuk mengaku, sehingga keduanya berusaha membuat pihak lain menyatakan cinta lebih dulu.",
    creditLabel: 'Studio',
    credit: "A-1 Pictures",
    genres: ["Comedy", "Romance"],
    cast: [
      CastMember(name: "Kaguya Shinomiya", role: "Main", voiceActor: "Aoi Koga", language: "Japanese"),
      CastMember(name: "Miyuki Shirogane", role: "Main", voiceActor: "Makoto Furukawa", language: "Japanese"),
      CastMember(name: "Chika Fujiwara", role: "Main", voiceActor: "Konomi Kohara", language: "Japanese"),
    ],
  ),
  "vinland saga": MediaDetail(
    synopsis:
        "Thorfinn tumbuh bersama para Viking yang membunuh ayahnya dan terus mencari kesempatan membalas dendam pada pemimpin mereka, Askeladd.",
    creditLabel: 'Studio',
    credit: "Wit Studio, MAPPA",
    genres: ["Action", "Adventure", "Drama"],
    cast: [
      CastMember(name: "Thorfinn", role: "Main", voiceActor: "Yuto Uemura", language: "Japanese"),
      CastMember(name: "Askeladd", role: "Main", voiceActor: "Naoya Uchida", language: "Japanese"),
      CastMember(name: "Thorkell", role: "Supporting", voiceActor: "Akio Otsuka", language: "Japanese"),
      CastMember(name: "Canute", role: "Main", voiceActor: "Kensho Ono", language: "Japanese"),
    ],
  ),
  "13 going on 30": MediaDetail(
    synopsis:
        "Jenna, remaja 13 tahun yang ingin cepat dewasa, mendadak terbangun sebagai wanita 30 tahun yang sukses di dunia majalah. Ia harus belajar menghadapi pilihan hidup yang dulu ia buat tanpa sadar.",
    duration: "98 min",
    creditLabel: "Director",
    credit: "Gary Winick",
    genres: ["Comedy", "Fantasy", "Romance"],
    cast: [
      CastMember(name: "Jennifer Garner", role: "Jenna Rink"),
      CastMember(name: "Mark Ruffalo", role: "Matt Flamhaff"),
      CastMember(name: "Judy Greer", role: "Lucy Wyman"),
      CastMember(name: "Andy Serkis", role: "Richard Kneeland"),
    ],
  ),
  "a cinderella story": MediaDetail(
    synopsis:
        "Sam, gadis SMA yang diperlakukan buruk oleh ibu tirinya, bertukar pesan dengan seorang pemuda misterius lewat internet. Mereka berencana bertemu di pesta dansa Halloween.",
    duration: "95 min",
    creditLabel: "Director",
    credit: "Mark Rosman",
    genres: ["Comedy", "Family", "Romance"],
    cast: [
      CastMember(name: "Hilary Duff", role: "Sam Montgomery"),
      CastMember(name: "Chad Michael Murray", role: "Austin Ames"),
      CastMember(name: "Jennifer Coolidge", role: "Fiona Montgomery"),
      CastMember(name: "Regina King", role: "Rhonda"),
    ],
  ),
  "how to lose a guy in 10 days": MediaDetail(
    synopsis:
        "Penulis majalah Andie bertaruh bisa membuat seorang pria kabur dalam sepuluh hari, sementara pria itu bertaruh bisa membuat seorang wanita jatuh cinta dalam waktu yang sama. Tanpa mereka ketahui, kedua taruhan itu saling bertabrakan.",
    duration: "116 min",
    creditLabel: "Director",
    credit: "Donald Petrie",
    genres: ["Comedy", "Romance"],
    cast: [
      CastMember(name: "Kate Hudson", role: "Andie Anderson"),
      CastMember(name: "Matthew McConaughey", role: "Benjamin Barry"),
      CastMember(name: "Adam Goldberg", role: "Spears"),
      CastMember(name: "Michael Michele", role: "Tony"),
    ],
  ),
  "the box": MediaDetail(
    synopsis:
        "Ji-hoon, penyanyi berbakat yang hanya bisa tampil dengan kotak di kepalanya karena takut panggung, bertemu Min-soo, produser yang jatuh dari puncak kariernya. Keduanya melakukan perjalanan keliling Korea Selatan sambil mengamen.",
    duration: "94 min",
    creditLabel: "Director",
    credit: "Yang Jung-woong",
    genres: ["Drama", "Music", "Musical"],
    cast: [
      CastMember(name: "Chanyeol", role: "Ji-hoon"),
      CastMember(name: "Jo Dal-hwan", role: "Min-soo"),
      CastMember(name: "Kim Ji-hyun", role: "Nana"),
      CastMember(name: "Kang Jae-jun", role: "Il-hyun"),
    ],
  ),
  "drawing closer": MediaDetail(
    synopsis:
        "Akito, pelukis muda yang divonis hidup satu tahun lagi, bertemu Haruna, gadis yang hanya punya sisa hidup setengah tahun. Mereka saling mendekat lewat seni dan kenangan.",
    duration: "118 min",
    creditLabel: "Director",
    credit: "Takahiro Miki",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Ren Nagase", role: "Akito Hayasaka"),
      CastMember(name: "Natsuki Deguchi", role: "Haruna Sakurai"),
      CastMember(name: "Mayuu Yokota", role: "Ayaka Miura"),
      CastMember(name: "Fumino Kimura", role: "Mikiko"),
    ],
  ),
  "even if this love disappears from the world tonight": MediaDetail(
    synopsis:
        "Toru menyatakan perasaan palsu kepada Maori, dan Maori memberi satu aturan: jangan jatuh cinta. Toru perlahan jatuh cinta, lalu tahu bahwa Maori kehilangan ingatannya setiap kali tidur.",
    duration: "121 min",
    creditLabel: "Director",
    credit: "Takahiro Miki",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Shunsuke Michieda", role: "Toru Kamiya"),
      CastMember(name: "Riko Fukumoto", role: "Maori Hino"),
      CastMember(name: "Kotone Furukawa", role: "Pemeran pendukung"),
      CastMember(name: "Honoka Matsumoto", role: "Pemeran pendukung"),
    ],
  ),
  "man in love": MediaDetail(
    synopsis:
        "Tae-il, preman rendahan penagih utang, jatuh cinta untuk pertama kalinya pada Ho-jung, perempuan yang ayahnya berutang padanya. Ia kemudian mengetahui bahwa waktunya tidak lama lagi.",
    duration: "120 min",
    creditLabel: "Director",
    credit: "Han Dong-wook",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Hwang Jung-min", role: "Han Tae-il"),
      CastMember(name: "Han Hye-jin", role: "Joo Ho-jung"),
      CastMember(name: "Kwak Do-won", role: "Han Young-il"),
      CastMember(name: "Jung Man-sik", role: "Doo-chul"),
    ],
  ),
  "little women (2019)": MediaDetail(
    synopsis:
        "Empat bersaudari March tumbuh di Amerika setelah Perang Saudara dan mengejar mimpi masing-masing, dengan Jo yang bercita-cita menjadi penulis sebagai pusat cerita.",
    duration: "135 min",
    creditLabel: "Director",
    credit: "Greta Gerwig",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Saoirse Ronan", role: "Jo March"),
      CastMember(name: "Emma Watson", role: "Meg March"),
      CastMember(name: "Florence Pugh", role: "Amy March"),
      CastMember(name: "Eliza Scanlen", role: "Beth March"),
    ],
  ),
  "atonement": MediaDetail(
    synopsis:
        "Pada tahun 1935, tuduhan palsu seorang gadis remaja bernama Briony menghancurkan kisah cinta kakaknya, Cecilia, dan Robbie. Bertahun-tahun kemudian, ia berusaha menebus kesalahannya.",
    duration: "123 min",
    creditLabel: "Director",
    credit: "Joe Wright",
    genres: ["Drama", "Mystery", "Romance"],
    cast: [
      CastMember(name: "Keira Knightley", role: "Cecilia Tallis"),
      CastMember(name: "James McAvoy", role: "Robbie Turner"),
      CastMember(name: "Saoirse Ronan", role: "Briony Tallis (13 tahun)"),
      CastMember(name: "Romola Garai", role: "Briony Tallis (18 tahun)"),
    ],
  ),
  "hear me: our summer": MediaDetail(
    synopsis:
        "Yong-jun, pemuda pengantar makan siang, jatuh hati pada Yeo-reum, kakak seorang perenang tuli. Ia mendekatinya dengan bahasa isyarat, dan hubungan mereka tumbuh sambil mereka mencari arah hidup masing-masing.",
    duration: "109 min",
    creditLabel: "Director",
    credit: "Jo Sun-ho",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Hong Kyung", role: "Yong-jun"),
      CastMember(name: "Roh Yoon-seo", role: "Yeo-reum"),
      CastMember(name: "Kim Min-ju", role: "Ga-eul"),
    ],
  ),
  "despicable me": MediaDetail(
    synopsis:
        "Gru, penjahat yang berencana mencuri bulan, mengadopsi tiga anak yatim untuk membantu rencananya, tetapi mereka justru mengubah hidupnya.",
    duration: "95 min",
    creditLabel: "Director",
    credit: "Pierre Coffin, Chris Renaud",
    genres: ["Animation", "Comedy", "Crime"],
    cast: [
      CastMember(name: "Steve Carell", role: "Gru"),
      CastMember(name: "Jason Segel", role: "Vector"),
      CastMember(name: "Russell Brand", role: "Dr. Nefario"),
      CastMember(name: "Kristen Wiig", role: "Miss Hattie"),
    ],
  ),
  "ghost in the cell": MediaDetail(
    synopsis:
        "Seorang narapidana baru tiba di penjara berkeamanan tinggi, dan sesosok hantu mulai menebar maut di sana. Geng-geng yang saling bermusuhan harus bersatu untuk bertahan hidup.",
    duration: "106 min",
    creditLabel: "Director",
    credit: "Joko Anwar",
    genres: ["Horror", "Comedy"],
    cast: [
      CastMember(name: "Abimana Aryasatya", role: "Cast utama"),
      CastMember(name: "Bront Palarae", role: "Cast utama"),
      CastMember(name: "Aming Sugandhi", role: "Cast utama"),
      CastMember(name: "Arswendy Bening Swara", role: "Cast utama"),
    ],
  ),
  "sore: istri dari masa depan": MediaDetail(
    synopsis:
        "Jonathan, yang tinggal di Kroasia, bertemu seorang perempuan bernama Sore yang mengaku sebagai istrinya dari masa depan. Ia datang untuk mengubah gaya hidup Jonathan sebelum terlambat.",
    duration: "119 min",
    creditLabel: "Director",
    credit: "Yandy Laurens",
    genres: ["Drama", "Romance", "Sci-Fi"],
    cast: [
      CastMember(name: "Dion Wiyoko", role: "Jonathan"),
      CastMember(name: "Sheila Dara Aisha", role: "Sore"),
      CastMember(name: "Goran Bogdan", role: "Pemeran pendukung"),
      CastMember(name: "Lara Nekić", role: "Pemeran pendukung"),
    ],
  ),
  "spider-man": MediaDetail(
    synopsis:
        "Peter Parker, pelajar pemalu, digigit laba-laba hasil rekayasa genetika dan mendapat kekuatan super. Ia harus menghadapi Green Goblin yang mengancam kotanya.",
    duration: "121 min",
    creditLabel: "Director",
    credit: "Sam Raimi",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Tobey Maguire", role: "Peter Parker / Spider-Man"),
      CastMember(name: "Willem Dafoe", role: "Norman Osborn / Green Goblin"),
      CastMember(name: "Kirsten Dunst", role: "Mary Jane Watson"),
      CastMember(name: "James Franco", role: "Harry Osborn"),
    ],
  ),
  "spider-man 2": MediaDetail(
    synopsis:
        "Peter berjuang menyeimbangkan kehidupan pribadinya dengan perannya sebagai Spider-Man, sementara ilmuwan Otto Octavius berubah menjadi Doctor Octopus.",
    duration: "127 min",
    creditLabel: "Director",
    credit: "Sam Raimi",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Tobey Maguire", role: "Peter Parker / Spider-Man"),
      CastMember(name: "Kirsten Dunst", role: "Mary Jane Watson"),
      CastMember(name: "James Franco", role: "Harry Osborn"),
      CastMember(name: "Alfred Molina", role: "Dr. Otto Octavius"),
    ],
  ),
  "spider-man 3": MediaDetail(
    synopsis:
        "Spider-Man yang kini dipuja banyak orang menghadapi musuh-musuh baru dan sisi gelap dirinya sendiri saat sebuah makhluk alien mengambil alih kostumnya.",
    duration: "139 min",
    creditLabel: "Director",
    credit: "Sam Raimi",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Tobey Maguire", role: "Peter Parker / Spider-Man"),
      CastMember(name: "Kirsten Dunst", role: "Mary Jane Watson"),
      CastMember(name: "James Franco", role: "Harry Osborn"),
      CastMember(name: "Topher Grace", role: "Eddie Brock / Venom"),
    ],
  ),
  "the amazing spider-man": MediaDetail(
    synopsis:
        "Peter Parker menyelidiki hilangnya orang tuanya sambil berhadapan dengan Lizard, ilmuwan Curt Connors yang bermutasi.",
    duration: "136 min",
    creditLabel: "Director",
    credit: "Marc Webb",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Andrew Garfield", role: "Peter Parker / Spider-Man"),
      CastMember(name: "Emma Stone", role: "Gwen Stacy"),
      CastMember(name: "Rhys Ifans", role: "Dr. Curt Connors / Lizard"),
      CastMember(name: "Denis Leary", role: "Captain George Stacy"),
    ],
  ),
  "the amazing spider-man 2": MediaDetail(
    synopsis:
        "Peter menghadapi Electro dan kembalinya sahabat lamanya, Harry Osborn, sambil menyelidiki kebenaran tentang masa lalu orang tuanya.",
    duration: "142 min",
    creditLabel: "Director",
    credit: "Marc Webb",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Andrew Garfield", role: "Peter Parker / Spider-Man"),
      CastMember(name: "Emma Stone", role: "Gwen Stacy"),
      CastMember(name: "Jamie Foxx", role: "Max Dillon / Electro"),
      CastMember(name: "Dane DeHaan", role: "Harry Osborn"),
    ],
  ),
  "spider-man: homecoming": MediaDetail(
    synopsis:
        "Peter Parker berusaha membuktikan diri sebagai pahlawan di bawah bimbingan Tony Stark, sementara Vulture mengancam kotanya.",
    duration: "133 min",
    creditLabel: "Director",
    credit: "Jon Watts",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Tom Holland", role: "Peter Parker / Spider-Man"),
      CastMember(name: "Michael Keaton", role: "Adrian Toomes / Vulture"),
      CastMember(name: "Zendaya", role: "Michelle"),
      CastMember(name: "Robert Downey Jr.", role: "Tony Stark / Iron Man"),
    ],
  ),
  "spider-man: far from home": MediaDetail(
    synopsis:
        "Peter berlibur ke Eropa bersama teman-temannya, tetapi Nick Fury melibatkannya dalam misi melawan ancaman elemental dan seorang pria misterius bernama Mysterio.",
    duration: "129 min",
    creditLabel: "Director",
    credit: "Jon Watts",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Tom Holland", role: "Peter Parker / Spider-Man"),
      CastMember(name: "Samuel L. Jackson", role: "Nick Fury"),
      CastMember(name: "Zendaya", role: "MJ"),
      CastMember(name: "Jake Gyllenhaal", role: "Quentin Beck / Mysterio"),
    ],
  ),
  "spider-man: no way home": MediaDetail(
    synopsis:
        "Setelah identitasnya terbongkar, Peter meminta bantuan Doctor Strange. Mantra yang diucapkan justru membuka pintu bagi musuh-musuh dari semesta lain.",
    duration: "148 min",
    creditLabel: "Director",
    credit: "Jon Watts",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Tom Holland", role: "Peter Parker / Spider-Man"),
      CastMember(name: "Zendaya", role: "MJ"),
      CastMember(name: "Benedict Cumberbatch", role: "Doctor Strange"),
      CastMember(name: "Jacob Batalon", role: "Ned Leeds"),
    ],
  ),
  "spider-man: brand new day": MediaDetail(
    synopsis:
        "Empat tahun setelah dunia melupakannya, Peter Parker menjadi Spider-Man penuh waktu di kota yang tak lagi mengenalnya, dan harus menghadapi ancaman baru yang tidak terlihat.",
    duration: "145 min",
    creditLabel: "Director",
    credit: "Destin Daniel Cretton",
    genres: ["Action", "Adventure", "Sci-Fi"],
    cast: [
      CastMember(name: "Tom Holland", role: "Peter Parker / Spider-Man"),
      CastMember(name: "Zendaya", role: "MJ"),
      CastMember(name: "Jacob Batalon", role: "Ned Leeds"),
      CastMember(name: "Jon Bernthal", role: "Frank Castle / Punisher"),
    ],
  ),
  "bridge to terabithia": MediaDetail(
    synopsis:
        "Jess, anak laki-laki pendiam, bersahabat dengan Leslie, tetangga barunya yang imajinatif. Bersama-sama mereka menciptakan dunia rahasia bernama Terabithia di hutan dekat rumah.",
    duration: "96 min",
    creditLabel: "Director",
    credit: "Gabor Csupo",
    genres: ["Adventure", "Drama", "Family"],
    cast: [
      CastMember(name: "AnnaSophia Robb", role: "Leslie Burke"),
      CastMember(name: "Josh Hutcherson", role: "Jess Aarons"),
      CastMember(name: "Zooey Deschanel", role: "Miss Edmunds"),
      CastMember(name: "Robert Patrick", role: "Jack Aarons"),
    ],
  ),
  "youth of may": MediaDetail(
    synopsis:
        "Pada tahun 1980 di Gwangju, mahasiswa kedokteran Hwang Hee-tae bertemu perawat Kim Myung-hee. Cinta mereka tumbuh di tengah gejolak sejarah yang kemudian memisahkan mereka.",
    duration: "12 episodes",
    episodes: 12,
    creditLabel: "Director",
    credit: "Song Min-yeop",
    genres: ["Drama", "History", "Romance"],
    cast: [
      CastMember(name: "Lee Do-hyun", role: "Hwang Hee-tae"),
      CastMember(name: "Go Min-si", role: "Kim Myung-hee"),
      CastMember(name: "Geum Sae-rok", role: "Lee Soo-ryeon"),
      CastMember(name: "Lee Sang-yi", role: "Lee Soo-chan"),
    ],
  ),
  "little women (2022)": MediaDetail(
    synopsis:
        "Tiga bersaudari yang hidup pas-pasan terseret ke dalam kasus yang melibatkan uang gelap dan keluarga kaya raya, dan harus menghadapi kebenaran di baliknya.",
    duration: "12 episodes",
    episodes: 12,
    creditLabel: "Director",
    credit: "Kim Hee-won",
    genres: ["Crime", "Drama", "Mystery"],
    cast: [
      CastMember(name: "Kim Go-eun", role: "Oh In-joo"),
      CastMember(name: "Nam Ji-hyun", role: "Oh In-kyung"),
      CastMember(name: "Park Ji-hu", role: "Oh In-hye"),
      CastMember(name: "Uhm Ji-won", role: "Won Sang-ah"),
    ],
  ),
  "mr. plankton": MediaDetail(
    synopsis:
        "Seorang pria yang waktunya tinggal beberapa bulan dan mantan kekasihnya terpaksa saling menemani dalam perjalanan terakhir hidupnya.",
    duration: "10 episodes",
    episodes: 10,
    creditLabel: "Director",
    credit: "Hong Jong-chan",
    genres: ["Comedy", "Drama", "Romance"],
    cast: [
      CastMember(name: "Woo Do-hwan", role: "Hae-jo"),
      CastMember(name: "Lee Yoo-mi", role: "Jae-mi"),
      CastMember(name: "Oh Jung-se", role: "Eo Heung"),
    ],
  ),
  "spirit fingers": MediaDetail(
    synopsis:
        "Song Woo-yeon, siswi SMA penurut yang sulit mengungkapkan perasaannya, bergabung dengan klub gambar Spirit Fingers dan perlahan menemukan warna, kepribadian, dan mimpinya.",
    duration: "12 episodes",
    episodes: 12,
    creditLabel: "Director",
    credit: "Lee Cheol-ha",
    genres: ["Comedy", "Drama", "Romance"],
    cast: [
      CastMember(name: "Park Ji-hu", role: "Song Woo-yeon"),
      CastMember(name: "Cho Jun-young", role: "Nam Gi-jeong"),
      CastMember(name: "Choi Bo-min", role: "Koo Seon-ho"),
      CastMember(name: "Park Yoo-na", role: "Nam Geu-rin"),
    ],
  ),
  "upin & ipin": MediaDetail(
    synopsis:
        "Dua anak kembar berusia lima tahun, Upin dan Ipin, menceritakan kehidupan sehari-hari mereka bersama kakak, nenek, dan teman-teman di Kampung Durian Runtuh sambil belajar banyak hal baru.",
    creditLabel: "Creator",
    credit: "Burhanuddin Md Radzi, Ainon Ariff",
    genres: ["Animation", "Comedy", "Family"],
    cast: [
      CastMember(name: "Asyiela Putri", role: "Suara Upin & Ipin"),
      CastMember(name: "Hajah Ainon Ariff", role: "Suara Opah"),
      CastMember(name: "Tang Ying Sowk", role: "Suara Mei Mei"),
      CastMember(name: "Muhammad Fareez Daniel", role: "Suara Ehsan"),
    ],
  ),
  "strong woman do bong-soon": MediaDetail(
    synopsis:
        "Do Bong-soon, perempuan bertubuh mungil dengan kekuatan super, menjadi pengawal bos muda sebuah perusahaan game. Keduanya mulai saling jatuh cinta sambil memecahkan kasus penculikan.",
    duration: "16 episodes",
    episodes: 16,
    creditLabel: "Director",
    credit: "Lee Hyung-min",
    genres: ["Comedy", "Fantasy", "Romance"],
    cast: [
      CastMember(name: "Park Bo-young", role: "Do Bong-soon"),
      CastMember(name: "Park Hyung-sik", role: "Ahn Min-hyuk"),
      CastMember(name: "Ji Soo", role: "Gook Doo"),
    ],
  ),
  "dead poets society": MediaDetail(
    synopsis:
        "Seorang guru sastra yang nyentrik mengajar di sekolah asrama putra yang sangat konservatif. Lewat puisi, ia mendorong murid-muridnya berpikir mandiri dan menjalani hidup sepenuhnya, hingga cara mengajarnya berbenturan dengan aturan sekolah.",
    duration: "128 min",
    creditLabel: 'Director',
    credit: "Peter Weir",
    genres: ["Drama"],
    cast: [
      CastMember(name: "Robin Williams", role: "John Keating"),
      CastMember(name: "Robert Sean Leonard", role: "Neil Perry"),
      CastMember(name: "Ethan Hawke", role: "Todd Anderson"),
      CastMember(name: "Josh Charles", role: "Knox Overstreet"),
    ],
  ),
  "the passion of jeanne d arc": MediaDetail(
    synopsis:
        "Film bisu klasik yang menggambarkan pengadilan dan hari-hari terakhir Joan of Arc, gadis petani Prancis yang diadili para pemuka gereja atas tuduhan bidah. Kisahnya disorot lewat close-up wajah yang sangat emosional.",
    duration: "110 min",
    creditLabel: 'Director',
    credit: "Carl Theodor Dreyer",
    genres: ["Biography", "Drama", "History"],
    cast: [
      CastMember(name: "Maria Falconetti", role: "Jeanne d'Arc"),
      CastMember(name: "Eugene Silvain", role: "Bishop Pierre Cauchon"),
      CastMember(name: "Andre Berley", role: "Jean d'Estivet"),
      CastMember(name: "Maurice Schutz", role: "Nicolas Loyseleur"),
    ],
  ),
  "the notebook": MediaDetail(
    synopsis:
        "Seorang pria tua membacakan kisah cinta sebuah pasangan kepada seorang wanita di panti jompo. Cerita tentang Noah dan Allie, dua anak muda dari latar sosial berbeda yang jatuh cinta di musim panas, perlahan terungkap hubungannya dengan si pendengar.",
    duration: "123 min",
    creditLabel: 'Director',
    credit: "Nick Cassavetes",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Ryan Gosling", role: "Noah Calhoun"),
      CastMember(name: "Rachel McAdams", role: "Allie Hamilton"),
      CastMember(name: "James Garner", role: "Duke"),
      CastMember(name: "Gena Rowlands", role: "Older Allie"),
    ],
  ),
  "10 things i hate about you": MediaDetail(
    synopsis:
        "Cameron ingin mengajak Bianca berkencan, tapi ayah Bianca melarangnya berpacaran kecuali kakaknya yang galak, Kat, juga punya pacar. Cameron pun menyewa cowok misterius untuk mendekati Kat.",
    duration: "97 min",
    creditLabel: 'Director',
    credit: "Gil Junger",
    genres: ["Comedy", "Romance"],
    cast: [
      CastMember(name: "Heath Ledger", role: "Patrick Verona"),
      CastMember(name: "Julia Stiles", role: "Kat Stratford"),
      CastMember(name: "Joseph Gordon-Levitt", role: "Cameron James"),
      CastMember(name: "Larisa Oleynik", role: "Bianca Stratford"),
    ],
  ),
  "gone with the wind": MediaDetail(
    synopsis:
        "Di tengah Perang Saudara Amerika dan masa Rekonstruksi, Scarlett O'Hara, putri perkebunan Georgia yang keras kepala, berjuang mempertahankan tanah keluarganya sambil terjebak dalam hubungan rumit dengan Rhett Butler.",
    duration: "238 min",
    creditLabel: 'Director',
    credit: "Victor Fleming",
    genres: ["Drama", "History", "Romance"],
    cast: [
      CastMember(name: "Vivien Leigh", role: "Scarlett O'Hara"),
      CastMember(name: "Clark Gable", role: "Rhett Butler"),
      CastMember(name: "Olivia de Havilland", role: "Melanie Hamilton"),
      CastMember(name: "Leslie Howard", role: "Ashley Wilkes"),
    ],
  ),
  "the summer i turned pretty": MediaDetail(
    synopsis:
        "Setiap musim panas, Belly menghabiskan liburan di rumah pantai keluarga sahabat ibunya bersama dua kakak beradik, Conrad dan Jeremiah. Di musim panas ketika ia beranjak dewasa, perasaan lama dan cinta segitiga mulai mengubah persahabatan mereka.",
    duration: "29 episodes",
    episodes: 29,
    creditLabel: 'Creator',
    credit: "Jenny Han",
    genres: ["Drama", "Romance"],
    cast: [
      CastMember(name: "Lola Tung", role: "Isabel 'Belly' Conklin"),
      CastMember(name: "Christopher Briney", role: "Conrad Fisher"),
      CastMember(name: "Gavin Casalegno", role: "Jeremiah Fisher"),
      CastMember(name: "Rain Spencer", role: "Taylor Jewel"),
    ],
  ),
};

String _normalize(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[àáâãäåā]'), 'a')
      .replaceAll(RegExp(r'[èéêëē]'), 'e')
      .replaceAll(RegExp(r'[ìíîïī]'), 'i')
      .replaceAll(RegExp(r'[òóôõöō]'), 'o')
      .replaceAll(RegExp(r'[ùúûüū]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
}

final Map<String, MediaDetail> _detailLookup = {
  for (final entry in _detailByTitle.entries)
    _normalize(entry.key): entry.value,
};

MediaDetail detailFor(MediaModel media) {
  return _detailLookup[_normalize(media.title)] ??
      const MediaDetail(
        synopsis: 'Sinopsis belum tersedia.',
      );
}
List<int> sampleDistribution(String title) {
  const base = [310, 420, 380, 190, 90, 40, 20, 10, 5, 5];

  int seed = 0;
  for (final unit in title.codeUnits) {
    seed += unit;
  }

  return [
    for (int i = 0; i < base.length; i++) base[i] + (seed * (i + 3)) % 60,
  ];
}