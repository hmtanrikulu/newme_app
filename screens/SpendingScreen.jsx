// ────────────────────────────────────────────────
// 3. HARCAMA LOGLARI
// ────────────────────────────────────────────────
const SPEND_CATS = [
  { id: 'food', label: 'Yemek', icon: 'fork' },
  { id: 'drink', label: 'İçecek', icon: 'cup' },
  { id: 'fun', label: 'Eğlence', icon: 'play' },
  { id: 'cloth', label: 'Kıyafet', icon: 'shirt' },
  { id: 'market', label: 'Market', icon: 'cart' },
  { id: 'other', label: 'Diğer', icon: 'dots' },
];

function CatIcon({ name, size = 22, color = '#fff' }) {
  const s = { width: size, height: size, fill: 'none', stroke: color, strokeWidth: 1.6, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'fork': return <svg {...s} viewBox="0 0 24 24"><path d="M7 3v8a2 2 0 002 2v8M7 3v6M11 3v6M16 3c-1 0-2 1-2 3v5h2v10"/></svg>;
    case 'cup': return <svg {...s} viewBox="0 0 24 24"><path d="M5 9h11v6a4 4 0 01-4 4H9a4 4 0 01-4-4V9zM16 11h2a2 2 0 010 4h-2M8 3c.5 1-.5 2 0 3M11 3c.5 1-.5 2 0 3"/></svg>;
    case 'play': return <svg {...s} viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M10 8.5v7l6-3.5-6-3.5z" fill={color}/></svg>;
    case 'shirt': return <svg {...s} viewBox="0 0 24 24"><path d="M9 4l-5 3 2 4h2v9h8v-9h2l2-4-5-3-3 2-3-2z"/></svg>;
    case 'cart': return <svg {...s} viewBox="0 0 24 24"><path d="M3 4h2l2.5 11h11l2-7H6.5"/><circle cx="9" cy="20" r="1.4"/><circle cx="17" cy="20" r="1.4"/></svg>;
    case 'dots': return <svg {...s} viewBox="0 0 24 24"><circle cx="6" cy="12" r="1.4" fill={color}/><circle cx="12" cy="12" r="1.4" fill={color}/><circle cx="18" cy="12" r="1.4" fill={color}/></svg>;
  }
}

function SpendingScreen({ onOpenCalendar, onOpenSettings, goal, entries, addEntry }) {
  const [cat, setCat] = React.useState('food');
  const [amount, setAmount] = React.useState('120');
  const todayTotal = entries.reduce((s, e) => s + e.amount, 0);
  const pct = Math.min(100, (todayTotal / goal) * 100);

  const press = (k) => {
    if (k === 'del') return setAmount(a => a.slice(0, -1) || '0');
    if (k === '.') {
      if (!amount.includes('.')) setAmount(a => a + '.');
      return;
    }
    setAmount(a => a === '0' ? k : a + k);
  };

  const submit = () => {
    const v = parseFloat(amount);
    if (!v) return;
    addEntry({ cat, amount: v, time: Date.now() });
    setAmount('0');
  };

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: '#000', color: '#fff', paddingTop: 54 }}>
      <div style={{ padding: '8px 22px 10px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
        <div>
          <div style={{ fontSize: 11, letterSpacing: 1.2, color: 'var(--text-3)', fontWeight: 600 }}>BUGÜN</div>
          <div style={{ fontSize: 26, fontWeight: 700, marginTop: 2, letterSpacing: -0.5 }}>Harcama</div>
        </div>
        <div style={{ display: 'flex', gap: 14, paddingBottom: 6 }}>
          <IconBtn onClick={onOpenCalendar}>
            <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
              <rect x="2.5" y="4.5" width="17" height="15" rx="3" stroke="#C9A961" strokeWidth="1.6"/>
              <path d="M2.5 9h17" stroke="#C9A961" strokeWidth="1.6"/>
            </svg>
          </IconBtn>
          <IconBtn onClick={onOpenSettings}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
              <path d="M12 15a3 3 0 100-6 3 3 0 000 6z" stroke="#C9A961" strokeWidth="1.6"/>
              <circle cx="12" cy="12" r="9" stroke="#C9A961" strokeWidth="1.6"/>
            </svg>
          </IconBtn>
        </div>
      </div>

      <div style={{ padding: '4px 22px 16px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 8 }}>
          <span style={{ fontSize: 11, letterSpacing: 1.2, color: 'var(--text-3)', fontWeight: 600 }}>BUGÜN</span>
          <span style={{ fontSize: 15, fontVariantNumeric: 'tabular-nums' }}>
            <span style={{ fontWeight: 600 }}>₺{todayTotal.toLocaleString('tr-TR')}</span>
            <span style={{ color: 'var(--text-3)' }}> / ₺{goal.toLocaleString('tr-TR')}</span>
          </span>
        </div>
        <div style={{ height: 4, background: 'rgba(255,255,255,0.08)', borderRadius: 2, overflow: 'hidden' }}>
          <div style={{ width: `${pct}%`, height: '100%', background: 'var(--gold)', borderRadius: 2 }} />
        </div>
      </div>

      <div style={{ padding: '0 16px 6px' }}>
        <div style={{ fontSize: 11, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700, padding: '0 6px 8px' }}>KATEGORİ</div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8 }}>
          {SPEND_CATS.map(c => {
            const sel = c.id === cat;
            return (
              <button key={c.id} onClick={() => setCat(c.id)} style={{
                background: sel ? 'var(--gold)' : 'var(--surface)',
                border: '1px solid ' + (sel ? 'transparent' : 'rgba(255,255,255,0.06)'),
                borderRadius: 14, padding: '14px 6px',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
                cursor: 'pointer', color: sel ? '#000' : '#fff',
              }}>
                <CatIcon name={c.icon} color={sel ? '#000' : '#fff'} />
                <span style={{ fontSize: 13, fontWeight: 600 }}>{c.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      <div style={{ padding: '14px 22px 6px' }}>
        <div style={{ fontSize: 11, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700, marginBottom: 4 }}>TUTAR</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, paddingBottom: 8, borderBottom: '1px solid rgba(201,169,97,0.5)' }}>
          <span style={{ fontSize: 30, color: 'var(--gold)', fontWeight: 300, lineHeight: 1 }}>₺</span>
          <span style={{ fontSize: 38, fontWeight: 500, fontVariantNumeric: 'tabular-nums', letterSpacing: -1 }}>{amount}</span>
          <span style={{ width: 2, height: 36, background: 'var(--gold)', display: 'inline-block' }} />
        </div>
      </div>

      {/* Keypad */}
      <div style={{ padding: '8px 16px 4px', display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 4 }}>
        {['1','2','3','4','5','6','7','8','9','.','0','del'].map(k => (
          <button key={k} onClick={() => press(k)} style={{
            height: 42, background: 'transparent', border: 'none', color: '#fff',
            fontSize: 24, fontWeight: 400, cursor: 'pointer',
          }}>
            {k === 'del' ? (
              <svg width="22" height="16" viewBox="0 0 22 16" style={{ display: 'inline-block', verticalAlign: 'middle' }}>
                <path d="M7 1h13a2 2 0 012 2v10a2 2 0 01-2 2H7L1 8l6-7z" stroke="#fff" strokeWidth="1.4" fill="none"/>
                <path d="M11 5l5 6M16 5l-5 6" stroke="#fff" strokeWidth="1.4" strokeLinecap="round"/>
              </svg>
            ) : k}
          </button>
        ))}
      </div>

      <div style={{ padding: '4px 16px 78px' }}>
        <button onClick={submit} style={{
          width: '100%', height: 50, borderRadius: 14, border: 'none',
          background: 'var(--gold)', color: '#000', fontSize: 15,
          fontWeight: 700, letterSpacing: 1.5, cursor: 'pointer',
        }}>EKLE</button>
      </div>
    </div>
  );
}

window.SpendingScreen = SpendingScreen;
window.SPEND_CATS = SPEND_CATS;
window.CatIcon = CatIcon;
