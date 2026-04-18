[🇬🇧 English](README.md) • [🇹🇷 Türkçe](README_tr.md) • [🇦🇿 Azərbaycanca](README_az.md) • [🇷🇺 Русский](README_ru.md) • [🇪🇸 Español](README_es.md)

---

<p align="center">
   <img width="256" height="256" alt="Ink Irony" src="https://github.com/user-attachments/assets/033c1824-d6fc-4184-8d34-ca439122fcd5" />
</p>

# Ink & Irony (Vahşi Eskiz Defteri) 🖋️📓

**Ink & Irony**, tamamen **SwiftUI** ve **SwiftData** ile oluşturulmuş, özenle tasarlanmış premium bir iOS kelime tahmin oyunudur (Adam Asmaca stili). Dinamik titreyen mürekkep animasyonları, sürükleyici dokunsal geri bildirimler ve her hataya tepki veren acımasız bir masaarası alay (taunt) sistemi ile tamamlanan benzersiz bir "el çizimi eskiz defteri" estetiği sunar.

[**App Store'dan İndir**](https://apps.apple.com/app/id6760973464)

---

## 🎨 Özellikler & Öne Çıkanlar

### 1. El Çizimi Eskiz Defteri Estetiği
- **Dinamik UI:** Özel `Shape` eklentileri, gerçek kağıt üzerinde kalem çizimini simüle eden titreyen, katmanlı vuruş animasyonları oluşturur.
- **Tema Motoru:** Semantik tasarım tokenleri (`inkPrimary`, `errorInk`, vb.) ile hem Açık Modu ("Aged Parchment") hem de Karanlık Modu ("Charcoal Sketch") destekleyen gelişmiş `ThemeManager`.
- **Özel Tipografi:** El yazısı ve daktilo damgalarını taklit etmek için entegre edilmiş özel yazı tipleri (`Caveat`, `Special Elite`, `Courier Prime`).

### 2. Derin Yerelleştirme (5 Dil)
Oyun özel bir `LocalizationService` kullanılarak tamamen yerelleştirilmiştir:
- 🇺🇸 İngilizce
- 🇹🇷 Türkçe
- 🇦🇿 Azerbaycanca
- 🇷🇺 Rusça
- 🇪🇸 İspanyolca

### 3. Devasa Kelime Sözlükleri
Sağlam bir `WordRepository`, belirli çevrimdışı JSON sözlüklerine bölünmüş binlerce yerelleştirilmiş kelimeyi yönetir.
- **Zorluk Seviyeleri:** Kolay, Orta, Zor, Kabus.
- **Kategoriler:** Hayvanlar, Bilim, Tarih, Teknoloji, Anatomi, Soyut Kelime Hazinesi ve daha fazlası.

### 4. Etkileşimli ve Sürükleyici Oynanış
- **Acımasız Alaylar:** Sahte bir çevrimdışı yapay zeka (`TauntService`), dilinize, zorluk derecesine ve yaptığınız hata sayısına göre bağlama duyarlı zorba şakalar sunar.
- **AVFoundation & CoreHaptics:** Her eyleme gerçekçi kağıt yırtıkları, kalem kırılmaları, mürekkep çizikleri ve hassas dokunsal atımlar eşlik eder.

### 5. Liderlik Tablosu & Analitikler (SwiftData)
- **Oyun Oturumları:** Her galibiyet veya mağlubiyet iOS 17'nin **SwiftData**'sı kullanılarak kalıcı olarak saklanır.
- **Liderlik Tablosu Görünümü:** En yüksek puanlarınızı görmek için geçmiş performanslarınızı dile göre filtreleyin (`@Query` kullanılarak dinamik filtrelenir).
- **Seri Takibi:** Mevcut ve tüm zamanların en yüksek kazanma serilerini izler.

---

## 🛠 Teknoloji Yığını & Mimari

- **Framework:** SwiftUI
- **Veritabanı:** SwiftData
- **Mimari Desen:** MVVM (Model-View-ViewModel) + Services (`AudioService`, `HapticService`, `TauntService`, `WordRepository`).
- **Veri Formatı:** Sözlükler ve alaylar için Decodable JSON.
- **Minimum iOS Sürümü:** iOS 17.0+ (SwiftData ve Observation framework'leri nedeniyle).

---

## 🚀 Projeyi Çalıştırma

1. Depoyu klonlayınız.
2. `Ink.xcodeproj` dosyasını **Xcode 15** veya daha yeni bir sürümle açın.
3. iOS Simülatörü veya **iOS 17.0+** çalıştıran fiziksel bir cihaz seçin.
4. **Cmd + R** tuşlarına basarak çalıştırın.

---

## 📫 İletişim & Destek

**Cavid Abbasaliyev** tarafından oluşturuldu.

Herhangi bir sorunuz, geri bildiriminiz varsa veya sadece merhaba demek isterseniz ulaşabilirsiniz:
- **Email:** [abbas3liyev@gmail.com](mailto:abbas3liyev@gmail.com)
- **LinkedIn:** [Cavid Abbasaliyev](https://www.linkedin.com/in/abbas3liyev/)
