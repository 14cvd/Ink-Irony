//
//  LocalizationService.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import Foundation

public struct LocalizationService {
    public static func t(_ key: String, lang: Language) -> String {
        return translations[key]?[lang] ?? key
    }
    
    /// Helper for hint count suffix "(N left)" in local language
    public static func hintSuffix(_ count: Int, lang: Language) -> String {
        switch lang {
        case .english:  return "(\(count) left)"
        case .turkish:  return "(\(count) kaldı)"
        case .azerbaijani: return "(\(count) qaldı)"
        case .spanish:  return "(quedan \(count))"
        case .russian:  return "(осталось \(count))"
        }
    }
    
    private static let translations: [String: [Language: String]] = [
        
        // ─── GameSetupView ───
        "NEW GAME": [.english: "NEW GAME", .spanish: "NUEVO JUEGO", .turkish: "YENİ OYUN", .azerbaijani: "YENİ OYUN", .russian: "НОВАЯ ИГРА"],
        "Select Language:": [.english: "Select Language:", .spanish: "Seleccionar Idioma:", .turkish: "Dil Seç:", .azerbaijani: "Dil Seç:", .russian: "Выберите Язык:"],
        "Select Difficulty:": [.english: "Select Difficulty:", .spanish: "Seleccionar Dificultad:", .turkish: "Zorluk Seç:", .azerbaijani: "Çətinlik Seç:", .russian: "Выберите Сложность:"],
        "START SKETCHING": [.english: "START SKETCHING", .spanish: "COMENZAR A DIBUJAR", .turkish: "ÇİZİME BAŞLA", .azerbaijani: "ÇƏKMƏYƏ BAŞLA", .russian: "НАЧАТЬ РИСОВАТЬ"],
        "Choose Topic": [.english: "Choose Topic", .spanish: "Elige Tema", .turkish: "Konu Seç", .azerbaijani: "Mövzu Seç", .russian: "Выбери Тему"],
        
        // ─── OnboardingFlow ───
        "INK & IRONY": [.english: "INK & IRONY", .spanish: "TINTA E IRONÍA", .turkish: "MÜREKKEP & İRONİ", .azerbaijani: "MÜRƏKKƏB VƏ İRONİYA", .russian: "ЧЕРНИЛА И ИРОНИЯ"],
        "The Teacher is waiting...\nDon't fail.": [
            .english: "The Teacher is waiting...\nDon't fail.",
            .turkish: "Öğretmen bekliyor...\nBaşarısız olma.",
            .azerbaijani: "Müəllim gözləyir...\nUğursuz olma.",
            .spanish: "El Profesor está esperando...\nNo falles.",
            .russian: "Учитель ждёт...\nНе провались."
        ],
        "ENTER": [.english: "ENTER", .spanish: "ENTRAR", .turkish: "GİRİŞ", .azerbaijani: "DAXİL OL", .russian: "ВОЙТИ"],
        
        // ─── MainMenu ───
        "START EXAM": [.english: "START EXAM", .spanish: "INICIAR EXAMEN", .turkish: "SINAVA BAŞLA", .azerbaijani: "İMTAHANA BAŞLA", .russian: "НАЧАТЬ ЭКЗАМЕН"],
        "DAILY CHALLENGE": [.english: "DAILY CHALLENGE", .spanish: "DESAFÍO DIARIO", .turkish: "GÜNLÜK SINAV", .azerbaijani: "GÜNLÜK İMTAHAN", .russian: "ЕЖЕДНЕВНЫЙ ЭКЗАМЕН"],
        "RECORDS": [.english: "RECORDS", .spanish: "RÉCORDS", .turkish: "REKORLAR", .azerbaijani: "REKORLAR", .russian: "РЕКОРДЫ"],
        "SETTINGS": [.english: "SETTINGS", .spanish: "AJUSTES", .turkish: "AYARLAR", .azerbaijani: "PARAMETRLƏR", .russian: "НАСТРОЙКИ"],
        
        // ─── Difficulties ───
        "EASY": [.english: "EASY", .spanish: "FÁCIL", .turkish: "KOLAY", .azerbaijani: "ASAN", .russian: "ЛЕГКО"],
        "MEDIUM": [.english: "MEDIUM", .spanish: "MEDIO", .turkish: "ORTA", .azerbaijani: "ORTA", .russian: "СРЕДНЕ"],
        "HARD": [.english: "HARD", .spanish: "DIFÍCIL", .turkish: "ZOR", .azerbaijani: "ÇƏTİN", .russian: "СЛОЖНО"],
        "NIGHTMARE": [.english: "NIGHTMARE", .spanish: "PESADILLA", .turkish: "KABUS", .azerbaijani: "KABUS", .russian: "КОШМАР"],
        
        // ─── GameView ───
        "LIVES: ": [.english: "LIVES: ", .spanish: "VIDAS: ", .turkish: "CAN: ", .azerbaijani: "CAN: ", .russian: "ЖИЗНИ: "],
        "LIVES": [.english: "LIVES", .spanish: "VIDAS", .turkish: "CAN", .azerbaijani: "CAN", .russian: "ЖИЗНИ"],
        "Guess a letter...": [.english: "Guess a letter...", .spanish: "Adivina una letra...", .turkish: "Bir harf tahmin et...", .azerbaijani: "Bir hərf tap...", .russian: "Угадай букву..."],
        "YOU SURVIVED.": [.english: "YOU SURVIVED.", .spanish: "SOBREVIVISTE.", .turkish: "HAYATTA KALDIN.", .azerbaijani: "SAĞ QALDIN.", .russian: "ТЫ ВЫЖИЛ."],
        "GAME OVER.": [.english: "GAME OVER.", .spanish: "FIN DEL JUEGO.", .turkish: "OYUN BİTTİ.", .azerbaijani: "OYUN BİTDİ.", .russian: "ИГРА ОКОНЧЕНА."],
        "HINT": [.english: "HINT", .spanish: "PISTA", .turkish: "İPUCU", .azerbaijani: "İPUCU", .russian: "ПОДСКАЗКА"],
        
        // ─── Victory Screen ───
        "PASSED!": [.english: "PASSED!", .spanish: "¡APROBADO!", .turkish: "GEÇTİN!", .azerbaijani: "KEÇDİN!", .russian: "СДАЛ!"],
        "NEXT WORD": [.english: "NEXT WORD", .spanish: "SIGUIENTE PALABRA", .turkish: "SONRAKİ KELİME", .azerbaijani: "NÖVBƏTİ SÖZ", .russian: "СЛЕДУЮЩЕЕ СЛОВО"],
        "MAIN MENU": [.english: "MAIN MENU", .spanish: "MENÚ PRINCIPAL", .turkish: "ANA MENÜ", .azerbaijani: "ANA MENYU", .russian: "ГЛАВНОЕ МЕНЮ"],
        "Time": [.english: "Time", .spanish: "Tiempo", .turkish: "Süre", .azerbaijani: "Vaxt", .russian: "Время"],
        "Lives": [.english: "Lives", .spanish: "Vidas", .turkish: "Can", .azerbaijani: "Can", .russian: "Жизни"],
        "Score": [.english: "Score", .spanish: "Puntos", .turkish: "Puan", .azerbaijani: "Bal", .russian: "Счёт"],
        "Definition": [.english: "Definition", .spanish: "Definición", .turkish: "Tanım", .azerbaijani: "Tərif", .russian: "Определение"],
        
        // ─── Defeat Screen ───
        "FAILED.": [.english: "FAILED.", .spanish: "SUSPENSO.", .turkish: "KALDI.", .azerbaijani: "QALDI.", .russian: "ПРОВАЛ."],
        "The word was:": [.english: "The word was:", .spanish: "La palabra era:", .turkish: "Kelime buydu:", .azerbaijani: "Söz bu idi:", .russian: "Слово было:"],
        "TRY AGAIN": [.english: "TRY AGAIN", .spanish: "INTENTAR DE NUEVO", .turkish: "TEKRAR DENE", .azerbaijani: "YENİDƏN CƏHD ET", .russian: "ЕЩЁ РАЗ"],
        
        // ─── Records / Stats ───
        "LEADERBOARD": [.english: "LEADERBOARD", .spanish: "CLASIFICACIÓN", .turkish: "LİDERLİK TABLOSU", .azerbaijani: "LİDERLƏR CƏDVƏLİ", .russian: "ТАБЛИЦА ЛИДЕРОВ"],
        "MY STATS": [.english: "MY STATS", .spanish: "MIS ESTADÍSTICAS", .turkish: "İSTATİSTİKLERİM", .azerbaijani: "STATİSTİKAM", .russian: "МОЯ СТАТИСТИКА"],
        "ACHIEVEMENTS": [.english: "ACHIEVEMENTS", .spanish: "LOGROS", .turkish: "BAŞARILAR", .azerbaijani: "NAİLİYYƏTLƏR", .russian: "ДОСТИЖЕНИЯ"],
        "No victorious records found\nfor this language.": [
            .english: "No victorious records found\nfor this language.",
            .spanish: "No se encontraron victorias\npara este idioma.",
            .turkish: "Bu dil için zafer\nkaydı bulunamadı.",
            .azerbaijani: "Bu dil üçün qələbə\nrekordu tapılmadı.",
            .russian: "Для этого языка\nнет победных рекордов."
        ],
        "Day Streak": [.english: "Day Streak", .spanish: "Racha diaria", .turkish: "Günlük seri", .azerbaijani: "Günlük seriya", .russian: "дней подряд"],
        "Total Wins": [.english: "Total Wins", .spanish: "Victorias totales", .turkish: "Toplam Kazanma", .azerbaijani: "Cəmi Qalibiyyət", .russian: "Всего побед"],
        "Total Losses": [.english: "Total Losses", .spanish: "Derrotas totales", .turkish: "Toplam Kaybetme", .azerbaijani: "Cəmi Məğlubiyyət", .russian: "Всего поражений"],
        "Win Rate": [.english: "Win Rate", .spanish: "Porcentaje de victorias", .turkish: "Kazanma Oranı", .azerbaijani: "Qalibiyyət faizi", .russian: "Процент побед"],
        "Best Score": [.english: "Best Score", .spanish: "Mejor puntuación", .turkish: "En Yüksek Puan", .azerbaijani: "Ən yüksək bal", .russian: "Лучший результат"],
        "Best Category": [.english: "Best Category", .spanish: "Mejor categoría", .turkish: "En iyi kategori", .azerbaijani: "Ən yaxşı kateqoriya", .russian: "Лучшая категория"],
        "Win rate by difficulty": [.english: "Win rate by difficulty", .spanish: "Tasa de victoria por dificultad", .turkish: "Zorluk bazında kazanma oranı", .azerbaijani: "Çətinliyə görə qalibiyyət faizi", .russian: "Победы по сложности"],
        "unlocked": [.english: "unlocked", .spanish: "desbloqueados", .turkish: "kazanıldı", .azerbaijani: "açıldı", .russian: "открыто"],
        
        // ─── Daily Challenge ───
        "DAILY EXAM": [.english: "DAILY EXAM", .spanish: "EXAMEN DIARIO", .turkish: "GÜNLÜK SINAV", .azerbaijani: "GÜNLÜK İMTAHAN", .russian: "ЕЖЕДНЕВНЫЙ ЭКЗАМЕН"],
        "One word. All players. Same chance.": [
            .english: "One word. All players. Same chance.",
            .turkish: "Bir kelime. Tüm oyuncular. Aynı şans.",
            .azerbaijani: "Bir söz. Bütün oyunçular. Eyni şans.",
            .spanish: "Una palabra. Todos los jugadores. La misma oportunidad.",
            .russian: "Одно слово. Все игроки. Равные шансы."
        ],
        "TODAY'S CLASS": [.english: "TODAY'S CLASS", .spanish: "LA CLASE DE HOY", .turkish: "BUGÜNKÜ SINIF", .azerbaijani: "BUGÜNKÜ SINIF", .russian: "СЕГОДНЯШНИЙ КЛАСС"],
        "No classmates yet.": [
            .english: "No classmates yet.",
            .turkish: "Henüz sınıf arkadaşı yok.",
            .azerbaijani: "Hələ sinif yoldaşı yoxdur.",
            .spanish: "Aún no hay compañeros.",
            .russian: "Пока нет одноклассников."
        ],
        "Already completed today.": [
            .english: "Already completed today.",
            .turkish: "Bugün zaten tamamlandı.",
            .azerbaijani: "Bu gün artıq tamamlandı.",
            .spanish: "Ya completado hoy.",
            .russian: "Уже пройдено сегодня."
        ],
        "Come back tomorrow!": [
            .english: "Come back tomorrow!",
            .turkish: "Yarın tekrar gel!",
            .azerbaijani: "Sabah yenidən gəl!",
            .spanish: "¡Vuelve mañana!",
            .russian: "Возвращайся завтра!"
        ],
        "Rank": [.english: "Rank", .spanish: "Rango", .turkish: "Sıra", .azerbaijani: "Sıra", .russian: "Ранг"],
        "Name": [.english: "Name", .spanish: "Nombre", .turkish: "İsim", .azerbaijani: "Ad", .russian: "Имя"],
        
        // ─── Settings ───
        "APPEARANCE": [.english: "APPEARANCE", .spanish: "APARIENCIA", .turkish: "GÖRÜNÜM", .azerbaijani: "GÖRÜNÜŞ", .russian: "ВНЕШНИЙ ВИД"],
        "Dark Mode": [.english: "Dark Mode", .spanish: "Modo oscuro", .turkish: "Karanlık Mod", .azerbaijani: "Qaranlıq Mod", .russian: "Тёмный режим"],
        "SOUND & HAPTICS": [.english: "SOUND & HAPTICS", .spanish: "SONIDO Y HÁPTICOS", .turkish: "SES & HAP TİK", .azerbaijani: "SƏS VƏ HAP TİK", .russian: "ЗВУК И ВИБРАЦИЯ"],
        "Sound FX": [.english: "Sound FX", .spanish: "Efectos de sonido", .turkish: "Ses Efektleri", .azerbaijani: "Səs Effektləri", .russian: "Звуковые эффекты"],
        "Haptic Feedback": [.english: "Haptic Feedback", .spanish: "Retroalimentación háptica", .turkish: "Dokunsal Geri Bildirim", .azerbaijani: "Haptik Rəy", .russian: "Вибрация"],
        "GAME": [.english: "GAME", .spanish: "JUEGO", .turkish: "OYUN", .azerbaijani: "OYUN", .russian: "ИГРА"],
        "Show Timer": [.english: "Show Timer", .spanish: "Mostrar temporizador", .turkish: "Zamanlayıcıyı Göster", .azerbaijani: "Taymeri Göstər", .russian: "Показывать таймер"],
        "Teacher Quotes": [.english: "Teacher Quotes", .spanish: "Frases del Profesor", .turkish: "Öğretmen Alıntıları", .azerbaijani: "Müəllim Sözləri", .russian: "Цитаты учителя"],
        "ACCOUNT": [.english: "ACCOUNT", .spanish: "CUENTA", .turkish: "HESAP", .azerbaijani: "HESAB", .russian: "АККАУНТ"],
        "Username": [.english: "Username", .spanish: "Nombre de usuario", .turkish: "Kullanıcı Adı", .azerbaijani: "İstifadəçi adı", .russian: "Имя пользователя"],
        "DANGER ZONE": [.english: "DANGER ZONE", .spanish: "ZONA DE PELIGRO", .turkish: "TEHLİKE BÖLGESİ", .azerbaijani: "TƏHLÜKƏLİ BÖLGƏ", .russian: "ОПАСНАЯ ЗОНА"],
        "RESET PROGRESS": [.english: "RESET PROGRESS", .spanish: "REINICIAR PROGRESO", .turkish: "İLERLEMEYİ SIFIRLA", .azerbaijani: "İRƏLİLƏMƏNİ SIFIRLA", .russian: "СБРОСИТЬ ПРОГРЕСС"],
        "Reset all progress? This cannot be undone.": [
            .english: "Reset all progress? This cannot be undone.",
            .turkish: "Tüm ilerleme sıfırlansın mı? Bu geri alınamaz.",
            .azerbaijani: "Bütün irəliləməni sıfırlamaq? Bu geri alına bilməz.",
            .spanish: "¿Reiniciar todo el progreso? No se puede deshacer.",
            .russian: "Сбросить весь прогресс? Это нельзя отменить."
        ],
        "Reset": [.english: "Reset", .spanish: "Reiniciar", .turkish: "Sıfırla", .azerbaijani: "Sıfırla", .russian: "Сбросить"],
        "Cancel": [.english: "Cancel", .spanish: "Cancelar", .turkish: "İptal", .azerbaijani: "Ləğv et", .russian: "Отмена"],
        
        // ─── Legacy results (kept for back-compat) ───
        "NAME: ": [.english: "NAME: ", .spanish: "NOMBRE: ", .turkish: "İSİM: ", .azerbaijani: "AD: ", .russian: "ИМЯ: "],
        "Player 1": [.english: "Player 1", .spanish: "Jugador 1", .turkish: "Oyuncu 1", .azerbaijani: "Oyunçu 1", .russian: "Игрок 1"],
        "SUBJECT: ": [.english: "SUBJECT: ", .spanish: "ASUNTO: ", .turkish: "KONU: ", .azerbaijani: "MÖVZU: ", .russian: "ПРЕДМЕТ: "],
        "DIFFICULTY: ": [.english: "DIFFICULTY: ", .spanish: "DIFICULTAD: ", .turkish: "ZORLUK: ", .azerbaijani: "ÇƏTİNLİK: ", .russian: "СЛОЖНОСТЬ: "],
        "CURRENT STREAK: ": [.english: "CURRENT STREAK: ", .spanish: "RACHA ACTUAL: ", .turkish: "MEVCUT SERİ: ", .azerbaijani: "CARI SERİYA: ", .russian: "ТЕКУЩАЯ СЕРИЯ: "],
        "HIGH SCORE STREAK: ": [.english: "HIGH SCORE STREAK: ", .spanish: "MEJOR RACHA: ", .turkish: "EN İYİ SERİ: ", .azerbaijani: "ƏN YAXŞI SERİYA: ", .russian: "ЛУЧШАЯ СЕРИЯ: "],
        "CONTINUE STREAK": [.english: "CONTINUE STREAK", .spanish: "CONTINUAR RACHA", .turkish: "SERİYE DEVAM", .azerbaijani: "SERİYAYA DAVAM", .russian: "ПРОДОЛЖИТЬ СЕРИЮ"],
        "RETURN TO MAIN MENU": [.english: "RETURN TO MAIN MENU", .spanish: "VOLVER AL MENÚ", .turkish: "ANA MENÜYE DÖN", .azerbaijani: "ANA MENYUYA QAYIT", .russian: "ВЕРНУТЬСЯ В ГЛАВНОЕ МЕНЮ"]
    ]
}
