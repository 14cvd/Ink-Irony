//
//  L10n.swift
//  Ink
//
//  v2 interface strings in en, tr, az, ru, es. Placeholders are {0}, {1}, ...
//  Pending Victoria's review (tone and translation) before release.
//

import Foundation
import InkEngine

@MainActor
enum L10n {
    static var language: Language = .english

    static var locale: Locale { language.locale }

    static func t(_ key: String, _ args: Any...) -> String {
        var text = table[key]?[language] ?? table[key]?[.english] ?? key
        for (index, arg) in args.enumerated() {
            text = text.replacingOccurrences(of: "{\(index)}", with: "\(arg)")
        }
        return text
    }

    static func livesLeft(_ left: Int, of lives: Int) -> String { t("game.lives", left, lives) }

    static func semesterName(_ number: Int) -> String { t("semester.name.\(number)") }

    static func semesterTitle(_ number: Int) -> String { t("semester.title", number, semesterName(number)) }

    /// Before the release epoch the Daily has no number yet, so it is shown as a preview.
    static func dailyTitle(_ number: Int) -> String {
        number >= 1 ? t("daily.number", number) : t("daily.preview")
    }

    static func modeSubtitle(_ mode: PlayMode) -> String {
        switch mode {
        case .semester(let number, let word): t("mode.sub.semester", number, word, Rules.wordsPerSemester)
        case .free(let level, _): t("mode.sub.free", t("level.\(level.rawValue)"))
        case .daily(let number): dailyTitle(number)
        }
    }

    /// Spoiler-free share text: status, mistakes and the hit/miss squares, never the word.
    static func dailyShare(number: Int, won: Bool, mistakes: Int, pattern: [Bool]) -> String {
        let squares = pattern.map { $0 ? "🟩" : "🟥" }.joined()
        let status = t(won ? "daily.passed" : "daily.failed")
        return t("share.daily", dailyTitle(number), status, mistakes) + "\n" + squares + "\nhttps://apps.apple.com/app/id6760973464"
    }

    private typealias Row = [Language: String]

    private static func row(_ en: String, _ tr: String, _ az: String, _ ru: String, _ es: String) -> Row {
        [.english: en, .turkish: tr, .azerbaijani: az, .russian: ru, .spanish: es]
    }

    private static let table: [String: Row] = [
        // Tabs and common
        "tab.desk": row("Desk", "Masa", "Masa", "Парта", "Pupitre"),
        "tab.semesters": row("Semesters", "Dönemler", "Semestrlər", "Семестры", "Semestres"),
        "tab.stickers": row("Stickers", "Çıkartmalar", "Stikerlər", "Наклейки", "Pegatinas"),
        "tab.report": row("Report card", "Karne", "Qiymət vərəqi", "Табель", "Boletín"),
        "common.back": row("Back", "Geri", "Geri", "Назад", "Atrás"),
        "common.close": row("Close", "Kapat", "Bağla", "Закрыть", "Cerrar"),
        "common.cancel": row("Cancel", "Vazgeç", "Ləğv et", "Отмена", "Cancelar"),

        // Desk
        "desk.gpa": row("GPA {0}", "Ort. {0}", "ÜOB {0}", "Балл {0}", "Media {0}"),
        "desk.continue": row("Continue", "Devam et", "Davam et", "Продолжить", "Continuar"),
        "desk.playWord": row("Play word {0}", "{0}. kelimeyi oyna", "{0}-ci sözü oyna", "Слово {0}", "Jugar palabra {0}"),
        "desk.playFinal": row("Final exam", "Final sınavı", "Yekun imtahan", "Итоговый экзамен", "Examen final"),
        "desk.allPassed": row("Every semester passed. Free play awaits.", "Tüm dönemler geçildi. Serbest oyun seni bekliyor.", "Bütün semestrlər keçildi. Sərbəst oyun səni gözləyir.", "Все семестры сданы. Ждёт свободная игра.", "Todos los semestres aprobados. Te espera el juego libre."),
        "mode.free": row("Free play", "Serbest oyun", "Sərbəst oyun", "Свободная игра", "Juego libre"),
        "mode.free.sub": row("Topic and level", "Konu ve seviye", "Mövzu və səviyyə", "Тема и уровень", "Tema y nivel"),
        "mode.blitz": row("Blitz", "Blitz", "Blits", "Блиц", "Blitz"),
        "mode.duel": row("Duel", "Düello", "Duel", "Дуэль", "Duelo"),
        "mode.notebook": row("Word notebook", "Kelime defteri", "Söz dəftəri", "Словарик", "Cuaderno"),
        "mode.notebook.sub": row("{0} words solved", "{0} kelime çözüldü", "{0} söz tapılıb", "Отгадано слов: {0}", "{0} palabras resueltas"),
        "mode.soon": row("Coming soon", "Yakında", "Tezliklə", "Скоро", "Muy pronto"),
        "mode.sub.semester": row("Semester {0} · word {1}/{2}", "Dönem {0} · kelime {1}/{2}", "Semestr {0} · söz {1}/{2}", "Семестр {0} · слово {1}/{2}", "Semestre {0} · palabra {1}/{2}"),
        "mode.sub.free": row("Free play · {0}", "Serbest oyun · {0}", "Sərbəst oyun · {0}", "Свободная игра · {0}", "Juego libre · {0}"),

        // Levels
        "level.Easy": row("Easy", "Kolay", "Asan", "Легко", "Fácil"),
        "level.Medium": row("Medium", "Orta", "Orta", "Средне", "Medio"),
        "level.Hard": row("Hard", "Zor", "Çətin", "Сложно", "Difícil"),
        "level.Nightmare": row("Nightmare", "Kabus", "Kabus", "Кошмар", "Pesadilla"),

        // Semesters
        "semester.name.1": row("Kindergarten", "Anaokulu", "Uşaq bağçası", "Детский сад", "Preescolar"),
        "semester.name.2": row("Primary School", "İlkokul", "İbtidai sinif", "Начальная школа", "Primaria"),
        "semester.name.3": row("Science Year", "Fen Yılı", "Elm ili", "Год науки", "Año de ciencias"),
        "semester.name.4": row("High School", "Lise", "Orta məktəb", "Старшая школа", "Bachillerato"),
        "semester.name.5": row("University", "Üniversite", "Universitet", "Университет", "Universidad"),
        "semester.name.6": row("PhD", "Doktora", "Doktorantura", "Аспирантура", "Doctorado"),
        "semester.title": row("Semester {0}: {1}", "Dönem {0}: {1}", "Semestr {0}: {1}", "Семестр {0}: {1}", "Semestre {0}: {1}"),
        "semester.currentSub": row("10 words · {0} lives each", "10 kelime · her biri {0} can", "10 söz · hər birində {0} can", "10 слов · по {0} жизней", "10 palabras · {0} vidas cada una"),
        "semester.finalNote": row("Final exam: {0} lives, no power-ups.", "Final sınavı: {0} can, güçlendirme yok.", "Yekun imtahan: {0} can, köməkçi yoxdur.", "Итоговый экзамен: {0} жизни, без подсказок.", "Examen final: {0} vidas, sin ayudas."),
        "semester.final": row("FINAL", "FİNAL", "YEKUN", "ФИНАЛ", "FINAL"),
        "semester.passedSub": row("Passed · GPA {0}", "Geçti · Ort. {0}", "Keçdi · ÜOB {0}", "Сдано · балл {0}", "Aprobado · media {0}"),
        "semester.lockedSub": row("Pass {0} with GPA 2.0+", "{0} dönemini 2.0+ ortalamayla geç", "{0} semestrini 2.0+ ÜOB ilə keç", "Сдай «{0}» со средним 2.0+", "Aprueba {0} con media 2.0+"),

        // Daily
        "daily.title": row("Daily Exam", "Günlük Sınav", "Gündəlik imtahan", "Ежедневный экзамен", "Examen diario"),
        "daily.number": row("Daily Exam #{0}", "Günlük Sınav #{0}", "Gündəlik imtahan #{0}", "Экзамен дня №{0}", "Examen diario #{0}"),
        "daily.preview": row("Daily Exam", "Günlük Sınav", "Gündəlik imtahan", "Экзамен дня", "Examen diario"),
        "daily.sub": row("Same word for everyone today.", "Bugün herkese aynı kelime.", "Bu gün hamı üçün eyni söz.", "Сегодня одно слово для всех.", "Hoy, la misma palabra para todos."),
        "daily.doneShort": row("Done today. Back tomorrow.", "Bugünlük bitti. Yarın gel.", "Bu günlük bitdi. Sabah gəl.", "На сегодня всё. Ждём завтра.", "Hecho por hoy. Vuelve mañana."),
        "daily.rules": row("One word. Everyone. 6 lives, no power-ups.", "Tek kelime. Herkes. 6 can, güçlendirme yok.", "Bir söz. Hamı. 6 can, köməkçi yoxdur.", "Одно слово. Для всех. 6 жизней, без подсказок.", "Una palabra. Para todos. 6 vidas, sin ayudas."),
        "daily.start": row("Start today's exam", "Bugünkü sınava başla", "Bugünkü imtahana başla", "Начать экзамен дня", "Empezar el examen de hoy"),
        "daily.passed": row("PASSED", "GEÇTİ", "KEÇDİ", "СДАНО", "APROBADO"),
        "daily.failed": row("FAILED", "KALDI", "QALDI", "ПРОВАЛ", "SUSPENSO"),
        "daily.stats": row("{0} mistakes · {1} s", "{0} hata · {1} sn", "{0} səhv · {1} san", "ошибок: {0} · {1} с", "{0} errores · {1} s"),
        "daily.share": row("Share without spoilers", "Spoiler vermeden paylaş", "Sözü açmadan paylaş", "Поделиться без спойлеров", "Compartir sin spoilers"),
        "daily.thisWeek": row("This week", "Bu hafta", "Bu həftə", "Эта неделя", "Esta semana"),
        "daily.streak": row("{0}-day streak", "{0} günlük seri", "{0} günlük seriya", "Серия: {0} дн.", "Racha de {0} días"),
        "daily.streakShort": row("{0} days", "{0} gün", "{0} gün", "{0} дн.", "{0} días"),
        "daily.hallPass": row("Missed a day? One free hall pass per week keeps the streak alive.", "Bir gün mü kaçırdın? Haftada bir izin seriyi korur.", "Bir gün buraxdın? Həftədə bir icazə seriyanı qoruyur.", "Пропустил день? Одна справка в неделю сохраняет серию.", "¿Faltaste un día? Un justificante por semana salva la racha."),
        "daily.next": row("Next exam: {0}", "Sonraki sınav: {0}", "Növbəti imtahan: {0}", "Следующий экзамен: {0}", "Próximo examen: {0}"),
        "share.daily": row("Ink & Irony · {0} · {1} · {2} mistakes", "Ink & Irony · {0} · {1} · {2} hata", "Ink & Irony · {0} · {1} · {2} səhv", "Ink & Irony · {0} · {1} · ошибок: {2}", "Ink & Irony · {0} · {1} · {2} errores"),

        // Game
        "game.lives": row("{0} of {1} lives left", "{1} candan {0} kaldı", "{1} candan {0} qalıb", "Осталось {0} из {1}", "Quedan {0} de {1} vidas"),
        "game.score": row("Score", "Puan", "Xal", "Очки", "Puntos"),
        "game.combo": row("combo ×{0}", "kombo ×{0}", "kombo ×{0}", "комбо ×{0}", "combo ×{0}"),
        "game.hint": row("Hint: {0}", "İpucu: {0}", "İpucu: {0}", "Подсказка: {0}", "Pista: {0}"),
        "game.leave": row("Leave the exam", "Sınavdan çık", "İmtahandan çıx", "Покинуть экзамен", "Salir del examen"),
        "game.noPowerUps": row("No power-ups in this exam.", "Bu sınavda güçlendirme yok.", "Bu imtahanda köməkçi yoxdur.", "В этом экзамене без подсказок.", "Sin ayudas en este examen."),
        "power.eraser": row("Eraser", "Silgi", "Pozan", "Ластик", "Goma"),
        "power.reveal": row("Reveal", "Göster", "Göstər", "Открыть", "Revelar"),
        "power.hint": row("Hint", "İpucu", "İpucu", "Подсказка", "Pista"),
        "power.cost": row("{0} ink", "{0} mürekkep", "{0} mürəkkəb", "{0} чернил", "{0} tinta"),
        "power.needInk": row("{0} ink needed", "{0} mürekkep gerekli", "{0} mürəkkəb lazımdır", "Нужно {0} чернил", "Necesitas {0} de tinta"),
        "power.notAllowed": row("No power-ups here.", "Burada güçlendirme yok.", "Burada köməkçi yoxdur.", "Здесь без подсказок.", "Aquí no hay ayudas."),
        "over.escaped": row("ESCAPED!", "KAÇTI!", "QAÇDI!", "СБЕЖАЛ!", "¡ESCAPÓ!"),
        "over.detention": row("DETENTION.", "CEZA.", "CƏZA.", "НАКАЗАН.", "CASTIGADO."),
        "over.wonNote": row("Score {0} · {1} mistakes", "Puan {0} · {1} hata", "Xal {0} · {1} səhv", "Очки {0} · ошибок: {1}", "Puntos {0} · {1} errores"),
        "over.lostNote": row("The word was {0}.", "Kelime: {0}.", "Söz: {0}.", "Слово: {0}.", "La palabra era {0}."),
        "over.seeExam": row("See graded exam", "Notlu kâğıdı gör", "Qiymətli vərəqə bax", "Посмотреть оценку", "Ver el examen corregido"),

        // Result
        "result.exam": row("Exam · {0}", "Sınav · {0}", "İmtahan · {0}", "Экзамен · {0}", "Examen · {0}"),
        "result.name": row("Name: {0}", "Ad: {0}", "Ad: {0}", "Имя: {0}", "Nombre: {0}"),
        "result.student": row("Student", "Öğrenci", "Şagird", "Ученик", "Alumno"),
        "result.letters": row("Letters ({0})", "Harfler ({0})", "Hərflər ({0})", "Буквы ({0})", "Letras ({0})"),
        "result.bestCombo": row("Best combo ×{0}", "En iyi kombo ×{0}", "Ən yaxşı kombo ×{0}", "Лучшее комбо ×{0}", "Mejor combo ×{0}"),
        "result.lives": row("Lives left {0} × {1}", "Kalan can {0} × {1}", "Qalan can {0} × {1}", "Жизни {0} × {1}", "Vidas restantes {0} × {1}"),
        "result.powerUps": row("Power-ups ({0})", "Güçlendirmeler ({0})", "Köməkçilər ({0})", "Подсказки ({0})", "Ayudas ({0})"),
        "result.total": row("Total", "Toplam", "Cəmi", "Итого", "Total"),
        "result.next": row("Next word", "Sonraki kelime", "Növbəti söz", "Следующее слово", "Siguiente palabra"),
        "result.backToDesk": row("Back to the desk", "Masaya dön", "Masaya qayıt", "Вернуться за парту", "Volver al pupitre"),
        "result.share": row("Share result", "Sonucu paylaş", "Nəticəni paylaş", "Поделиться", "Compartir resultado"),
        "result.shareText": row("I got {0} on {1} in Ink & Irony ({2} points). Your turn.", "Ink & Irony'de {1} için {0} aldım ({2} puan). Sıra sende.", "Ink & Irony-də {1} sözü üçün {0} aldım ({2} xal). Növbə səndədir.", "Получил {0} за слово {1} в Ink & Irony ({2} очков). Твоя очередь.", "Saqué {0} con {1} en Ink & Irony ({2} puntos). Te toca."),
        "result.semesterPassed": row("Semester passed! {0} is open.", "Dönem geçildi! {0} açıldı.", "Semestr keçildi! {0} açıldı.", "Семестр сдан! Открыт: {0}.", "¡Semestre aprobado! {0} desbloqueado."),
        "result.allPassed": row("PhD complete. Even I am impressed.", "Doktora tamam. Ben bile etkilendim.", "Doktorantura bitdi. Hətta mən də təsirləndim.", "Аспирантура окончена. Даже я впечатлена.", "Doctorado completo. Hasta yo estoy impresionada."),
        "result.semesterFailed": row("GPA below 2.0. The semester starts again with new words.", "Ortalama 2.0'ın altında. Dönem yeni kelimelerle baştan.", "ÜOB 2.0-dan aşağıdır. Semestr yeni sözlərlə yenidən başlayır.", "Средний балл ниже 2.0. Семестр начнётся заново с новыми словами.", "Media por debajo de 2.0. El semestre empieza de nuevo con otras palabras."),

        // Report card and stickers
        "report.solved": row("Words solved", "Çözülen kelime", "Tapılan söz", "Отгадано", "Resueltas"),
        "report.rate": row("Pass rate", "Başarı", "Uğur", "Успех", "Aciertos"),
        "report.best": row("Best score", "En iyi puan", "Ən yaxşı xal", "Рекорд", "Mejor puntuación"),
        "report.streak": row("Daily streak", "Günlük seri", "Gündəlik seriya", "Серия дней", "Racha diaria"),
        "report.ink": row("Ink drops", "Mürekkep", "Mürəkkəb", "Чернила", "Tinta"),
        "report.played": row("Exams", "Sınavlar", "İmtahanlar", "Экзамены", "Exámenes"),
        "report.byLanguage": row("By language", "Dillere göre", "Dillər üzrə", "По языкам", "Por idioma"),
        "report.langLine": row("{0} solved · {1}", "{0} çözüldü · {1}", "{0} tapılıb · {1}", "{0} отгадано · {1}", "{0} resueltas · {1}"),
        "report.recent": row("Recent exams", "Son sınavlar", "Son imtahanlar", "Последние экзамены", "Exámenes recientes"),
        "report.empty": row("No exams yet. Ms. Irony is waiting.", "Henüz sınav yok. Bayan İroni bekliyor.", "Hələ imtahan yoxdur. Xanım İroni gözləyir.", "Экзаменов пока нет. Мисс Ирония ждёт.", "Aún no hay exámenes. La señorita Ironía espera."),
        "stickers.count": row("{0} of {1}", "{0} / {1}", "{0} / {1}", "{0} из {1}", "{0} de {1}"),
        "stickers.earned": row("Earned", "Kazanıldı", "Qazanılıb", "Получена", "Conseguida"),
        "stickers.locked": row("Locked", "Kilitli", "Bağlı", "Закрыта", "Bloqueada"),

        // Settings
        "settings.title": row("Settings", "Ayarlar", "Parametrlər", "Настройки", "Ajustes"),
        "settings.language": row("Language", "Dil", "Dil", "Язык", "Idioma"),
        "settings.languageNote": row("Words, keyboard and the teacher follow this language.", "Kelimeler, klavye ve öğretmen bu dili kullanır.", "Sözlər, klaviatura və müəllim bu dildədir.", "Слова, клавиатура и учитель — на этом языке.", "Las palabras, el teclado y la profesora usan este idioma."),
        "settings.teacher": row("Teacher", "Öğretmen", "Müəllim", "Учитель", "Profesora"),
        "settings.strict": row("Strict", "Sert", "Sərt", "Строгая", "Estricta"),
        "settings.gentle": row("Gentle", "Nazik", "Mülayim", "Мягкая", "Amable"),
        "settings.theme": row("Theme", "Tema", "Mövzu", "Тема", "Tema"),
        "settings.themeSystem": row("System", "Sistem", "Sistem", "Система", "Sistema"),
        "settings.themePaper": row("Paper", "Kâğıt", "Kağız", "Бумага", "Papel"),
        "settings.themeChalk": row("Chalkboard", "Kara tahta", "Lövhə", "Доска", "Pizarra"),
        "settings.feel": row("Sound and haptics", "Ses ve titreşim", "Səs və vibrasiya", "Звук и вибрация", "Sonido y vibración"),
        "settings.sound": row("Sound effects", "Ses efektleri", "Səs effektləri", "Звуковые эффекты", "Efectos de sonido"),
        "settings.haptics": row("Haptics", "Titreşim", "Vibrasiya", "Вибрация", "Vibración"),
        "settings.name": row("Your name on the exam", "Sınavdaki adın", "İmtahandakı adın", "Имя на экзамене", "Tu nombre en el examen"),
        "settings.reset": row("Reset all progress", "Tüm ilerlemeyi sıfırla", "Bütün irəliləyişi sıfırla", "Сбросить весь прогресс", "Borrar todo el progreso"),
        "settings.resetTitle": row("Reset everything?", "Her şey sıfırlansın mı?", "Hər şey sıfırlansın?", "Сбросить всё?", "¿Borrarlo todo?"),
        "settings.resetMessage": row("Exams, grades, ink and stickers will be erased. This cannot be undone.", "Sınavlar, notlar, mürekkep ve çıkartmalar silinecek. Geri alınamaz.", "İmtahanlar, qiymətlər, mürəkkəb və stikerlər silinəcək. Geri qaytarmaq olmaz.", "Экзамены, оценки, чернила и наклейки будут удалены. Это нельзя отменить.", "Se borrarán exámenes, notas, tinta y pegatinas. No se puede deshacer."),
        "settings.resetConfirm": row("Reset", "Sıfırla", "Sıfırla", "Сбросить", "Borrar"),

        // Free play and onboarding
        "free.topic": row("Topic", "Konu", "Mövzu", "Тема", "Tema"),
        "free.level": row("Level", "Seviye", "Səviyyə", "Уровень", "Nivel"),
        "free.lives": row("{0} lives", "{0} can", "{0} can", "жизней: {0}", "{0} vidas"),
        "free.start": row("Start", "Başla", "Başla", "Начать", "Empezar"),
        "onboarding.intro": row("I am Ms. Irony. I grade in red pen. Pick your language and try not to disappoint me.", "Ben Bayan İroni. Kırmızı kalemle not veririm. Dilini seç ve beni hayal kırıklığına uğratma.", "Mən Xanım İroniyəm. Qırmızı qələmlə qiymət yazıram. Dilini seç və məni məyus etməməyə çalış.", "Я мисс Ирония. Ставлю оценки красной ручкой. Выбери язык и постарайся меня не разочаровать.", "Soy la señorita Ironía. Califico con bolígrafo rojo. Elige tu idioma e intenta no decepcionarme."),
        "onboarding.firstDay": row("First day", "İlk gün", "İlk gün", "Первый день", "Primer día"),
        "onboarding.form": row("Enrollment form", "Kayıt formu", "Qeydiyyat forması", "Анкета ученика", "Hoja de matrícula"),
        "onboarding.nameLabel": row("Student name", "Öğrenci adı", "Şagirdin adı", "Имя ученика", "Nombre del alumno"),
        "onboarding.namePlaceholder": row("Your name", "Adın", "Adın", "Твоё имя", "Tu nombre"),
        "onboarding.langLabel": row("Language of instruction", "Eğitim dili", "Tədris dili", "Язык обучения", "Idioma de las clases"),
        "onboarding.toneLabel": row("Teacher's manner", "Öğretmenin tavrı", "Müəllimin rəftarı", "Характер учителя", "Carácter de la profesora"),
        "onboarding.strictSub": row("Dry sarcasm. Roasts your guesses.", "Kuru alay. Tahminlerine laf sokar.", "Quru sarkazm. Təxminlərinə söz atır.", "Сухой сарказм. Высмеивает догадки.", "Sarcasmo seco. Se burla de tus intentos."),
        "onboarding.gentleSub": row("Warm, kind, still witty.", "Sıcak, nazik, yine esprili.", "Mehriban, yumşaq, yenə hazırcavab.", "Тёплая, добрая, но с юмором.", "Cálida, amable y con gracia."),
        "onboarding.signature": row("Signature", "İmza", "İmza", "Подпись", "Firma"),
        "onboarding.date": row("Date", "Tarih", "Tarix", "Дата", "Fecha"),
        "onboarding.sign": row("Sign and enroll", "İmzala ve kaydol", "İmzala və qeydiyyatdan keç", "Подписать и поступить", "Firmar y matricularse"),
        "onboarding.enrolled": row("ENROLLED", "KAYITLI", "QƏBUL OLUNDU", "ЗАЧИСЛЕН", "MATRICULADO"),
        "onboarding.bubble.strict": row("Fill in the form. Neatly. I will know.", "Formu doldur. Düzgünce. Anlarım.", "Formanı doldur. Səliqəli. Mən bilərəm.", "Заполни анкету. Аккуратно. Я узнаю.", "Rellena la hoja. Con buena letra. Lo sabré."),
        "onboarding.bubble.gentle": row("Welcome! Fill in the form and we will begin together.", "Hoş geldin! Formu doldur, birlikte başlayalım.", "Xoş gəldin! Formanı doldur, birlikdə başlayaq.", "Добро пожаловать! Заполни анкету, и начнём вместе.", "¡Bienvenido! Rellena la hoja y empezamos juntos."),
        "onboarding.signed.strict": row("Enrolled, {0}. Do not make me regret it.", "Kaydın yapıldı, {0}. Pişman etme beni.", "Qəbul olundun, {0}. Məni peşman etmə.", "Зачислен, {0}. Не заставь пожалеть.", "Matriculado, {0}. No me hagas arrepentirme."),
        "onboarding.signed.noName": row("Enrolled. Nameless. Bold.", "Kaydın yapıldı. İsimsiz. Cesur.", "Qəbul olundun. Adsız. Cəsarətli.", "Зачислен. Без имени. Смело.", "Matriculado. Sin nombre. Valiente."),
        "onboarding.signed.gentle": row("Lovely handwriting. Off we go!", "Ne güzel el yazısı. Haydi başlayalım!", "Gözəl xətt. Gəl başlayaq!", "Прекрасный почерк. Вперёд!", "Qué letra tan bonita. ¡Vamos allá!"),
        "onboarding.start": row("Start Kindergarten", "Anaokuluna başla", "Uşaq bağçasından başla", "Начать с детского сада", "Empezar en preescolar"),

        // Accessibility
        "a11y.blank": row("blank", "boş", "boş", "пусто", "vacío"),
        "a11y.correct": row("{0}, correct", "{0}, doğru", "{0}, düzgün", "{0}, верно", "{0}, correcta"),
        "a11y.wrong": row("{0}, wrong", "{0}, yanlış", "{0}, səhv", "{0}, неверно", "{0}, incorrecta"),
        "a11y.grade": row("Grade {0}", "Not {0}", "Qiymət {0}", "Оценка {0}", "Nota {0}"),
        "a11y.ink": row("{0} ink drops", "{0} mürekkep damlası", "{0} mürəkkəb damcısı", "Чернил: {0}", "{0} gotas de tinta"),
        "a11y.nextWord": row("Next word", "Sonraki kelime", "Növbəti söz", "Следующее слово", "Siguiente palabra"),
        "a11y.notPlayed": row("Not played yet", "Henüz oynanmadı", "Hələ oynanmayıb", "Ещё не сыграно", "Aún sin jugar"),
        "a11y.pattern": row("{0} hits, {1} misses", "{0} isabet, {1} hata", "{0} düz, {1} səhv", "Верно: {0}, ошибок: {1}", "{0} aciertos, {1} fallos"),
        "a11y.word": row("Word: {0}", "Kelime: {0}", "Söz: {0}", "Слово: {0}", "Palabra: {0}"),
    ]
}
