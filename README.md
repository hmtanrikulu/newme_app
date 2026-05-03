# NewMe

Kişisel takip uygulaması: yemek, fitness, harcama logları + takvim + ayarlar.

Repo iki bölüm içerir:

## `prototype/` — HTML/JSX tasarım prototipi

Claude Design'dan handoff bundle. React + Babel-in-browser; build adımı yok.
Tarayıcıda `prototype/NEWME.html` aç, design canvas üzerinde 5 ekranı
yan yana göreceksin. Native uygulamanın görsel referansı.

## `NewMe/` — Native iOS uygulaması (SwiftUI)

iOS 17+ hedefli SwiftUI + SwiftData + CloudKit + Swift Charts.

**Build**: Xcode'da `NewMe/NewMe.xcodeproj` aç, target olarak kendi
iPhone'unu seç, `Cmd+R`. İlk yüklemede telefon Settings > General >
VPN & Device Management > developer profile trust gerekebilir.

**Sync**: Apple ID'ye bağlı CloudKit private DB üzerinden otomatik;
ek kurulum yok.
