// ────────────────────────────────────────────────
// 2. FITNESS LOGLARI
// Her hareket için set/tekrar/ağırlık girişi
// ────────────────────────────────────────────────
function FitnessScreen({ onOpenCalendar, onOpenSettings, exercises, log, setLog, dateLabel }) {
  const [openId, setOpenId] = React.useState(exercises[0]?.id);

  const totalSets = Object.values(log).reduce((s, sets) => s + sets.length, 0);
  const totalVolume = Object.entries(log).reduce((s, [, sets]) =>
    s + sets.reduce((a, st) => a + (st.reps || 0) * (st.kg || 0), 0), 0);

  const addSet = (id) => {
    const sets = log[id] || [];
    const last = sets[sets.length - 1];
    setLog({ ...log, [id]: [...sets, { reps: last?.reps || 8, kg: last?.kg || 20 }] });
  };
  const updSet = (id, i, patch) => {
    const sets = [...(log[id] || [])];
    sets[i] = { ...sets[i], ...patch };
    setLog({ ...log, [id]: sets });
  };
  const delSet = (id, i) => {
    const sets = [...(log[id] || [])];
    sets.splice(i, 1);
    setLog({ ...log, [id]: sets });
  };

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: '#000', color: '#fff', paddingTop: 54 }}>
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
              <circle cx="12" cy="12" r="9" stroke="#C9A961" strokeWidth="1.6"/>
            </svg>
          </IconBtn>
        </div>
      </div>

      {/* SUMMARY ROW */}
      <div style={{ padding: '8px 22px 14px', display: 'flex', gap: 10 }}>
        <SummaryPill label="SET" value={totalSets} />
        <SummaryPill label="HACİM" value={`${Math.round(totalVolume).toLocaleString()} kg`} />
        <SummaryPill label="HAREKET" value={Object.keys(log).filter(k => log[k]?.length).length} />
      </div>

      {/* EXERCISE LIST */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 80px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {exercises.map(ex => {
            const sets = log[ex.id] || [];
            const open = openId === ex.id;
            return (
              <div key={ex.id} style={{
                background: 'var(--surface)',
                borderRadius: 14,
                border: open ? '1px solid rgba(201,169,97,0.35)' : '1px solid transparent',
                overflow: 'hidden',
              }}>
                <button onClick={() => setOpenId(open ? null : ex.id)} style={{
                  width: '100%', padding: '14px 14px',
                  background: 'transparent', border: 'none', color: '#fff', cursor: 'pointer',
                  display: 'flex', alignItems: 'center', gap: 12, textAlign: 'left',
                }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 16, fontWeight: 500 }}>{ex.name}</div>
                    <div style={{ fontSize: 12, color: 'var(--text-2)', marginTop: 2 }}>{ex.group}</div>
                  </div>
                  {sets.length > 0 && (
                    <div style={{ fontSize: 12, color: 'var(--gold)', fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>
                      {sets.length} set
                    </div>
                  )}
                  <svg width="14" height="14" viewBox="0 0 14 14" style={{ transform: open ? 'rotate(90deg)' : 'none', transition: 'transform .15s' }}>
                    <path d="M5 2l5 5-5 5" stroke="rgba(255,255,255,0.4)" strokeWidth="1.6" fill="none" strokeLinecap="round"/>
                  </svg>
                </button>

                {open && (
                  <div style={{ padding: '0 14px 14px' }}>
                    <div style={{
                      display: 'grid', gridTemplateColumns: '24px 1fr 1fr 22px',
                      gap: 8, padding: '6px 4px 4px',
                      fontSize: 10, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700,
                      borderBottom: '1px solid rgba(255,255,255,0.06)',
                    }}>
                      <span>SET</span>
                      <span style={{ textAlign: 'center' }}>KG</span>
                      <span style={{ textAlign: 'center' }}>TEKRAR</span>
                      <span></span>
                    </div>
                    {sets.length === 0 && (
                      <div style={{ fontSize: 13, color: 'var(--text-3)', padding: '8px 2px' }}>Henüz set girilmedi</div>
                    )}
                    {sets.map((st, i) => (
                      <div key={i} style={{
                        display: 'grid', gridTemplateColumns: '24px 1fr 1fr 22px',
                        gap: 8, alignItems: 'center', padding: '6px 4px',
                        borderBottom: i < sets.length - 1 ? '1px solid rgba(255,255,255,0.04)' : 'none',
                      }}>
                        <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--gold)', fontVariantNumeric: 'tabular-nums' }}>{i + 1}</span>
                        <NumberInput value={st.kg} onChange={(v) => updSet(ex.id, i, { kg: v })} decimals={1} suffix="kg" />
                        <NumberInput value={st.reps} onChange={(v) => updSet(ex.id, i, { reps: v })} />
                        <button onClick={() => delSet(ex.id, i)} style={{
                          width: 22, height: 22, background: 'transparent',
                          border: 'none', color: 'var(--text-3)', cursor: 'pointer', fontSize: 16, padding: 0,
                        }}>×</button>
                      </div>
                    ))}
                    <button onClick={() => addSet(ex.id)} style={{
                      width: '100%', padding: '10px',
                      background: 'rgba(201,169,97,0.15)',
                      border: '1px dashed rgba(201,169,97,0.4)',
                      borderRadius: 10, color: 'var(--gold)', cursor: 'pointer',
                      fontSize: 13, fontWeight: 600, marginTop: 8,
                    }}>+ Set Ekle</button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

function SummaryPill({ label, value }) {
  return (
    <div style={{
      flex: 1, background: 'var(--surface)', borderRadius: 12,
      border: '1px solid rgba(255,255,255,0.06)',
      padding: '8px 12px',
    }}>
      <div style={{ fontSize: 9.5, letterSpacing: 1.1, color: 'var(--text-3)', fontWeight: 700 }}>{label}</div>
      <div style={{ fontSize: 16, fontWeight: 600, marginTop: 2, fontVariantNumeric: 'tabular-nums' }}>{value}</div>
    </div>
  );
}

function NumberInput({ value, onChange, decimals = 0, suffix }) {
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
      borderRadius: 6, height: 30, padding: '0 6px', minWidth: 0,
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
          flex: 1, minWidth: 0, height: 28,
          background: 'transparent', border: 'none', outline: 'none',
          color: '#fff', textAlign: 'center', fontSize: 14, fontWeight: 600,
          fontVariantNumeric: 'tabular-nums', padding: 0,
        }}
      />
      {suffix && (<span style={{ fontSize: 9, color: 'var(--text-3)' }}>{suffix}</span>)}
    </div>
  );
}

function NumberStepper({ value, onChange, step = 1, decimals = 0 }) {
  const fmt = (v) => decimals ? v.toFixed(decimals) : String(v);
  return (
    <div style={{
      display: 'flex', alignItems: 'center',
      background: 'rgba(255,255,255,0.05)',
      border: '1px solid rgba(255,255,255,0.08)',
      borderRadius: 8, height: 30,
    }}>
      <button onClick={() => onChange(Math.max(0, +(value - step).toFixed(2)))} style={stepBtn}>−</button>
      <input
        value={fmt(value)}
        onChange={(e) => {
          const v = parseFloat(e.target.value);
          onChange(isNaN(v) ? 0 : v);
        }}
        style={{
          flex: 1, minWidth: 0, height: 28, background: 'transparent', border: 'none',
          color: '#fff', textAlign: 'center', fontSize: 14, fontWeight: 600,
          fontVariantNumeric: 'tabular-nums', outline: 'none',
        }}
      />
      <button onClick={() => onChange(+(value + step).toFixed(2))} style={stepBtn}>+</button>
    </div>
  );
}

const stepBtn = {
  width: 28, height: 28, background: 'transparent', border: 'none',
  color: 'rgba(255,255,255,0.7)', cursor: 'pointer', fontSize: 16, fontWeight: 500,
};

window.FitnessScreen = FitnessScreen;
window.NumberInput = NumberInput;
