// Proje adının 'hyper_casual' olduğunu varsayarak:
import 'package:hyper_casual/models/game_card.dart';
import 'package:hyper_casual/models/game_choice.dart';
import 'package:hyper_casual/models/choice_effect.dart';
import 'package:hyper_casual/models/game_ending.dart';

// Veya görece yollar kullanarak (daha garantili):
// import '../models/game_card.dart';
// import '../models/game_choice.dart';
// import '../models/choice_effect.dart';
// import '../models/game_ending.dart';

class CardDatabase {
  // --- OYUN SONLARI ---
  // Kartların kullandığı tüm oyun sonlarını buraya ekleyelim.
  static final Map<String, GameEnding> endings = {
    'STAT_DEATH': const GameEnding(
      id: 'STAT_DEATH',
      title: 'DÜŞÜŞ',
      text:
          'Kaynaklarından biri tükendi. Şehir kaosa sürüklendi ve sen tahtını kaybettin.',
    ),
    'SURGUN': const GameEnding(
      id: 'SURGUN',
      title: 'SÜRGÜN',
      text:
          'Tahtını kaybettin. Şehir artık başkasının. Geceler boyu gölgelerin arasında dolaşıyorsun, bir zamanlar krallığın olan yerleri uzaktan izleyerek.',
    ),
    'YENIDEN_DOGUS': const GameEnding(
      id: 'YENIDEN_DOGUS',
      title: 'YENİDEN DOĞUŞ',
      text:
          'Savaştan sonra şehri yeniden inşa ettin. Gölgeler çekildi, halk sana güveniyor. Zor günler geçti ama şimdi yeni bir çağ başlıyor.',
    ),
    'GOLGE_HUKUMDAR': const GameEnding(
      id: 'GOLGE_HUKUMDAR',
      title: 'GÖLGE HÜKÜMDAR',
      text:
          'Gölge kraliçesiyle evlendin. Artık yarı insan yarı gölgesin. Şehir sonsuza dek korunuyor ama sen artık eskisi gibi değilsin.',
    ),
    'ISIGA_DONUS': const GameEnding(
      id: 'ISIGA_DONUS',
      title: 'IŞIĞA DÖNÜŞ',
      text:
          'Gölge gücünü bıraktın. Zayıfsın ama özgürsün. Halk seni bağışladı. Şehir yavaş yavaş iyileşiyor.',
    ),
    'KARANLARIN_EFENDISI': const GameEnding(
      id: 'KARANLARIN_EFENDISI',
      title: 'KARANLARIN EFENDİSİ',
      text:
          'Gölge gücünü tamamen kabul ettin. Şimdi ölümsüzsün ama insanlığını kaybettin. Şehir sana tapıyor ama seni de korkuyla izliyor.',
    ),
    'FEDAKARLIK': const GameEnding(
      id: 'FEDAKARLIK',
      title: 'FEDAKARLIK',
      text:
          'Kendini feda ettin. Gölge gücün şehri korumaya devam ediyor ama sen artık yoksun. Halk seni efsane olarak hatırlıyor.',
    ),
  };

  // --- HİKAYE KARTLARI ---
  // Az önce oluşturduğumuz 25 kart
  static final Map<String, GameCard> cards = {
    '1': const GameCard(
      id: '1',
      title: 'İlk Gece',
      text:
          'Tahtın soğuk. Pencereden şehrin ışıkları titreşiyor. Ölen hükümdarın gölgesi hâlâ koridorlarda dolaşıyor.',
      choices: [
        GameChoice(
          text: "Gölgeyi kovmak için büyücü çağır.",
          effect: ChoiceEffect(golge: 10, hazine: -5),
        ),
        GameChoice(
          text: "Gölgeyle konuşmaya çalış.",
          effect: ChoiceEffect(golge: 5, halk: -3),
        ),
        GameChoice(
          text: "Görmezden gel ve uyumaya çalış.",
          effect: ChoiceEffect(halk: 2, bekciler: -3),
        ),
      ],
    ),
    '2': const GameCard(
      id: '2',
      title: 'Sabah Meclisi',
      text:
          'Danışmanlar salonunda bekliyor. Yaşlı vezir, çocuk büyücü ve genç kumandan. Hepsi birbirine düşman.',
      choices: [
        GameChoice(
          text: "Veziri dinle.",
          effect: ChoiceEffect(hazine: 8, golge: -4),
        ),
        GameChoice(
          text: "Büyücüye güven.",
          effect: ChoiceEffect(golge: 12, halk: -6),
        ),
        GameChoice(
          text: "Kumandanı ön plana çıkar.",
          effect: ChoiceEffect(bekciler: 10, hazine: -5),
        ),
      ],
    ),
    // ... '2': const GameCard(...) bloğundan sonra ...

    '3': const GameCard(
      id: '3',
      title: 'Pazar Yangını',
      text:
          "Sabah güneşi henüz doğmadan saray kapısı çalındı. Bekçi koşarak içeri girdi, yüzü telaşlı: 'Hükümdarım, pazarda yangın çıktı! Ateş hızla yayılıyor, halk panik içinde!' Pencereden baktığında şehrin göbeğinden yükselen dumanı görüyorsun. Bu yangın küçük değil.",
      choices: [
        // GDD'ye göre  bu seçeneği mini oyunu başlatacak şekilde güncelliyoruz
        GameChoice(
          text: "Hemen müdahale et!",
          // Efekt yok, çünkü GameProvider bunu yakalayıp mini oyunu başlatacak
        ),
        // GDD [cite: 1139] mini oyunu atlama seçeneği de öneriyor
        GameChoice(
          text: "Geç (Otomatik Başarısızlık)",
          // Başarısızlık cezalarını [cite: 859-863] doğrudan uygula
          effect: ChoiceEffect(
            halk: -30,
            hazine: -1500,
            bekciler: -15, // Ordu
            diplomasi: -20,
          ),
          // nextCardId '4' olmalı (Provider bunu otomatik yapacak)
        ),
      ],
    ),

// ... '4': const GameCard(...) bloğu devam ediyor ...
    '4': const GameCard(
      id: '4',
      title: 'Tüccarın Teklifi',
      text:
          'Yabancı bir tüccar altın dolu bir sandık getirmiş. Karşılığında şehrin liman haklarını istiyor.',
      choices: [
        GameChoice(
          text: "Anlaşmayı kabul et.",
          effect: ChoiceEffect(hazine: 20, halk: -8),
        ),
        GameChoice(
          text: "Tüccarı kovmak için bekçileri çağır.",
          effect: ChoiceEffect(bekciler: 5, hazine: -3),
        ),
        GameChoice(
          text: "Pazarlık yap.",
          effect: ChoiceEffect(hazine: 10, halk: 3),
        ),
      ],
    ),
    '5': const GameCard(
      id: '5',
      title: 'Gölge Tapınağı',
      text:
          'Eski tapınaktan gizemli sesler geliyor. Büyücüler buraya gireni lanetler, ama içinde hazine olduğu söyleniyor.',
      choices: [
        GameChoice(
          text: "Tapınağı aç.",
          effect: ChoiceEffect(golge: 15, bekciler: -5),
        ),
        GameChoice(
          text: "Tapınağı yıkarak ortadan kaldır.",
          effect: ChoiceEffect(golge: -12, halk: 7),
        ),
        GameChoice(
          text: "Tapınağı bekçiler altında tut.",
          effect: ChoiceEffect(bekciler: 8, golge: -5),
        ),
      ],
    ),
    '6': const GameCard(
      id: '6',
      title: 'Açlık Başlıyor',
      text:
          'Depolar yarı boş. Halk ekmek kuyruğunda. Vezir vergi artırılmasını öneriyor.',
      choices: [
        GameChoice(
          text: "Vergiyi artır.",
          effect: ChoiceEffect(hazine: 12, halk: -15),
        ),
        GameChoice(
          text: "Kendi hazineni harcayarak yardım et.",
          effect: ChoiceEffect(hazine: -10, halk: 18),
        ),
        GameChoice(
          text: "Büyücülerden yiyecek büyüsü iste.",
          effect: ChoiceEffect(golge: -8, halk: 10),
        ),
      ],
    ),
    '7': const GameCard(
      id: '7',
      title: 'Kumandanın İtirafı',
      text:
          'Genç kumandan gece sana gelir. Bekçilerin yarısının eski hükümdarın gölgesine sadık olduğunu söyler.',
      choices: [
        GameChoice(
          text: "Sadık olmayanları temizle.",
          effect: ChoiceEffect(bekciler: 15, halk: -10),
        ),
        GameChoice(
          text: "Gölge ile anlaşma yap.",
          effect: ChoiceEffect(golge: 12, bekciler: -8),
        ),
        GameChoice(
          text: "Hiçbir şey yapma, zamanla çözülür.",
          effect: ChoiceEffect(bekciler: -5, golge: 5),
        ),
      ],
    ),
    '8': const GameCard(
      id: '8',
      title: 'Çocuk Büyücünün Kehaneti',
      text:
          'Büyücü sana bakıyor: "Şehir üç ayın sonunda ya ışığa kavuşacak ya da karanlığa gömülecek."',
      choices: [
        GameChoice(
          text: "Işığı seç.",
          effect: ChoiceEffect(golge: -10, halk: 12),
        ),
        GameChoice(
          text: "Karanlığı kucakla.",
          effect: ChoiceEffect(golge: 18, halk: -12),
        ),
        GameChoice(
          text: "Kehanete inanma.",
          effect: ChoiceEffect(golge: -3, hazine: 5),
        ),
      ],
    ),
    '9': const GameCard(
      id: '9',
      title: 'Suikast Girişimi',
      text:
          'Geceyarısı bıçak sesleri. Oda hizmetçisi sana saldırıyor. Ama gözleri boş, sanki kontrol altında.',
      choices: [
        GameChoice(
          text: "Hizmetçiyi öldür.",
          effect: ChoiceEffect(bekciler: 5, halk: -3),
        ),
        GameChoice(
          text: "Büyücülere götür.",
          effect: ChoiceEffect(golge: 8, bekciler: -4),
        ),
        GameChoice(
          text: "Onu bağışla.",
          effect: ChoiceEffect(halk: 10, bekciler: -8),
        ),
      ],
    ),
    '10': const GameCard(
      id: '10',
      title: 'Liman Kuşatması',
      text:
          'Yabancı bir donanma limanda. Savaş mı yoksa ticaret mi olacak? Karara vakit kalmadı.',
      choices: [
        GameChoice(
          text: "Savaş ilan et.",
          effect: ChoiceEffect(bekciler: 10, hazine: -12),
        ),
        GameChoice(
          text: "Diplomatik görüşmeye çağır.",
          effect: ChoiceEffect(hazine: 8, bekciler: -5),
        ),
        GameChoice(
          text: "Gölge büyüsüyle korkut.",
          effect: ChoiceEffect(golge: -12, bekciler: 8),
        ),
      ],
    ),
    '11': const GameCard(
      id: '11',
      title: 'Eski Dostun Mektubu',
      text:
          'Sürgündeki eski dostun mektup göndermiş: "Sana ihanet ettim ama affedersen şehre dönerim."',
      choices: [
        GameChoice(
          text: "Affet ve geri çağır.",
          effect: ChoiceEffect(halk: 8, bekciler: -6),
        ),
        GameChoice(
          text: "Sürgünde kal.",
          effect: ChoiceEffect(bekciler: 5, halk: -3),
        ),
        GameChoice(
          text: "İdam emri ver.",
          effect: ChoiceEffect(bekciler: 10, halk: -10),
        ),
      ],
    ),
    '12': const GameCard(
      id: '12',
      title: 'Gizli Toplantı',
      text:
          'Gece yarısı gizli bir toplantı yapılıyor. Soyluların bazıları seni devirmek istiyor.',
      choices: [
        GameChoice(
          text: "Toplantıyı basmak için bekçileri gönder.",
          effect: ChoiceEffect(bekciler: 12, halk: -8),
        ),
        GameChoice(
          text: "Casuslarla izle.",
          effect: ChoiceEffect(golge: 8, hazine: -4),
        ),
        GameChoice(
          text: "Toplantıya katıl.",
          effect: ChoiceEffect(halk: 10, bekciler: -5),
        ),
      ],
    ),
    '13': const GameCard(
      id: '13',
      title: 'Salgın Başladı',
      text:
          'Şehrin fakir mahallelerinde hastalık yayılıyor. Zenginler mahalleleri kapatmak istiyor.',
      choices: [
        GameChoice(
          text: "Mahalleleri kapat.",
          effect: ChoiceEffect(halk: -15, bekciler: 8),
        ),
        GameChoice(
          text: "Herkese ücretsiz tedavi.",
          effect: ChoiceEffect(hazine: -15, halk: 20),
        ),
        GameChoice(
          text: "Büyücülerden şifa büyüsü iste.",
          effect: ChoiceEffect(golge: -10, halk: 12),
        ),
      ],
    ),
    '14': const GameCard(
      id: '14',
      title: 'Vezirin İhaneti',
      text:
          'Yaşlı vezir hazineden çalıyor. Kanıtlar net ama o yıllardır sadık.',
      choices: [
        GameChoice(
          text: "İdam et.",
          effect: ChoiceEffect(bekciler: 8, halk: -5),
        ),
        GameChoice(
          text: "Affet ama görevden al.",
          effect: ChoiceEffect(halk: 8, hazine: -3),
        ),
        GameChoice(
          text: "Görmezden gel.",
          effect: ChoiceEffect(hazine: -10, golge: 5),
        ),
      ],
    ),
    '15': const GameCard(
      id: '15',
      title: 'Kayıp Prenses',
      text:
          'Komşu krallıktan kaçan bir prenses şehre sığınmış. Onu korumak savaş getirebilir.',
      choices: [
        GameChoice(
          text: "Prensesi koru.",
          effect: ChoiceEffect(bekciler: -10, halk: 12),
        ),
        GameChoice(
          text: "Geri gönder.",
          effect: ChoiceEffect(hazine: 8, halk: -8),
        ),
        GameChoice(
          text: "Gizlice sakla.",
          effect: ChoiceEffect(golge: 10, bekciler: -5),
        ),
      ],
    ),
    '16': const GameCard(
      id: '16',
      title: 'Kutsal Gün',
      text:
          'Şehrin en büyük bayramı. Halk senden törensel bir konuşma bekliyor.',
      choices: [
        GameChoice(
          text: "Umut dolu bir konuşma yap.",
          effect: ChoiceEffect(halk: 15, golge: -5),
        ),
        GameChoice(
          text: "Gücünü göster.",
          effect: ChoiceEffect(bekciler: 10, halk: -3),
        ),
        GameChoice(
          text: "Sessiz kal.",
          effect: ChoiceEffect(halk: -8, golge: 5),
        ),
      ],
    ),
    '17': const GameCard(
      id: '17',
      title: 'Rüya mı Gerçek mi?',
      text:
          'Geceler boyu aynı rüyayı görüyorsun: şehir alevler içinde. Büyücü "Bu bir uyarı" diyor.',
      choices: [
        GameChoice(
          text: "Büyücüye güven ve hazırlık yap.",
          effect: ChoiceEffect(golge: 10, hazine: -8),
        ),
        GameChoice(
          text: "Sadece bir rüya, unut.",
          effect: ChoiceEffect(golge: -5, halk: 3),
        ),
        GameChoice(
          text: "Rüyanın kaynağını bul.",
          effect: ChoiceEffect(golge: 8, bekciler: -4),
        ),
      ],
    ),
    '18': const GameCard(
      id: '18',
      title: 'Altin Madenı',
      text:
          'Şehir dışında altın madeni bulundu. Ama maden gölge yaratıklarının topraklarında.',
      choices: [
        GameChoice(
          text: "Madeni aç.",
          effect: ChoiceEffect(hazine: 25, golge: -15),
        ),
        GameChoice(
          text: "Yaratıklarla anlaşma yap.",
          effect: ChoiceEffect(golge: 15, hazine: 10),
        ),
        GameChoice(
          text: "Madene dokunma.",
          effect: ChoiceEffect(golge: 8, halk: -5),
        ),
      ],
    ),
    '19': const GameCard(
      id: '19',
      title: 'İsyan Kıvılcımı',
      text:
          'Meydanda kalabalık toplanıyor. "Halk aç, yönetim zengin!" diye bağırıyorlar.',
      choices: [
        GameChoice(
          text: "İsyanı bastır.",
          effect: ChoiceEffect(bekciler: 12, halk: -20),
        ),
        GameChoice(
          text: "Halka yiyecek dağıt.",
          effect: ChoiceEffect(hazine: -15, halk: 18),
        ),
        GameChoice(
          text: "İsyancılarla görüş.",
          effect: ChoiceEffect(halk: 10, bekciler: -8),
        ),
      ],
    ),
    '20': const GameCard(
      id: '20',
      title: 'Gölge Kraliçesi',
      text:
          'Gölge aleminin kraliçesi sana teklif gönderiyor: "Benimle evlen, şehir sonsuza dek korunsun."',
      choices: [
        GameChoice(
          text: "Kabul et.",
          effect: ChoiceEffect(golge: 30, halk: -15),
        ),
        GameChoice(
          text: "Reddet.",
          effect: ChoiceEffect(golge: -20, halk: 10),
        ),
        GameChoice(
          text: "Zaman iste.",
          effect: ChoiceEffect(golge: 5, halk: -3),
        ),
      ],
    ),
    '21': const GameCard(
      id: '21',
      title: 'Büyük Deprem',
      text:
          'Şehir sarsılıyor. Binalar yıkıldı, halk panikle kaçışıyor. Acil eylem gerekli.',
      choices: [
        GameChoice(
          text: "Tüm kaynakları kurtarma için kullan.",
          effect: ChoiceEffect(hazine: -20, halk: 20),
        ),
        GameChoice(
          text: "Sadece sarayı koru.",
          effect: ChoiceEffect(hazine: 5, halk: -25),
        ),
        GameChoice(
          text: "Büyücüleri yıkıntıları tamir etmesi için çağır.",
          effect: ChoiceEffect(golge: -15, halk: 15),
        ),
      ],
    ),
    '22': const GameCard(
      id: '22',
      title: 'Son Seçim',
      text:
          'Şehir iki yol ayrımında. Ya gölgeyi tamamen kovacaksın ya da onunla birleşeceksin.',
      choices: [
        GameChoice(
          text: "Gölgeyi kov, ışık getir.",
          effect: ChoiceEffect(golge: -30, halk: 25),
        ),
        GameChoice(
          text: "Gölgeyle birleş, gücü kabul et.",
          effect: ChoiceEffect(golge: 35, halk: -20),
        ),
        GameChoice(
          text: "Dengeyi koru.",
          effect: ChoiceEffect(golge: 10, halk: 10),
        ),
      ],
    ),
    '23': const GameCard(
      id: '23',
      title: 'Kumandanın Darbesi',
      text: 'Kumandan sarayı kuşattı. Ya tahttan ineceksin ya da savaşacaksın.',
      choices: [
        GameChoice(
          text: "Tahttan in, şehri terk et.",
          endingId: 'SURGUN',
        ),
        GameChoice(
          text: "Savaş.",
          effect: ChoiceEffect(bekciler: -20, golge: 15),
          nextCardId: '24',
        ),
        GameChoice(
          text: "Gölge gücüyle kumandanı kontrol et.",
          effect: ChoiceEffect(golge: -25, bekciler: 20),
          nextCardId: '25',
        ),
      ],
    ),
    '24': const GameCard(
      id: '24',
      title: 'Zafer ya da Ölüm',
      text:
          'Savaş kanlı geçti. Kumandan öldü ama şehir harabe. Halk seni suçluyor.',
      choices: [
        GameChoice(
          text: "Şehri yeniden inşa et.",
          endingId: 'YENIDEN_DOGUS',
        ),
        GameChoice(
          text: "Şehri terk et.",
          endingId: 'SURGUN',
        ),
        GameChoice(
          text: "Gölge kraliçesinin teklifini kabul et.",
          endingId: 'GOLGE_HUKUMDAR',
        ),
      ],
    ),
    '25': const GameCard(
      id: '25',
      title: 'Sessiz Taht',
      text:
          'Kumandan senin gölge kuklana dönüştü. Halk korku içinde. Sen artık bir hükümdarsın ama insan değil.',
      choices: [
        GameChoice(
          text: "Gölge gücünü bırak, insanlığına dön.",
          endingId: 'ISIGA_DONUS',
        ),
        GameChoice(
          text: "Gücü koru, ebedi yönet.",
          endingId: 'KARANLARIN_EFENDISI',
        ),
        GameChoice(
          text: "Kendini yok et, şehri kurtar.",
          endingId: 'FEDAKARLIK',
        ),
      ],
    ),
  };
}
