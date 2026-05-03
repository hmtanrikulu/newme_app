// ────────────────────────────────────────────────
// 5. TAKVİM EKRANI
// Ay görünümü + seçili gün özeti + son 7 gün grafiği
// ────────────────────────────────────────────────
function CalendarScreen({ onClose, dailyData }) {
  const today = new Date(2026, 4, 3); // 3 Mayıs 2026 Pazar
  const [selected, setSelected] = React.useState(today.toISOString().slice(0, 10));
  const [month, setMonth] = React.useState(new Date(2026, 4, 1));

  const monthName = month.toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' });
  const selDate = new Date(selected);
  const sel = dailyData[selected] || { kcal: 0, protein: 0, sets: {}, spend: {} };

  // Build calendar grid (Mon-first)
  const firstDay = new Date(month.getFullYear(), month.getMonth(), 1);
  let startOffset = (firstDay.getDay() + 6) % 7; // Mon=0
  const daysInMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
  const cells = [];
  // prev month
  const prevDays = new Date(month.getFullYear(), month.getMonth(), 0).getDate();
  for (let i = startOffset - 1; i >= 0; i--) cells.push({ d: prevDays - i, off: true });
  for (let i = 1; i <= daysInMonth; i++) cells.push({ d: i, off: false });
  while (cells.length % 7 !== 0) cells.push({ d: cells.length - startOffset - daysInMonth + 1, off: true });

  const dateKey = (d) => `${month.getFullYear()}-${String(month.getMonth() + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;

  // Last 7 days bars
  const last7 = [];
  for (let i = 6; i >= 0; i--) {
    const dt = new Date(today);
    dt.setDate(today.getDate() - i);
    const k = dt.toISOString().slice(0, 10);
    const data = dailyData[k] || { kcal: 0, sets: {}, spend: {} };
    last7.push({
      key: k, date: dt,
      kcal: data.kcal,
      sets: Object.values(data.sets || {}).reduce((s, a) => s + a.length, 0),
      spend: Object.values(data.spend || {}).reduce((s, v) => s + v, 0),
    });
  }
  const maxKcal = Math.max(2400, ...last7.map(d => d.kcal));
  const maxSpend = Math.max(1, ...last7.map(d => d.spend));

  const totalSpend = Object.entries(sel.spend || {}).reduce((s, [, v]) => s + v, 0);
  const setsByGroup = {};
  Object.entries(sel.sets || {}).forEach(([exId, sets]) => {
    const ex = (window._allExercises || []).find(x => x.id === exId);
    const g = ex?.group || 'Diğer';
    setsByGroup[g] = (setsByGroup[g] || 0) + sets.length;
  });

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: '#000', color: '#fff', paddingTop: 54 }}>
      {/* Nav */}
      <div style={{
        padding: '6px 16px 10px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <button onClick={onClose} style={{
          background: 'none', border: 'none', color: 'var(--gold)',
          fontSize: 16, cursor: 'pointer', padding: 0,
          display: 'flex', alignItems: 'center', gap: 4,
        }}>
          <svg width="11" height="18" viewBox="0 0 11 18"><path d="M9 1L1 9l8 8" stroke="#C9A961" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
          Bugün
        </button>
        <div style={{ fontSize: 17, fontWeight: 600, textTransform: 'capitalize' }}>{monthName}</div>
        <div style={{ display: 'flex', gap: 6 }}>
          <IconBtn onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() - 1, 1))}>
            <svg width="11" height="16" viewBox="0 0 11 16"><path d="M9 1L1 8l8 7" stroke="#C9A961" strokeWidth="1.8" fill="none" strokeLinecap="round"/></svg>
          </IconBtn>
          <IconBtn onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() + 1, 1))}>
            <svg width="11" height="16" viewBox="0 0 11 16"><path d="M2 1l8 7-8 7" stroke="#C9A961" strokeWidth="1.8" fill="none" strokeLinecap="round"/></svg>
          </IconBtn>
        </div>
      </div>

      {/* Weekday header */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', padding: '4px 12px 8px' }}>
        {['Pzt','Sal','Çar','Per','Cum','Cmt','Paz'].map(d => (
          <div key={d} style={{ textAlign: 'center', fontSize: 10, letterSpacing: 0.6, color: 'var(--text-3)', fontWeight: 600 }}>{d}</div>
        ))}
      </div>

      {/* Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', padding: '0 8px', rowGap: 4 }}>
        {cells.map((c, i) => {
          if (c.off) return <div key={i} style={{ height: 42 }} />;
          const k = dateKey(c.d);
          const isToday = k === today.toISOString().slice(0, 10);
          const isSel = k === selected;
          const data = dailyData[k];
          const has = data && (data.kcal > 0 || Object.keys(data.sets || {}).length > 0);
          return (
            <button key={i} onClick={() => setSelected(k)} style={{
              height: 42, background: 'transparent', border: 'none', cursor: 'pointer', padding: 0,
              display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 2,
            }}>
              <div style={{
                width: 30, height: 30, borderRadius: 15,
                background: isSel ? 'var(--gold)' : (isToday ? 'rgba(201,169,97,0.15)' : 'transparent'),
                color: isSel ? '#000' : (isToday ? 'var(--gold)' : '#fff'),
                fontSize: 14, fontWeight: isToday || isSel ? 600 : 400,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontVariantNumeric: 'tabular-nums',
              }}>{c.d}</div>
              <span style={{
                width: 4, height: 4, borderRadius: 2,
                background: has && !isSel ? 'var(--gold)' : 'transparent',
              }} />
            </button>
          );
        })}
      </div>

      {/* Selected day card */}
      <div style={{ padding: '14px 16px 6px' }}>
        <div style={{
          background: 'var(--surface)', borderRadius: 14,
          border: '1px solid rgba(255,255,255,0.06)',
          padding: '12px 14px',
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 10 }}>
            <span style={{ fontSize: 15, fontWeight: 600 }}>
              {selDate.toLocaleDateString('tr-TR', { day: 'numeric', month: 'long', weekday: 'long' })}
            </span>
            <span style={{ fontSize: 12, color: 'var(--text-3)' }}>
              {selected === today.toISOString().slice(0, 10) ? 'Bugün' : ''}
            </span>
          </div>
          <Row icon="fork" text={`${Math.round(sel.kcal)} kcal · ${Math.round(sel.protein)}g protein`} />
          <Row icon="dumbbell" text={
            Object.keys(setsByGroup).length
              ? Object.entries(setsByGroup).map(([g, n]) => `${g.toLowerCase()}: ${n} set`).join(' · ')
              : 'antrenman yok'
          } />
          <Row icon="lira" text={
            totalSpend
              ? Object.entries(sel.spend || {}).map(([cid, v]) => {
                  const c = SPEND_CATS.find(x => x.id === cid);
                  return `${c?.label || cid}: ₺${v}`;
                }).join(' · ')
              : 'harcama yok'
          } />
        </div>
      </div>

      {/* Last 7 days — Trend grafiği (kcal smooth çizgi + harcama bar overlay) */}
      <div style={{ flex: 1, padding: '10px 16px 30px', overflowY: 'auto' }}>
        {(() => {
          const Trend = window.Last7Alt_Trend;
          return Trend ? (
            <Trend
              days={last7}
              selected={selected}
              onSelect={setSelected}
              today={today.toISOString().slice(0, 10)}
              goalKcal={2400}
            />
          ) : null;
        })()}
      </div>
    </div>
  );
}

function Row({ icon, text }) {
  const ic = {
    fork: <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.6)" strokeWidth="1.6"><path d="M7 3v8a2 2 0 002 2v8M7 3v6M11 3v6M16 3c-1 0-2 1-2 3v5h2v10"/></svg>,
    dumbbell: <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.6)" strokeWidth="1.6"><path d="M3 9v6M5 7v10M9 6v12M15 6v12M19 7v10M21 9v6M9 12h6"/></svg>,
    lira: <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.6)" strokeWidth="1.6"><path d="M8 4v16M5 9l8-3M5 13l8-3M16 6c2 0 3 2 3 4-1 6-7 8-11 8"/></svg>,
  };
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '4px 0', fontSize: 13, color: 'var(--text-2)' }}>
      <span style={{ width: 16, display: 'flex' }}>{ic[icon]}</span>
      <span style={{ flex: 1 }}>{text}</span>
    </div>
  );
}

function Legend({ color, label }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
      <span style={{ width: 8, height: 8, borderRadius: 2, background: color }} />
      <span style={{ fontSize: 11, color: 'var(--text-3)' }}>{label}</span>
    </div>
  );
}

window.CalendarScreen = CalendarScreen;
