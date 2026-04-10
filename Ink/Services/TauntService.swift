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
    
    // Sequential quote index per language (cycles 0-19)
    private var quoteIndex: [Language: Int] = [:]
    
    // MARK: - 20 Dry-Academic Taunts Per Language
    
    private let tauntsEN: [String] = [
        "Another incorrect letter. Truly remarkable.",
        "I've seen better guesses from first-year students.",
        "Your reasoning process fascinates me — not in a good way.",
        "That letter is not in the word. Neither is it in your vocabulary, apparently.",
        "One might assume you're familiar with the alphabet. One would be wrong.",
        "The word remains. Your dignity, less so.",
        "An intellectually curious choice. Incorrect, but curious.",
        "At this rate, the exam will end itself on your behalf.",
        "I'm not disappointed. I've long since stopped expecting anything.",
        "Were you guessing, or simply choosing letters aesthetically?",
        "That mistake has been documented. For posterity.",
        "Perhaps consider a different academic subject. Forestry, perhaps.",
        "Your confidence is admirable. Your accuracy is not.",
        "Each wrong answer is a gift to my conviction that education is failing.",
        "The correct letters are still there, waiting patiently.",
        "You are making an effort. I will give you that. Only that.",
        "This is what happens when students skip the reading.",
        "I have seen rocks make better guesses. Quiet ones.",
        "Your academic transcript must be a source of great entertainment.",
        "The gallows does not judge. I, however, do."
    ]
    
    private let tauntsTR: [String] = [
        "Yanlış harf. Gerçekten etkileyici.",
        "Birinci sınıf öğrencilerinden daha iyi tahminler gördüm.",
        "Düşünce süreciniz ilgimi çekiyor — iyi anlamda değil.",
        "Bu harf kelimede yok. Görünüşe göre kelime dağarcığınızda da.",
        "Alfabeye aşina olduğunuzu varsayardım. Yanılmışım.",
        "Kelime duruyor. Onurunuz, pek öyle değil.",
        "Entelektüel açıdan merak uyandıran bir tercih. Yanlış, ama merak uyandıran.",
        "Bu gidişle sınav sizin yerinize biter.",
        "Hayal kırıklığına uğramıyorum. Uzun zaman önce bir beklentim kalmadı.",
        "Harf mi seçiyordunuz, yoksa estetik olarak mı karar verdiniz?",
        "Bu hata kayıt altına alındı. Gelecek nesiller için.",
        "Belki farklı bir akademik alan düşünün. Ormancılık, mesela.",
        "Güveniniz takdire şayan. Doğruluğunuz, değil.",
        "Her yanlış cevap, eğitimin çöküşüne olan inancımı güçlendiriyor.",
        "Doğru harfler hâlâ orada, sabırla bekliyor.",
        "Bir çaba sarf ediyorsunuz. Bunu teslim ederim. Yalnızca bunu.",
        "Okumayı atlayan öğrencilerin başına bu gelir işte.",
        "Taşların daha iyi tahmin yaptığını gördüm. Sessiz taşların.",
        "Akademik transkriptiniz büyük bir eğlence kaynağı olmalı.",
        "Darağacı yargılamaz. Ben ise yargılarım."
    ]
    
    private let tauntsAZ: [String] = [
        "Yanlış hərf. Həqiqətən heyrətamizdir.",
        "Birinci kurs tələbələrindən daha yaxşı təxminlər görmüşəm.",
        "Düşüncə prosesiniz məni maraqlandırır — yaxşı mənada deyil.",
        "Bu hərf sözdə yoxdur. Görünür, lüğətinizdə də.",
        "Əlifbanı tanıdığınızı düşünərdim. Yanılmışam.",
        "Söz durur. Şərəfinizsə, o qədər də deyil.",
        "İntellektual cəhətdən maraqlı bir seçim. Yanlış, amma maraqlı.",
        "Bu sürətlə imtahan sizin əvəzinizə bitəcək.",
        "Məyus deyiləm. Çoxdan hər hansı bir gözləntim qalmayıb.",
        "Hərf seçirdiniz, yoxsa estetik baxımdan qərar verirdiniz?",
        "Bu xəta qeydə alındı. Gələcək nəsillər üçün.",
        "Bəlkə fərqli bir akademik sahə düşünün. Meşəçilik, məsələn.",
        "Güvəniniz təqdirəlayiqdir. Dəqiqliyiniz isə yox.",
        "Hər yanlış cavab, təhsilin uğursuzluğuna olan inamımı artırır.",
        "Düzgün hərflər hələ də orada, səbirlə gözləyir.",
        "Bir cəhd edirsiniz. Bunu qəbul edirəm. Yalnız bunu.",
        "Oxunuşu atlayan tələbələrin başına bu gəlir.",
        "Daşların daha yaxşı təxmin etdiyini görmüşəm. Sakit daşların.",
        "Akademik transkriptiniz böyük bir əyləncə mənbəyi olmalıdır.",
        "Dar ağacı mühakimə etmir. Mən isə edirəm."
    ]
    
    private let tauntsES: [String] = [
        "Otra letra incorrecta. Verdaderamente notable.",
        "He visto mejores respuestas de estudiantes de primer año.",
        "Su proceso de razonamiento me fascina — no de manera positiva.",
        "Esa letra no está en la palabra. Tampoco en su vocabulario, al parecer.",
        "Uno supondría que usted conoce el alfabeto. Uno estaría equivocado.",
        "La palabra permanece. Su dignidad, un poco menos.",
        "Una elección intelectualmente curiosa. Incorrecta, pero curiosa.",
        "A este ritmo, el examen terminará solo en su lugar.",
        "No estoy decepcionado. Hace tiempo que dejé de esperar algo.",
        "¿Estaba adivinando o simplemente eligiendo letras por su estética?",
        "Ese error ha quedado documentado. Para la posteridad.",
        "Quizás considere otra disciplina académica. La silvicultura, tal vez.",
        "Su confianza es admirable. Su precisión, no tanto.",
        "Cada respuesta incorrecta refuerza mi convicción de que la educación está fallando.",
        "Las letras correctas siguen ahí, esperando con paciencia.",
        "Está haciendo un esfuerzo. Le concedo eso. Sólo eso.",
        "Esto ocurre cuando los estudiantes se saltan las lecturas.",
        "He visto piedras hacer mejores suposiciones. Piedras silenciosas.",
        "Su expediente académico debe ser una fuente de gran entretenimiento.",
        "La horca no juzga. Yo, en cambio, sí."
    ]
    
    private let tauntsRU: [String] = [
        "Ещё одна неверная буква. Поистине замечательно.",
        "Я видел более удачные ответы от первокурсников.",
        "Ваш мыслительный процесс меня восхищает — и не в хорошем смысле.",
        "Этой буквы нет в слове. Судя по всему, её нет и в вашем словарном запасе.",
        "Можно было бы предположить, что вы знакомы с алфавитом. Можно было бы.",
        "Слово остаётся. Ваше достоинство — несколько меньше.",
        "Интеллектуально любопытный выбор. Неверный, но любопытный.",
        "При таком темпе экзамен завершится сам вместо вас.",
        "Я не разочарован. Я давно перестал чего-либо ожидать.",
        "Вы угадывали или просто выбирали буквы по эстетическим соображениям?",
        "Эта ошибка задокументирована. Для потомков.",
        "Возможно, стоит рассмотреть другую академическую дисциплину. Например, лесоводство.",
        "Ваша уверенность достойна восхищения. Ваша точность — нет.",
        "Каждый неверный ответ укрепляет мою убеждённость в несостоятельности образования.",
        "Правильные буквы всё ещё там, терпеливо ожидают.",
        "Вы прилагаете усилия. Это я признаю. Только это.",
        "Вот что бывает, когда студенты пропускают чтение.",
        "Я видел, как камни делают лучшие догадки. Тихие камни.",
        "Ваша академическая зачётная книжка должна быть источником большого развлечения.",
        "Виселица не судит. Я же — сужу."
    ]
    
    private init() {}
    
    // MARK: - Public Fetch Methods
    
    /// Sequential cycling taunt for wrong guesses
    public func fetchTaunt(language: Language, wrongCount: Int, difficulty: Difficulty) async -> String {
        let arr = tauntsArray(for: language)
        let idx = quoteIndex[language] ?? 0
        let taunt = arr[idx % arr.count]
        quoteIndex[language] = (idx + 1) % arr.count
        return taunt
    }
    
    /// Random taunt for defeat screen
    public func fetchDefeatQuote(language: Language) async -> String {
        return tauntsArray(for: language).randomElement()!
    }
    
    /// Reset cycling index when a new game starts
    public func resetIndex(for language: Language) {
        quoteIndex[language] = 0
    }
    
    // MARK: - Private
    private func tauntsArray(for language: Language) -> [String] {
        switch language {
        case .english:    return tauntsEN
        case .turkish:    return tauntsTR
        case .azerbaijani: return tauntsAZ
        case .spanish:    return tauntsES
        case .russian:    return tauntsRU
        }
    }
}
