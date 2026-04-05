//
//  TauntService.swift
//  Ink
//
//  Created by Cavid Abbasaliyev on 21.03.26.
//

import Foundation

// MARK: - Taunt Service
public actor TauntService {
    public static let shared = TauntService()
    
    // Offline Fallback Arrays - 25 taunts per language
    private let fallbackTauntsEN: [String] = [
        "Are you even trying?", "My grandmother guesses better.", "That was pathetic.",
        "Drawing the noose tighter...", "Did you skip school?", "A step closer to the gallows.",
        "Is that your best?", "You're embarrassing yourself.", "Truly abysmal.", "Hopeless.",
        "I expected nothing, yet I'm disappointed.", "Just give up already.",
        "Words are clearly not your strong suit.", "Another mistake, another nail in the coffin.",
        "Are your eyes closed?", "Even a toddler could do this.", "The hangman is laughing at you.",
        "Is this a joke to you?", "I'm running out of ink for your mistakes.", "Try using your brain next time.",
        "A monkey hitting a keyboard would do better.", "Disgraceful.", "You're writing your own doom.",
        "My patience is wearing thinner than this paper.", "Did you even look at the word?",
        "Another masterpiece of failure.", "I'd facepalm, but I'm just a drawing.",
        "This is getting painful to watch.", "Can we just skip to the end?",
        "You're making this too easy for me.", "Astonishingly bad.", "Are you trying to lose?"
    ]
    
    private let fallbackTauntsES: [String] = [
        "¿Siquiera lo intentas?", "Mi abuela adivina mejor.", "Eso fue patético.",
        "Apretando el nudo...", "¿Faltaste a la escuela?", "Un paso hacia la soga.",
        "¿Es lo mejor que tienes?", "Estás dando vergüenza.", "Verdaderamente abismal.", "Sin esperanza.",
        "No esperaba nada y aún así me decepcionas.", "Solo ríndete de una vez.",
        "Claramente las palabras no son lo tuyo.", "Otro error, otro clavo en el ataúd.",
        "¿Acaso tienes los ojos cerrados?", "Incluso un niño pequeño podría hacerlo.",
        "El verdugo se ríe de ti.", "¿A eso le llamas adivinar?", "Qué trágica muestra de ignorancia.",
        "¿Te parece una broma?", "Me estoy quedando sin tinta para tus errores.",
        "Intenta usar tu cerebro la próxima vez.", "Un mono golpeando un teclado lo haría mejor.",
        "Vergonzoso.", "Estás escribiendo tu propia perdición."
    ]
    
    private let fallbackTauntsRU: [String] = [
        "Ты вообще стараешься?", "Моя бабушка лучше угадывает.", "Это было жалко.",
        "Петля затягивается...", "Ты прогуливал школу?", "Шаг к виселице.",
        "Это твой максимум?", "Ты позоришься.", "Просто ужасно.", "Безнадежно.",
        "Я ничего не ждал, но всё равно разочарован.", "Просто сдавайся уже.",
        "Слова явно не твой конек.", "Еще одна ошибка, еще один гвоздь в крышку гроба.",
        "Ты угадываешь с закрытыми глазами?", "Даже ребенок справился бы.",
        "Палач смеется над тобой.", "И это ты называешь догадкой?",
        "Какое трагическое проявление невежества.", "Для тебя это шутка?",
        "У меня заканчиваются чернила на твои ошибки.", "В следующий раз попробуй использовать мозг.",
        "Обезьяна, бьющая по клавиатуре, справилась бы лучше.", "Позор.", "Ты сам пишешь свой приговор."
    ]
    
    private let fallbackTauntsTR: [String] = [
        "Hiç çabalıyor musun?", "Ninem bile daha iyi bilir.", "Bu çok acınasıydı.",
        "İlmek daralıyor...", "Okulu mu astın?", "Darağacına bir adım daha.",
        "En iyisi bu mu?", "Kendini utandırıyorsun.", "Gerçekten berbat.", "Umutsuz vaka.",
        "Hiçbir şey beklemiyordum, yine de hayal kırıklığına uğradım.", "Pes et gitsin.",
        "Kelimeler senin güçlü yanın değil.", "Bir hata daha, tabuta bir çivi daha.",
        "Gözlerin kapalı mı tahmin ediyorsun?", "Küçük bir çocuk bile bunu yapabilirdi.",
        "Cellat sana gülüyor.", "Buna tahmin mi diyorsun?", "Ne kadar trajik bir cehalet gösterisi.",
        "Bu senin için bir şaka mı?", "Hatalarını çizmekten mürekkebim bitti.",
        "Bir dahaki sefere beynini kullanmayı dene.", "Klavyeye rastgele basan bir maymun daha iyi yapardı.",
        "Rezalet.", "Kendi sonunu hazırlıyorsun.", "Sabrım bu kağıttan daha ince hale geliyor.",
        "Kelimeye hiç baktın mı?", "Başarısızlığın bir başka şaheseri.",
        "Bunu izlemek acı vermeye başladı.", "Doğrudan sona geçebilir miyiz?",
        "İşimi çok kolaylaştırıyorsun.", "Şaşırtıcı derecede kötü.", "Özellikle mi kaybetmeye çalışıyorsun?"
    ]
    
    private let fallbackTauntsAZ: [String] = [
        "Heç cəhd edirsən?", "Nənəm daha yaxşı tapır.", "Bu çox acınacaqlı idi.",
        "İlmək daralır...", "Məktəbdən qaçmısan?", "Dar ağacına bir addım.",
        "Ən yaxşın budur?", "Özünü biabır edirsən.", "Həqiqətən bərbat.", "Ümidsiz vəziyyət.",
        "Hec nə gözləmirdim, amma yenə də məyus oldum.", "Sadəcə təslim ol.",
        "Sözlər sənin güclü tərəfin deyil.", "Daha bir səhv, tabuta bir mismar da.",
        "Gözlərin bağla tapırsan?", "Bunu bir uşaq da edə bilərdi.",
        "Cəllad sənə gülür.", "Buna təxmin deyirsən?", "Necə də faciəvi bir cəhalət nümayişidir.",
        "Bu sənin üçün zarafatdır?", "Səhvlərini yazmaqdan mürəkkəbim bitdi.",
        "Növbəti dəfə beynini işlətməyə çalış.", "Klaviatura düymələrinə sıxan bir meymun daha yaxşı edərdi.",
        "Rüsvayçılıq.", "Öz sonunu hazırlayırsan.", "Səbrim bu kağızdan daha nazik olur.",
        "Sözə heç baxdınmı?", "Uğursuzluğun başqa bir şah əsəri.",
        "Buna baxmaq artıq əziyyət verir.", "Birbaşa sona keçə bilərikmi?",
        "İşimi çox asanlaşdırırsan.", "Təəccüblü dərəcədə pis.", "Qəsdən uduzmağa çalışırsan?"
    ]
    
    private init() {}
    
    // MARK: - Public Fetch Method
    public func fetchTaunt(language: Language, wrongCount: Int, difficulty: Difficulty) async -> String {
        switch language {
        case .english: return fallbackTauntsEN.randomElement()!
        case .spanish: return fallbackTauntsES.randomElement()!
        case .russian: return fallbackTauntsRU.randomElement()!
        case .turkish: return fallbackTauntsTR.randomElement()!
        case .azerbaijani: return fallbackTauntsAZ.randomElement()!
        }
    }
}
