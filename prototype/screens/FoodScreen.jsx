// ────────────────────────────────────────────────
// 1. YEMEK LOGLARI (giriş sayfası)
// — alt kısımdaki "KALAN" kaldırıldı
// — makro kutuları (PROTEİN, KARB, YAĞ) çerçeveli ve daha görünür
// ────────────────────────────────────────────────
function FoodScreen({ onOpenCalendar, onOpenSettings, foods, goals, qty, setQty, dateLabel }) {
  const total = foods.reduce((s, f) => s + (qty[f.id] || 0) * f.kcal, 0);
  const protein = foods.reduce((s, f) => s + (qty[f.id] || 0) * (f.p || 0), 0);
  const carbs = foods.reduce((s, f) => s + (qty[f.id] || 0) * (f.c || 0), 0);
  const fat = foods.reduce((s, f) => s + (qty[f.id] || 0) * (f.f || 0), 0);
  const pct = Math.min(100, (total / goals.kcal) * 100);

  return (
    <div style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      background: '#000', color: '#fff', paddingTop: 54,
    }}>
      {/* HEADER */}
      <div style={{ padding: '8px 22px 10px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
        <div>
          <div style={{ fontSize: 11, letterSpacing: 1.2, color: 'var(--text-3)', fontWeight: 600 }}>BUGÜN</div>
          <div style={{ fontSize: 26, fontWeight: 700, marginTop: 2, letterSpacing: -0.5 }}>{dateLabel}</div>
        </div>
        <div style={{ display: 'flex', gap: 14, paddingBottom: 6 }}>
          <IconBtn onClick={onOpenCalendar}>
            <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
              <rect x="2.5" y="4.5" width="17" height="15" rx="3" stroke="#C9A961" strokeWidth="1.6"/>
              <path d="M2.5 9h17" stroke="#C9A961" strokeWidth="1.6"/>
              <path d="M7 2.5v4M15 2.5v4" stroke="#C9A961" strokeWidth="1.6" strokeLinecap="round"/>
            </svg>
          </IconBtn>
          <IconBtn onClick={onOpenSettings}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M12 15a3 3 0 100-6 3 3 0 000 6z" stroke="#C9A961" strokeWidth="1.6"/>
              <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 01-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 11-4 0v-.09a1.65 1.65 0 00-1-1.51 1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 110-4h.09a1.65 1.65 0 001.51-1 1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 114 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 112.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 110 4h-.09a1.65 1.65 0 00-1.51 1z" stroke="#C9A961" strokeWidth="1.5"/>
            </svg>
          </IconBtn>
        </div>
      </div>

      {/* KALORİ BAR */}
      <div style={{ padding: '8px 22px 14px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 8 }}>
          <span style={{ fontSize: 11, letterSpacing: 1.2, color: 'var(--text-3)', fontWeight: 600 }}>KALORİ</span>
          <span style={{ fontSize: 15, color: 'var(--text-2)', fontVariantNumeric: 'tabular-nums' }}>
            <span style={{ color: '#fff', fontWeight: 600 }}>{Math.round(total)}</span>
            <span style={{ color: 'var(--text-3)' }}> / {goals.kcal.toLocaleString()}</span>
          </span>
        </div>
        <div style={{ height: 4, background: 'rgba(255,255,255,0.08)', borderRadius: 2, overflow: 'hidden' }}>
          <div style={{ width: `${pct}%`, height: '100%', background: 'var(--gold)', borderRadius: 2, transition: 'width .3s' }} />
        </div>
      </div>

      {/* FOOD LIST */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px' }}>
        <div style={{
          display: 'flex', justifyContent: 'space-between',
          fontSize: 11, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 600,
          padding: '4px 8px 10px',
        }}>
          <span>YİYECEK</span><span>ADET</span>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {foods.map(f => (
            <FoodRow key={f.id} food={f} qty={qty[f.id] || 0}
              onInc={() => setQty({ ...qty, [f.id]: (qty[f.id] || 0) + 1 })}
              onDec={() => setQty({ ...qty, [f.id]: Math.max(0, (qty[f.id] || 0) - 1) })}
            />
          ))}
        </div>
        <div style={{ height: 16 }} />
      </div>

      {/* BOTTOM SUMMARY — revize edilmiş */}
      <div style={{
        padding: '14px 16px 78px',
        background: 'linear-gradient(180deg, rgba(0,0,0,0) 0%, #000 24%)',
        borderTop: '1px solid rgba(255,255,255,0.06)',
      }}>
        {/* TOPLAM */}
        <div style={{ padding: '0 6px 10px' }}>
          <div style={{ fontSize: 10, letterSpacing: 1.4, color: 'var(--text-3)', fontWeight: 700 }}>TOPLAM</div>
          <div style={{ fontSize: 30, fontWeight: 700, marginTop: 2, letterSpacing: -0.6, fontVariantNumeric: 'tabular-nums' }}>
            {Math.round(total)} <span style={{ fontSize: 18, color: 'var(--text-2)', fontWeight: 500 }}>kcal</span>
          </div>
        </div>
        {/* MAKRO KARTLARI — çerçeveli, daha görünür */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8 }}>
          <MacroCard label="PROTEİN" current={protein} goal={goals.p} unit="g" tone="#FF6B6B" />
          <MacroCard label="KARB." current={carbs} goal={goals.c} unit="g" tone="#5AB7FF" />
          <MacroCard label="YAĞ" current={fat} goal={goals.f} unit="g" tone="#FFC857" />
        </div>
      </div>
    </div>
  );
}

function FoodRow({ food, qty, onInc, onDec }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      background: 'var(--surface)', borderRadius: 14, padding: '12px 14px',
    }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 16, fontWeight: 500, lineHeight: 1.15 }}>{food.name}</div>
        <div style={{ fontSize: 12, color: 'var(--text-2)', marginTop: 3, fontVariantNumeric: 'tabular-nums' }}>
          {qty * food.serving} {food.unit} · {Math.round(qty * food.kcal)} kcal
        </div>
      </div>
      <button onClick={onDec} style={qtyBtn(false)}>
        <svg width="14" height="2" viewBox="0 0 14 2"><rect width="14" height="2" rx="1" fill="rgba(255,255,255,0.6)"/></svg>
      </button>
      <div style={{ width: 26, textAlign: 'center', fontSize: 17, fontWeight: 500, fontVariantNumeric: 'tabular-nums' }}>{qty}</div>
      <button onClick={onInc} style={qtyBtn(true)}>
        <svg width="14" height="14" viewBox="0 0 14 14"><path d="M7 1v12M1 7h12" stroke="rgba(255,255,255,0.85)" strokeWidth="1.8" strokeLinecap="round"/></svg>
      </button>
    </div>
  );
}

function MacroCard({ label, current, goal, unit, tone }) {
  const pct = goal > 0 ? Math.min(100, (current / goal) * 100) : 0;
  return (
    <div style={{
      background: 'var(--surface)',
      border: '1px solid rgba(255,255,255,0.08)',
      borderRadius: 14, padding: '10px 10px',
      display: 'flex', flexDirection: 'column', gap: 6,
      minWidth: 0,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 5, minWidth: 0 }}>
        <span style={{ width: 6, height: 6, borderRadius: 3, background: tone, flexShrink: 0 }} />
        <span style={{ fontSize: 9.5, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'clip' }}>{label}</span>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 3, minWidth: 0, flexWrap: 'nowrap' }}>
        <span style={{ fontSize: 18, fontWeight: 600, fontVariantNumeric: 'tabular-nums', letterSpacing: -0.3, lineHeight: 1, color: '#fff' }}>
          {Math.round(current)}
        </span>
        <span style={{ fontSize: 11, color: 'var(--text-3)', fontWeight: 500, fontVariantNumeric: 'tabular-nums', whiteSpace: 'nowrap' }}>
          /{goal}{unit}
        </span>
      </div>
      <div style={{ height: 3, background: 'rgba(255,255,255,0.07)', borderRadius: 2, overflow: 'hidden' }}>
        <div style={{ width: `${pct}%`, height: '100%', background: tone, borderRadius: 2 }} />
      </div>
    </div>
  );
}

function IconBtn({ children, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: 34, height: 34, borderRadius: 17,
      background: 'transparent', border: 'none', padding: 0, cursor: 'pointer',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>{children}</button>
  );
}

const qtyBtn = (filled) => ({
  width: 30, height: 30, borderRadius: 15,
  background: filled ? 'rgba(201,169,97,0.18)' : 'rgba(255,255,255,0.06)',
  border: filled ? '1px solid rgba(201,169,97,0.4)' : '1px solid rgba(255,255,255,0.08)',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  cursor: 'pointer', padding: 0,
});

window.FoodScreen = FoodScreen;
window.IconBtn = IconBtn;
