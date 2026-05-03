# NewMe

Kişisel takip uygulaması: yemek, fitness, harcama logları + takvim + ayarlar.

Repo iki bölümden oluşur:

## `prototype/` — HTML/JSX tasarım prototipi

Claude Design'dan handoff bundle. React + Babel-in-browser; build yok.
Tarayıcıda `prototype/NEWME.html` aç → 5 ekran tek design canvas
üzerinde yan yana. Native uygulamanın görsel referansı.

## `NewMe/` — Native iOS uygulaması (SwiftUI)

iOS 17+. SwiftUI · SwiftData · CloudKit · Swift Charts. Locale tr_TR.

```
NewMe/
├── project.yml             xcodegen spec
├── NewMe.xcodeproj         (xcodegen ile üretilir)
└── NewMe/
    ├── NewMeApp.swift      ModelContainer + CloudKit init
    ├── Models/             6 @Model + SeedData
    ├── Theme/              renkler, fontlar, tarih/sayı formatlayıcılar
    └── Views/              Food/Fitness/Spending/Settings/Calendar
```

### İlk kurulum

```bash
brew install xcodegen           # bir kez
cd NewMe
xcodegen generate               # NewMe.xcodeproj'u taze üretir
open NewMe.xcodeproj
```

Xcode açılınca:
1. **Signing & Capabilities** sekmesi → **Team** dropdown'ında kendi
   Apple Developer hesabını seç. "Automatically manage signing" işaretli olsun.
2. iCloud capability hâlâ ekli görünmüyorsa → `+ Capability` → **iCloud** ekle,
   **CloudKit** kutusunu işaretle, container olarak `iCloud.com.hmtanrikulu.newme`
   seç. Yoksa `+` ile yeni container yarat (Xcode otomatik developer
   portalına kayıt eder).
3. Bundle identifier (`com.hmtanrikulu.newme`) sana ait değilse kendi
   ters domain'ine değiştir; container ID'sini de güncelle.

### iPhone'a yükle

1. iPhone'unu USB ile bağla, telefonu trust et.
2. Xcode toolbar'ında target olarak bağlı cihazını seç.
3. `⌘R` (Run).
4. İlk seferde iPhone'da: **Settings → General → VPN & Device Management** →
   geliştirici profilini trust et → uygulamayı aç.

### Sync nasıl çalışır

CloudKit private DB. Aynı Apple ID ile imzaladığın her cihazda aynı
veri görünür; ek kurulum yok. Telefonun internete bağlıyken arka planda
silent push ile senkron olur.

### v1 kapsamı

- Yemek logu: katalog + günlük adet + kalori/makro toplamları
- Fitness logu: hareket başına set/kg/tekrar tablosu
- Harcama logu: kategori + miktar + günlük limit
- Ayarlar: yiyecek/egzersiz katalog yönetimi + günlük hedefler
- Takvim: ay görünümü + seçili gün özeti + son 7 gün trend grafiği

Sonra eklenebilir (henüz yok): HealthKit, widget, bildirimler,
import/export, App Store dağıtımı.
