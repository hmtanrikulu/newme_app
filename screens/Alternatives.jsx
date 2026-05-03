// ────────────────────────────────────────────────
// ALTERNATIFLER — 3 öğenin farklı tasarımları
// ────────────────────────────────────────────────

// =============================================
// MAKRO KARTLARI alternatifleri
// =============================================

// ALT A — Daire/halka göstergeli
function MacroAlt_Ring({ label, current, goal, unit, tone }) {
  const pct = goal > 0 ? Math.min(1, current / goal) : 0;
  const r = 18, c = 2 * Math.PI * r;
  return (
    <div style={{
      background: 'var(--surface)',
      border: '1px solid rgba(255,255,255,0.08)',
      borderRadius: 14, padding: '10px 8px 12px',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
      minWidth: 0,
    }}>
      <div style={{ position: 'relative', width: 46, height: 46 }}>
        <svg width="46" height="46" viewBox="0 0 46 46" style={{ transform: 'rotate(-90deg)' }}>
          <circle cx="23" cy="23" r={r} fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth="4"/>
          <circle cx="23" cy="23" r={r} fill="none" stroke={tone} strokeWidth="4"
            strokeDasharray={c} strokeDashoffset={c * (1 - pct)} strokeLinecap="round"/>
        </svg>
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 11, fontWeight: 700, fontVariantNumeric: 'tabular-nums',
        }}>{Math.round(pct * 100)}%</div>
      </div>
      <div style={{ textAlign: 'center', minWidth: 0 }}>
        <div style={{ fontSize: 9, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700 }}>{label}</div>
        <div style={{ fontSize: 12, fontWeight: 600, marginTop: 2, fontVariantNumeric: 'tabular-nums' }}>
          {Math.round(current)}<span style={{ color: 'var(--text-3)', fontWeight: 400 }}>/{goal}{unit}</span>
        </div>
      </div>
    </div>
  );
}

// ALT B — Stacked bar (tek kart, 3 makro birlikte)
function MacroAlt_Stacked({ macros }) {
  const total = macros.reduce((s, m) => s + m.current, 0) || 1;
  return (
    <div style={{
      background: 'var(--surface)',
      border: '1px solid rgba(255,255,255,0.08)',
      borderRadius: 14, padding: '12px 14px',
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 10 }}>
        <span style={{ fontSize: 10, letterSpacing: 1.2, color: 'var(--text-3)', fontWeight: 700 }}>MAKRO DAĞILIMI</span>
        <span style={{ fontSize: 11, color: 'var(--text-2)', fontVariantNumeric: 'tabular-nums' }}>
          {Math.round(total)}g toplam
        </span>
      </div>
      <div style={{ display: 'flex', height: 8, borderRadius: 4, overflow: 'hidden', background: 'rgba(255,255,255,0.05)' }}>
        {macros.map(m => (
          <div key={m.label} style={{
            flex: m.current, background: m.tone, transition: 'flex .3s',
          }} />
        ))}
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 12, gap: 8 }}>
        {macros.map(m => {
          const pct = m.goal > 0 ? Math.round((m.current / m.goal) * 100) : 0;
          return (
            <div key={m.label} style={{ flex: 1, textAlign: 'center' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4 }}>
                <span style={{ width: 6, height: 6, borderRadius: 3, background: m.tone }} />
                <span style={{ fontSize: 9.5, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700 }}>{m.label}</span>
              </div>
              <div style={{ fontSize: 14, fontWeight: 600, marginTop: 4, fontVariantNumeric: 'tabular-nums' }}>
                {Math.round(m.current)}<span style={{ color: 'var(--text-3)' }}>g</span>
              </div>
              <div style={{ fontSize: 10, color: pct >= 100 ? 'var(--green)' : 'var(--text-3)', fontWeight: 600, marginTop: 1 }}>
                {pct}%
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ALT C — Kalan miktar odaklı (büyük rakam)
function MacroAlt_Remaining({ label, current, goal, unit, tone }) {
  const remaining = Math.max(0, goal - current);
  const pct = goal > 0 ? Math.min(100, (current / goal) * 100) : 0;
  const done = current >= goal;
  return (
    <div style={{
      background: done ? 'rgba(52,199,89,0.08)' : 'var(--surface)',
      border: '1px solid ' + (done ? 'rgba(52,199,89,0.3)' : 'rgba(255,255,255,0.08)'),
      borderRadius: 14, padding: '10px 12px', position: 'relative', overflow: 'hidden',
    }}>
      <div style={{
        position: 'absolute', left: 0, top: 0, bottom: 0,
        width: `${pct}%`, background: tone, opacity: 0.10,
      }} />
      <div style={{ position: 'relative' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
          <span style={{ width: 6, height: 6, borderRadius: 3, background: tone }} />
          <span style={{ fontSize: 9.5, letterSpacing: 1.1, color: 'var(--text-3)', fontWeight: 700 }}>{label}</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 3, marginTop: 4 }}>
          <span style={{ fontSize: 20, fontWeight: 700, fontVariantNumeric: 'tabular-nums', color: done ? 'var(--green)' : '#fff', letterSpacing: -0.5 }}>
            {done ? '✓' : remaining}
          </span>
          <span style={{ fontSize: 11, color: 'var(--text-3)' }}>{done ? 'tamam' : `${unit} kaldı`}</span>
        </div>
      </div>
    </div>
  );
}

// =============================================
// FITNESS EXERCISE CARD alternatifleri
// =============================================

// ALT A — Tablo görünümü (kompakt, geçmiş set referansı)
function FitAlt_Table({ ex, sets, onAdd, onUpd, onDel, lastSets }) {
  return (
    <div style={{
      background: 'var(--surface)', borderRadius: 14,
      border: '1px solid rgba(201,169,97,0.35)',
      padding: '14px 14px 12px',
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 12 }}>
        <div>
          <div style={{ fontSize: 16, fontWeight: 600 }}>{ex.name}</div>
          <div style={{ fontSize: 11, color: 'var(--text-3)', marginTop: 2 }}>{ex.group} · son antrenman 8×70kg</div>
        </div>
        <div style={{ fontSize: 11, color: 'var(--gold)', fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>
          {sets.length} / 3
        </div>
      </div>

      <div style={{
        display: 'grid', gridTemplateColumns: '24px 1fr 1fr 22px',
        gap: 8, padding: '6px 4px 4px',
        fontSize: 9.5, letterSpacing: 1.1, color: 'var(--text-3)', fontWeight: 700,
        borderBottom: '1px solid rgba(255,255,255,0.06)',
      }}>
        <span>SET</span>
        <span style={{ textAlign: 'center' }}>KG</span>
        <span style={{ textAlign: 'center' }}>TEKRAR</span>
        <span></span>
      </div>
      {sets.map((s, i) => (
        <div key={i} style={{
          display: 'grid', gridTemplateColumns: '24px 1fr 1fr 22px',
          gap: 8, alignItems: 'center', padding: '6px 4px',
          borderBottom: i < sets.length - 1 ? '1px solid rgba(255,255,255,0.04)' : 'none',
        }}>
          <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--gold)', fontVariantNumeric: 'tabular-nums' }}>{i + 1}</span>
          <FitInlineNum value={s.kg} onChange={(v) => onUpd(i, { kg: v })} step={2.5} decimals={1} suffix="kg" />
          <FitInlineNum value={s.reps} onChange={(v) => onUpd(i, { reps: v })} step={1} suffix="" />
          <button onClick={() => onDel(i)} style={{
            width: 22, height: 22, background: 'transparent', border: 'none',
            color: 'var(--text-3)', cursor: 'pointer', fontSize: 16, padding: 0,
          }}>×</button>
        </div>
      ))}
      <button onClick={onAdd} style={{
        width: '100%', padding: '8px', marginTop: 8,
        background: 'transparent', color: 'var(--gold)',
        border: '1px solid rgba(201,169,97,0.3)', borderRadius: 8,
        fontSize: 12, fontWeight: 600, cursor: 'pointer',
      }}>+ Set Ekle</button>
    </div>
  );
}
function FitInlineNum({ value, onChange, step, decimals = 0, suffix }) {
  const fmt = (v) => decimals ? v.toFixed(decimals) : String(v);
  const [text, setText] = React.useState(fmt(value));
  React.useEffect(() => { setText(fmt(value)); }, [value]);
  const commit = () => {
    const v = parseFloat(text);
    if (isNaN(v)) { setText(fmt(value)); return; }
    onChange(v);
  };
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 1,
      background: 'rgba(255,255,255,0.05)',
      border: '1px solid rgba(255,255,255,0.10)',
      borderRadius: 6, height: 28, padding: '0 4px', minWidth: 0,
    }}>
      <input
        type="text"
        inputMode="decimal"
        value={text}
        onChange={(e) => setText(e.target.value)}
        onBlur={commit}
        onFocus={(e) => e.target.select()}
        onKeyDown={(e) => { if (e.key === 'Enter') e.target.blur(); }}
        style={{
          flex: 1, minWidth: 0, height: 26,
          background: 'transparent', border: 'none', outline: 'none',
          color: '#fff', textAlign: 'center', fontSize: 14, fontWeight: 600,
          fontVariantNumeric: 'tabular-nums', padding: 0,
        }}
      />
      {suffix && (
        <span style={{ fontSize: 9, color: 'var(--text-3)' }}>{suffix}</span>
      )}
    </div>
  );
}

// ALT B — Pill/chip set görünümü (her set yatay pill)
function FitAlt_Pills({ ex, sets, onAdd, onUpd, onDel, activeIdx, setActiveIdx }) {
  return (
    <div style={{
      background: 'var(--surface)', borderRadius: 14,
      border: '1px solid rgba(201,169,97,0.35)',
      padding: '14px 14px 12px',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
        <div>
          <div style={{ fontSize: 16, fontWeight: 600 }}>{ex.name}</div>
          <div style={{ fontSize: 11, color: 'var(--text-3)', marginTop: 1 }}>{ex.group}</div>
        </div>
        <button onClick={onAdd} style={{
          width: 28, height: 28, borderRadius: 14,
          background: 'rgba(201,169,97,0.2)', border: '1px solid rgba(201,169,97,0.4)',
          color: 'var(--gold)', cursor: 'pointer', fontSize: 16, padding: 0, lineHeight: 1,
        }}>+</button>
      </div>

      <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', marginBottom: 8 }}>
        {sets.map((s, i) => {
          const active = activeIdx === i;
          return (
            <button key={i} onClick={() => setActiveIdx(i)} style={{
              padding: '7px 10px', borderRadius: 8,
              background: active ? 'var(--gold)' : 'rgba(255,255,255,0.06)',
              border: '1px solid ' + (active ? 'transparent' : 'rgba(255,255,255,0.08)'),
              color: active ? '#000' : '#fff', cursor: 'pointer',
              fontSize: 12, fontWeight: 600, fontVariantNumeric: 'tabular-nums',
              display: 'flex', alignItems: 'center', gap: 6,
            }}>
              <span style={{ opacity: 0.6 }}>{i + 1}</span>
              <span>{s.kg}<span style={{ fontSize: 9, opacity: 0.7 }}>kg</span></span>
              <span style={{ opacity: 0.4 }}>×</span>
              <span>{s.reps}</span>
            </button>
          );
        })}
      </div>

      {sets[activeIdx] && (
        <div style={{
          background: 'rgba(0,0,0,0.3)', borderRadius: 10, padding: '10px 12px',
          display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12,
        }}>
          <FitDial label="AĞIRLIK" suffix="kg" value={sets[activeIdx].kg} step={2.5}
            onChange={(v) => onUpd(activeIdx, { kg: v })} />
          <FitDial label="TEKRAR" suffix="" value={sets[activeIdx].reps} step={1}
            onChange={(v) => onUpd(activeIdx, { reps: v })} />
        </div>
      )}
    </div>
  );
}
function FitDial({ label, value, onChange, step, suffix }) {
  return (
    <div>
      <div style={{ fontSize: 9.5, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700, marginBottom: 4 }}>{label}</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <button onClick={() => onChange(Math.max(0, value - step))} style={dialBtn}>−</button>
        <div style={{ flex: 1, fontSize: 22, fontWeight: 700, textAlign: 'center', fontVariantNumeric: 'tabular-nums', color: 'var(--gold)' }}>
          {value}<span style={{ fontSize: 11, color: 'var(--text-3)', marginLeft: 2 }}>{suffix}</span>
        </div>
        <button onClick={() => onChange(value + step)} style={dialBtn}>+</button>
      </div>
    </div>
  );
}
const dialBtn = {
  width: 28, height: 28, borderRadius: 14,
  background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.1)',
  color: '#fff', cursor: 'pointer', fontSize: 14, padding: 0,
};

// ALT C — Hacim göstergeli, geçmişle karşılaştırma
function FitAlt_Volume({ ex, sets, onAdd, onUpd, onDel, lastVolume }) {
  const volume = sets.reduce((s, x) => s + (x.reps || 0) * (x.kg || 0), 0);
  const diff = volume - (lastVolume || 0);
  return (
    <div style={{
      background: 'var(--surface)', borderRadius: 14,
      border: '1px solid rgba(201,169,97,0.35)',
      padding: '14px',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 12 }}>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 16, fontWeight: 600 }}>{ex.name}</div>
          <div style={{ fontSize: 11, color: 'var(--text-3)', marginTop: 1 }}>{ex.group}</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 9.5, letterSpacing: 1.1, color: 'var(--text-3)', fontWeight: 700 }}>HACİM</div>
          <div style={{ fontSize: 16, fontWeight: 700, color: 'var(--gold)', fontVariantNumeric: 'tabular-nums' }}>
            {volume.toLocaleString()} <span style={{ fontSize: 10, color: 'var(--text-3)' }}>kg</span>
          </div>
          {lastVolume > 0 && (
            <div style={{
              fontSize: 10, fontWeight: 600,
              color: diff >= 0 ? 'var(--green)' : 'var(--red)',
              fontVariantNumeric: 'tabular-nums',
            }}>
              {diff >= 0 ? '↑' : '↓'} {Math.abs(diff)} kg
            </div>
          )}
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        {sets.map((s, i) => {
          const setVol = (s.reps || 0) * (s.kg || 0);
          const maxVol = Math.max(...sets.map(x => (x.reps || 0) * (x.kg || 0)), 1);
          return (
            <div key={i} style={{
              display: 'grid', gridTemplateColumns: '18px 1fr 1fr 20px',
              gap: 4, alignItems: 'center', position: 'relative',
              padding: '6px 6px', borderRadius: 8,
              background: 'rgba(0,0,0,0.25)',
              overflow: 'hidden',
            }}>
              <div style={{
                position: 'absolute', left: 0, top: 0, bottom: 0,
                width: `${(setVol / maxVol) * 100}%`, background: 'var(--gold)', opacity: 0.10,
              }} />
              <span style={{ fontSize: 12, fontWeight: 700, color: 'var(--gold)', fontVariantNumeric: 'tabular-nums', position: 'relative' }}>{i + 1}</span>
              <FitInlineNum value={s.kg} onChange={(v) => onUpd(i, { kg: v })} step={2.5} decimals={1} suffix="kg" />
              <FitInlineNum value={s.reps} onChange={(v) => onUpd(i, { reps: v })} step={1} suffix="" />
              <button onClick={() => onDel(i)} style={{
                width: 22, height: 22, background: 'transparent', border: 'none',
                color: 'var(--text-3)', cursor: 'pointer', fontSize: 16, padding: 0, position: 'relative',
              }}>×</button>
            </div>
          );
        })}
      </div>
      <button onClick={onAdd} style={{
        width: '100%', padding: '9px', marginTop: 8,
        background: 'rgba(201,169,97,0.12)', color: 'var(--gold)',
        border: '1px dashed rgba(201,169,97,0.4)', borderRadius: 10,
        fontSize: 12, fontWeight: 600, cursor: 'pointer',
      }}>+ Set Ekle</button>
    </div>
  );
}

// =============================================
// SON 7 GÜN alternatifleri
// =============================================

// ALT A — Ay heatmap görünümü (her gün rengi ne kadar dolu olduğunu gösterir)
function Last7Alt_Heatmap({ days, selected, onSelect, today }) {
  const max = Math.max(2400, ...days.map(d => d.kcal));
  const completion = (d) => {
    const k = d.kcal / max;
    const sScore = Math.min(1, d.sets / 12);
    return (k + sScore) / 2;
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 6px 10px' }}>
        <span style={{ fontSize: 11, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700 }}>BU HAFTA</span>
        <span style={{ fontSize: 11, color: 'var(--text-3)' }}>aktivite yoğunluğu</span>
      </div>
      <div style={{
        background: 'var(--surface)', borderRadius: 14,
        border: '1px solid rgba(255,255,255,0.06)', padding: '14px',
      }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 6 }}>
          {days.map(d => {
            const score = completion(d);
            const isSel = d.key === selected;
            const isToday = d.key === today;
            const intensity = 0.10 + score * 0.85;
            return (
              <button key={d.key} onClick={() => onSelect(d.key)} style={{
                aspectRatio: '1', borderRadius: 8,
                background: `rgba(201,169,97,${intensity})`,
                border: isSel ? '2px solid var(--gold)' : (isToday ? '1.5px solid rgba(201,169,97,0.5)' : '1px solid rgba(255,255,255,0.05)'),
                cursor: 'pointer', padding: 0,
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                gap: 2,
              }}>
                <div style={{ fontSize: 9, color: score > 0.5 ? '#000' : 'var(--text-3)', fontWeight: 700, letterSpacing: 0.5 }}>
                  {d.date.toLocaleDateString('tr-TR', { weekday: 'short' }).slice(0,3).toUpperCase()}
                </div>
                <div style={{ fontSize: 16, fontWeight: 700, color: score > 0.5 ? '#000' : '#fff', fontVariantNumeric: 'tabular-nums' }}>
                  {d.date.getDate()}
                </div>
              </button>
            );
          })}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 14, fontSize: 10, color: 'var(--text-3)' }}>
          <span>az</span>
          <div style={{ display: 'flex', gap: 2 }}>
            {[0.10, 0.30, 0.55, 0.80, 0.95].map(i => (
              <div key={i} style={{ width: 14, height: 8, borderRadius: 2, background: `rgba(201,169,97,${i})` }} />
            ))}
          </div>
          <span>çok</span>
          <span style={{ flex: 1 }} />
          <span style={{ fontVariantNumeric: 'tabular-nums' }}>
            {days.filter(d => d.kcal > 0 || d.sets > 0).length}/7 aktif
          </span>
        </div>
      </div>
    </div>
  );
}

// ALT B — Trend grafiği (kalori smooth çizgi + harcama bar overlay)
function Last7Alt_Trend({ days, selected, onSelect, today, goalKcal = 2400 }) {
  const w = 320, h = 130, pad = 14;
  const max = Math.max(goalKcal * 1.1, ...days.map(d => d.kcal));
  const maxSpend = Math.max(1, ...days.map(d => d.spend || 0));
  const stepX = (w - pad * 2) / (days.length - 1);
  const points = days.map((d, i) => ({
    x: pad + i * stepX,
    y: pad + (1 - d.kcal / max) * (h - pad * 2),
    d,
  }));
  const path = points.map((p, i) => (i === 0 ? `M${p.x},${p.y}` : `L${p.x},${p.y}`)).join(' ');
  const area = path + ` L${points[points.length-1].x},${h - pad} L${pad},${h - pad} Z`;
  const goalY = pad + (1 - goalKcal / max) * (h - pad * 2);
  const barW = 12;
  const baseY = h - pad;

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 6px 10px' }}>
        <span style={{ fontSize: 11, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700 }}>SON 7 GÜN</span>
        <span style={{ fontSize: 11, color: 'var(--text-3)' }}>kcal · harcama</span>
      </div>
      <div style={{
        background: 'var(--surface)', borderRadius: 14,
        border: '1px solid rgba(255,255,255,0.06)', padding: '12px 4px 4px',
      }}>
        <svg width="100%" height={h} viewBox={`0 0 ${w} ${h}`} style={{ display: 'block' }}>
          <defs>
            <linearGradient id="kcalGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#C9A961" stopOpacity="0.4"/>
              <stop offset="100%" stopColor="#C9A961" stopOpacity="0"/>
            </linearGradient>
            <linearGradient id="spendGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#5AB7FF" stopOpacity="0.95"/>
              <stop offset="100%" stopColor="#5AB7FF" stopOpacity="0.55"/>
            </linearGradient>
          </defs>

          {/* spend bars (behind line) */}
          {points.map(p => {
            const sp = p.d.spend || 0;
            const barH = (sp / maxSpend) * (h - pad * 2) * 0.7;
            const isSel = p.d.key === selected;
            return (
              <g key={'b' + p.d.key} onClick={() => onSelect(p.d.key)} style={{ cursor: 'pointer' }}>
                <rect
                  x={p.x - barW/2} y={baseY - barH}
                  width={barW} height={barH}
                  rx={2} fill="url(#spendGrad)"
                  opacity={isSel ? 1 : 0.7}
                />
              </g>
            );
          })}

          {/* goal line */}
          <line x1={pad} y1={goalY} x2={w - pad} y2={goalY} stroke="rgba(201,169,97,0.3)" strokeWidth="1" strokeDasharray="3 3"/>
          <text x={w - pad} y={goalY - 3} fontSize="9" fill="rgba(201,169,97,0.6)" textAnchor="end">hedef</text>

          {/* kcal area + line */}
          <path d={area} fill="url(#kcalGrad)"/>
          <path d={path} fill="none" stroke="#C9A961" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>

          {/* points */}
          {points.map(p => {
            const isSel = p.d.key === selected;
            return (
              <g key={p.d.key} onClick={() => onSelect(p.d.key)} style={{ cursor: 'pointer' }}>
                <circle cx={p.x} cy={p.y} r={isSel ? 5 : 3} fill={isSel ? '#fff' : '#C9A961'} stroke="#C9A961" strokeWidth="2"/>
                {isSel && (
                  <g>
                    <rect x={p.x - 38} y={p.y - 38} width="76" height="30" rx="5" fill="#000" stroke="#C9A961" strokeWidth="1"/>
                    <text x={p.x} y={p.y - 25} fontSize="10" fill="#C9A961" textAnchor="middle" fontWeight="700">
                      {(p.d.kcal/1000).toFixed(1)}k kcal
                    </text>
                    <text x={p.x} y={p.y - 13} fontSize="9" fill="#5AB7FF" textAnchor="middle" fontWeight="600">
                      ₺{(p.d.spend || 0).toLocaleString('tr-TR')}
                    </text>
                  </g>
                )}
              </g>
            );
          })}
        </svg>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', padding: '4px 4px 6px' }}>
          {days.map(d => {
            const isSel = d.key === selected;
            const isToday = d.key === today;
            return (
              <button key={d.key} onClick={() => onSelect(d.key)} style={{
                background: 'transparent', border: 'none', cursor: 'pointer',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, padding: '4px 0',
                color: isSel ? 'var(--gold)' : (isToday ? '#fff' : 'var(--text-3)'),
              }}>
                <span style={{ fontSize: 9, letterSpacing: 0.5, fontWeight: 700, textTransform: 'uppercase' }}>
                  {d.date.toLocaleDateString('tr-TR', { weekday: 'short' }).slice(0,3)}
                </span>
                <span style={{ fontSize: 12, fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>
                  {d.date.getDate()}
                </span>
              </button>
            );
          })}
        </div>
        <div style={{ display: 'flex', gap: 12, padding: '4px 10px 8px' }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 10, color: 'var(--text-3)' }}>
            <span style={{ width: 10, height: 2, background: '#C9A961', borderRadius: 1 }} /> kcal
          </span>
          <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 10, color: 'var(--text-3)' }}>
            <span style={{ width: 8, height: 8, background: '#5AB7FF', borderRadius: 2 }} /> harcama
          </span>
        </div>
      </div>
    </div>
  );
}

// ALT C — Streak / başarımlar (gamification)
function Last7Alt_Streak({ days, selected, onSelect, today }) {
  const goalKcal = 2400;
  const days_ = days.map(d => ({
    ...d,
    kcalOk: d.kcal >= goalKcal * 0.85 && d.kcal <= goalKcal * 1.15,
    workoutOk: d.sets > 0,
    spendOk: d.spend <= 700,
  }));

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 6px 10px' }}>
        <span style={{ fontSize: 11, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700 }}>HAFTANIN ÖZETİ</span>
      </div>
      <div style={{
        background: 'var(--surface)', borderRadius: 14,
        border: '1px solid rgba(255,255,255,0.06)', padding: '14px',
      }}>
        {/* 3 streak rows */}
        {[
          { key: 'kcalOk', label: 'Kalori', tone: 'var(--gold)', icon: '◐' },
          { key: 'workoutOk', label: 'Antrenman', tone: '#FF6B6B', icon: '◇' },
          { key: 'spendOk', label: 'Bütçe', tone: '#5AB7FF', icon: '◊' },
        ].map(track => {
          const hits = days_.filter(d => d[track.key]).length;
          return (
            <div key={track.key} style={{ marginBottom: 12 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 6 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <span style={{ width: 6, height: 6, borderRadius: 3, background: track.tone }} />
                  <span style={{ fontSize: 12, fontWeight: 600 }}>{track.label}</span>
                </div>
                <span style={{ fontSize: 11, color: 'var(--text-3)', fontVariantNumeric: 'tabular-nums' }}>
                  <span style={{ color: track.tone, fontWeight: 700 }}>{hits}</span>/7
                </span>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7,1fr)', gap: 4 }}>
                {days_.map(d => {
                  const ok = d[track.key];
                  const isSel = d.key === selected;
                  const isToday = d.key === today;
                  return (
                    <button key={d.key} onClick={() => onSelect(d.key)} style={{
                      height: 24, borderRadius: 6,
                      background: ok ? track.tone : 'rgba(255,255,255,0.06)',
                      border: isSel ? '1.5px solid #fff' : 'none',
                      cursor: 'pointer', padding: 0,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      fontSize: 10, fontWeight: 700,
                      color: ok ? '#000' : (isToday ? '#fff' : 'var(--text-3)'),
                      fontVariantNumeric: 'tabular-nums',
                    }}>
                      {d.date.getDate()}
                    </button>
                  );
                })}
              </div>
            </div>
          );
        })}
        <div style={{
          marginTop: 4, padding: '10px 12px',
          background: 'rgba(201,169,97,0.10)', borderRadius: 10,
          display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <div style={{ fontSize: 22 }}>🔥</div>
          <div>
            <div style={{ fontSize: 13, fontWeight: 600 }}>3 günlük seri</div>
            <div style={{ fontSize: 11, color: 'var(--text-3)' }}>3 hedefi de tutturduğun gün sayısı</div>
          </div>
        </div>
      </div>
    </div>
  );
}

window.MacroAlt_Ring = MacroAlt_Ring;
window.MacroAlt_Stacked = MacroAlt_Stacked;
window.MacroAlt_Remaining = MacroAlt_Remaining;
window.FitAlt_Table = FitAlt_Table;
window.FitAlt_Pills = FitAlt_Pills;
window.FitAlt_Volume = FitAlt_Volume;
window.Last7Alt_Heatmap = Last7Alt_Heatmap;
window.Last7Alt_Trend = Last7Alt_Trend;
window.Last7Alt_Streak = Last7Alt_Streak;
