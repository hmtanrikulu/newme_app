// ────────────────────────────────────────────────
// 4. AYARLAR
// — Yiyecek listesi ekle/çıkar
// — Egzersiz listesi ekle/çıkar
// — Kalori & makro hedefi
// — Harcama hedefi
// ────────────────────────────────────────────────
function SettingsScreen({ onClose, foods, setFoods, exercises, setExercises, goals, setGoals, spendGoal, setSpendGoal }) {
  const [tab, setTab] = React.useState('food');

  const removeFood = (id) => setFoods(foods.filter(f => f.id !== id));
  const removeEx = (id) => setExercises(exercises.filter(e => e.id !== id));

  const addFood = () => {
    const name = prompt('Yiyecek adı?');
    if (!name) return;
    const kcal = parseFloat(prompt('Porsiyon başına kcal?', '100')) || 0;
    const p = parseFloat(prompt('Protein (g)?', '5')) || 0;
    const c = parseFloat(prompt('Karbonhidrat (g)?', '15')) || 0;
    const f = parseFloat(prompt('Yağ (g)?', '2')) || 0;
    const unit = prompt('Birim? (adet/g/dilim/ml)', 'g') || 'g';
    setFoods([...foods, { id: 'f' + Date.now(), name, kcal, p, c, f, unit, serving: 1 }]);
  };
  const addEx = () => {
    const name = prompt('Hareket adı?');
    if (!name) return;
    const group = prompt('Kas grubu? (Göğüs, Sırt, Bacak, Omuz, Kol, Core)', 'Göğüs') || 'Diğer';
    setExercises([...exercises, { id: 'e' + Date.now(), name, group }]);
  };

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: '#000', color: '#fff', paddingTop: 54 }}>
      {/* Nav */}
      <div style={{
        padding: '6px 16px 12px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        borderBottom: '1px solid rgba(255,255,255,0.06)',
      }}>
        <button onClick={onClose} style={{ background: 'none', border: 'none', color: 'var(--gold)', fontSize: 16, cursor: 'pointer', padding: 0 }}>Sırala</button>
        <div style={{ fontSize: 17, fontWeight: 600 }}>Ayarlar</div>
        <button onClick={onClose} style={{ background: 'none', border: 'none', color: 'var(--gold)', fontSize: 16, fontWeight: 600, cursor: 'pointer', padding: 0 }}>Bitti</button>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', padding: '12px 16px 8px', gap: 6 }}>
        {[
          { id: 'food', label: 'Yiyecek' },
          { id: 'ex', label: 'Egzersiz' },
          { id: 'goals', label: 'Hedefler' },
        ].map(t => (
          <button key={t.id} onClick={() => setTab(t.id)} style={{
            flex: 1, height: 32, borderRadius: 10,
            background: tab === t.id ? 'rgba(201,169,97,0.2)' : 'rgba(255,255,255,0.05)',
            border: '1px solid ' + (tab === t.id ? 'rgba(201,169,97,0.5)' : 'transparent'),
            color: tab === t.id ? 'var(--gold)' : '#fff',
            fontSize: 13, fontWeight: 600, cursor: 'pointer',
          }}>{t.label}</button>
        ))}
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 30px' }}>
        {tab === 'food' && (
          <div>
            <div style={{ fontSize: 11, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700, padding: '8px 6px' }}>YİYECEKLER</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {foods.map(f => (
                <ListRow key={f.id} title={f.name} subtitle={`${f.kcal} kcal · ${f.p}P / ${f.c}K / ${f.f}Y`} onRemove={() => removeFood(f.id)} />
              ))}
              <button onClick={addFood} style={addRowBtn}>+ Yiyecek Ekle</button>
            </div>
          </div>
        )}

        {tab === 'ex' && (
          <div>
            <div style={{ fontSize: 11, letterSpacing: 1, color: 'var(--text-3)', fontWeight: 700, padding: '8px 6px' }}>EGZERSİZLER</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {exercises.map(e => (
                <ListRow key={e.id} title={e.name} subtitle={e.group} onRemove={() => removeEx(e.id)} />
              ))}
              <button onClick={addEx} style={addRowBtn}>+ Egzersiz Ekle</button>
            </div>
          </div>
        )}

        {tab === 'goals' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14, paddingTop: 4 }}>
            <GoalRow label="Günlük kalori" unit="kcal" value={goals.kcal} step={50} onChange={(v) => setGoals({ ...goals, kcal: v })} />
            <GoalRow label="Protein hedefi" unit="g" value={goals.p} step={5} onChange={(v) => setGoals({ ...goals, p: v })} tone="#FF6B6B" />
            <GoalRow label="Karbonhidrat hedefi" unit="g" value={goals.c} step={5} onChange={(v) => setGoals({ ...goals, c: v })} tone="#5AB7FF" />
            <GoalRow label="Yağ hedefi" unit="g" value={goals.f} step={5} onChange={(v) => setGoals({ ...goals, f: v })} tone="#FFC857" />
            <div style={{ height: 1, background: 'rgba(255,255,255,0.08)', margin: '6px 0' }} />
            <GoalRow label="Günlük harcama limiti" unit="₺" prefix value={spendGoal} step={100} onChange={setSpendGoal} tone="var(--gold)" />
          </div>
        )}
      </div>
    </div>
  );
}

function ListRow({ title, subtitle, onRemove }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      background: 'var(--surface)', borderRadius: 12, padding: '11px 12px',
    }}>
      <button onClick={onRemove} style={{
        width: 22, height: 22, borderRadius: 11, background: 'var(--red)',
        border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer', flexShrink: 0,
      }}>
        <span style={{ width: 10, height: 2, background: '#fff', display: 'block' }} />
      </button>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 500 }}>{title}</div>
        <div style={{ fontSize: 12, color: 'var(--text-2)', marginTop: 1 }}>{subtitle}</div>
      </div>
      <svg width="12" height="16" viewBox="0 0 12 16" style={{ opacity: 0.3 }}>
        <path d="M2 3h8M2 8h8M2 13h8" stroke="#fff" strokeWidth="1.4" strokeLinecap="round"/>
      </svg>
    </div>
  );
}

function GoalRow({ label, unit, value, step, onChange, tone, prefix }) {
  return (
    <div style={{
      background: 'var(--surface)', borderRadius: 14,
      border: '1px solid rgba(255,255,255,0.06)',
      padding: '12px 14px',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
        {tone && <span style={{ width: 6, height: 6, borderRadius: 3, background: tone }} />}
        <span style={{ fontSize: 14, fontWeight: 500, flex: 1 }}>{label}</span>
        <span style={{ fontSize: 16, fontWeight: 600, fontVariantNumeric: 'tabular-nums', color: 'var(--gold)' }}>
          {prefix && unit}{value.toLocaleString('tr-TR')}{!prefix && ' ' + unit}
        </span>
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        <button onClick={() => onChange(Math.max(0, value - step))} style={goalBtn}>−</button>
        <button onClick={() => onChange(value + step)} style={goalBtn}>+</button>
      </div>
    </div>
  );
}

const goalBtn = {
  flex: 1, height: 32, borderRadius: 8,
  background: 'rgba(255,255,255,0.05)', border: '1px solid rgba(255,255,255,0.08)',
  color: '#fff', fontSize: 18, cursor: 'pointer', fontWeight: 500,
};

const addRowBtn = {
  background: 'rgba(201,169,97,0.12)',
  border: '1px dashed rgba(201,169,97,0.4)',
  borderRadius: 12, padding: '12px',
  color: 'var(--gold)', fontSize: 14, fontWeight: 600, cursor: 'pointer',
  textAlign: 'left', paddingLeft: 16,
};

window.SettingsScreen = SettingsScreen;
