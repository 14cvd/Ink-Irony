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
    
    private static let translations: [String: [Language: String]] = [
        // GameSetupView
        "NEW GAME": [.english: "NEW GAME", .spanish: "NUEVO JUEGO", .turkish: "YENİ OYUN", .azerbaijani: "YENİ OYUN", .russian: "НОВАЯ ИГРА"],
        "Select Language:": [.english: "Select Language:", .spanish: "Seleccionar Idioma:", .turkish: "Dil Seç:", .azerbaijani: "Dil Seç:", .russian: "Выберите Язык:"],
        "Select Difficulty:": [.english: "Select Difficulty:", .spanish: "Seleccionar Dificultad:", .turkish: "Zorluk Seç:", .azerbaijani: "Çətinlik Seç:", .russian: "Выберите Сложность:"],
        "START SKETCHING": [.english: "START SKETCHING", .spanish: "COMENZAR A DIBUJAR", .turkish: "ÇİZİME BAŞLA", .azerbaijani: "ÇƏKMƏYƏ BAŞLA", .russian: "НАЧАТЬ РИСОВАТЬ"],
        
        // OnboardingFlow
        "INK & IRONY": [.english: "INK & IRONY", .spanish: "TINTA E IRONÍA", .turkish: "MÜREKKEP & İRONİ", .azerbaijani: "MÜRƏKKƏB VƏ İRONİYA", .russian: "ЧЕРНИЛА И ИРОНИЯ"],
        "Welcome to the\nSavage Sketchbook.": [.english: "Welcome to the\nSavage Sketchbook.", .spanish: "Bienvenido al\nCuaderno Salvaje.", .turkish: "Vahşi Eskiz Defterine\nHoş Geldiniz.", .azerbaijani: "Vəhşi Eskiz Dəftərinə\nXoş Gəlmişsiniz.", .russian: "Добро пожаловать в\nДикий Скетчбук."],
        "The Teacher is waiting...\nDon't fail.": [.english: "The Teacher is waiting...\nDon't fail.", .spanish: "El Maestro te espera...\nNo falles.", .turkish: "Öğretmen bekliyor...\nBaşarısız olma.", .azerbaijani: "Müəllim gözləyir...\nUğursuz olma.", .russian: "Учитель ждет...\nНе подведи."],
        "NEXT": [.english: "NEXT", .spanish: "SIGUIENTE", .turkish: "İLERİ", .azerbaijani: "NÖVBƏTİ", .russian: "ДАЛЕЕ"],
        "ENTER": [.english: "ENTER", .spanish: "ENTRAR", .turkish: "GİRİŞ", .azerbaijani: "DAXİL OL", .russian: "ВОЙТИ"],
        
        // ResultScreen
        "NAME: ": [.english: "NAME: ", .spanish: "NOMBRE: ", .turkish: "İSİM: ", .azerbaijani: "AD: ", .russian: "ИМЯ: "],
        "Player 1": [.english: "Player 1", .spanish: "Jugador 1", .turkish: "Oyuncu 1", .azerbaijani: "Oyunçu 1", .russian: "Игрок 1"],
        "SUBJECT: ": [.english: "SUBJECT: ", .spanish: "ASUNTO: ", .turkish: "KONU: ", .azerbaijani: "MÖVZU: ", .russian: "ПРЕДМЕТ: "],
        "Execution": [.english: "Execution", .spanish: "Ejecución", .turkish: "İdam", .azerbaijani: "Edam", .russian: "Исполнение"],
        "DIFFICULTY: ": [.english: "DIFFICULTY: ", .spanish: "DIFICULTAD: ", .turkish: "ZORLUK: ", .azerbaijani: "ÇƏTİNLİK: ", .russian: "СЛОЖНОСТЬ: "],
        "VOCABULARY MASTERED:": [.english: "VOCABULARY MASTERED:", .spanish: "VOCABULARIO DOMINADO:", .turkish: "KELİME ÖĞRENİLDİ:", .azerbaijani: "SÖZ ÖYRƏNİLDİ:", .russian: "СЛОВО ОСВОЕНО:"],
        "FATAL ERROR. CORRECT WORD:": [.english: "FATAL ERROR. CORRECT WORD:", .spanish: "ERROR FATAL. PALABRA CORRECTA:", .turkish: "ÖLÜMCÜL HATA. DOĞRU KELİME:", .azerbaijani: "ÖLÜMCÜL XƏTA. DOĞRU SÖZ:", .russian: "ФАТАЛЬНАЯ ОШИБКА. ПРАВИЛЬНОЕ СЛОВО:"],
        "CURRENT STREAK: ": [.english: "CURRENT STREAK: ", .spanish: "RACHA ACTUAL: ", .turkish: "MEVCUT SERİ: ", .azerbaijani: "CARI SERİYA: ", .russian: "ТЕКУЩАЯ СЕРИЯ: "],
        "HIGH SCORE STREAK: ": [.english: "HIGH SCORE STREAK: ", .spanish: "MEJOR RACHA: ", .turkish: "EN İYİ SERİ: ", .azerbaijani: "ƏN YAXŞI SERİYA: ", .russian: "ЛУЧШАЯ СЕРИЯ: "],
        "CONTINUE STREAK": [.english: "CONTINUE STREAK", .spanish: "CONTINUAR RACHA", .turkish: "SERİYE DEVAM", .azerbaijani: "SERİYAYA DAVAM", .russian: "ПРОДОЛЖИТЬ СЕРИЮ"],
        "TRY AGAIN": [.english: "TRY AGAIN", .spanish: "INTENTAR DE NUEVO", .turkish: "TEKRAR DENE", .azerbaijani: "YENİDƏN CƏHD ET", .russian: "ПОПРОБОВАТЬ СНОВА"],
        "RETURN TO MAIN MENU": [.english: "RETURN TO MAIN MENU", .spanish: "VOLVER AL MENÚ", .turkish: "ANA MENÜYE DÖN", .azerbaijani: "ANA MENYUYA QAYIT", .russian: "ВЕРНУТЬСЯ В ГЛАВНОЕ МЕНЮ"],
        
        // MainMenu / ContentView
        "START EXAM": [.english: "START EXAM", .spanish: "INICIAR EXAMEN", .turkish: "SINAVA BAŞLA", .azerbaijani: "İMTAHANA BAŞLA", .russian: "НАЧАТЬ ЭКЗАМЕН"],
        "RECORDS": [.english: "RECORDS", .spanish: "RÉCORDS", .turkish: "REKORLAR", .azerbaijani: "REKORLAR", .russian: "РЕКОРДЫ"],
        
        // Difficulties
        "EASY": [.english: "EASY", .spanish: "FÁCIL", .turkish: "KOLAY", .azerbaijani: "ASAN", .russian: "ЛЕГКО"],
        "MEDIUM": [.english: "MEDIUM", .spanish: "MEDIO", .turkish: "ORTA", .azerbaijani: "ORTA", .russian: "СРЕДНЕ"],
        "HARD": [.english: "HARD", .spanish: "DIFÍCIL", .turkish: "ZOR", .azerbaijani: "ÇƏTİN", .russian: "СЛОЖНО"],
        "NIGHTMARE": [.english: "NIGHTMARE", .spanish: "PESADILLA", .turkish: "KABUS", .azerbaijani: "KABUS", .russian: "КОШМАР"],
        
        // LeaderboardView
        "LEADERBOARD": [.english: "LEADERBOARD", .spanish: "CLASIFICACIÓN", .turkish: "LİDERLİK TABLOSU", .azerbaijani: "LİDERLƏR CƏDVƏLİ", .russian: "ТАБЛИЦА ЛИДЕРОВ"],
        "No victorious records found\nfor this language.": [.english: "No victorious records found\nfor this language.", .spanish: "No se encontraron victorias\npara este idioma.", .turkish: "Bu dil için zafer\nkaydı bulunamadı.", .azerbaijani: "Bu dil üçün qələbə\nrekordu tapılmadı.", .russian: "Для этого языка\nнет победных рекордов."],
        
        // GameView
        "LIVES: ": [.english: "LIVES: ", .spanish: "VIDAS: ", .turkish: "CAN: ", .azerbaijani: "CAN: ", .russian: "ЖИЗНИ: "],
        "Guess a letter...": [.english: "Guess a letter...", .spanish: "Adivina una letra...", .turkish: "Bir harf tahmin et...", .azerbaijani: "Bir hərf tap...", .russian: "Угадай букву..."],
        "YOU SURVIVED.": [.english: "YOU SURVIVED.", .spanish: "SOBREVIVISTE.", .turkish: "HAYATTA KALDIN.", .azerbaijani: "SAĞ QALDIN.", .russian: "ТЫ ВЫЖИЛ."],
        "GAME OVER.": [.english: "GAME OVER.", .spanish: "FIN DEL JUEGO.", .turkish: "OYUN BİTTİ.", .azerbaijani: "OYUN BİTDİ.", .russian: "ИГРА ОКОНЧЕНА."]
    ]
}
