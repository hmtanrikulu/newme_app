// Bottom tab bar for switching between Food / Fitness / Spending
function TabBar({ tab, setTab }) {
  const tabs = [
    { id: 'food', label: 'Yemek', icon: (a) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={a ? '#C9A961' : 'rgba(255,255,255,0.4)'} strokeWidth="1.6" strokeLinecap="round">
        <path d="M7 3v8a2 2 0 002 2v8M7 3v6M11 3v6M16 3c-1 0-2 1-2 3v5h2v10"/>
      </svg>
    )},
    { id: 'fit', label: 'Fitness', icon: (a) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={a ? '#C9A961' : 'rgba(255,255,255,0.4)'} strokeWidth="1.6" strokeLinecap="round">
        <path d="M3 9v6M5 7v10M9 6v12M15 6v12M19 7v10M21 9v6M9 12h6"/>
      </svg>
    )},
    { id: 'spend', label: 'Harcama', icon: (a) => (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={a ? '#C9A961' : 'rgba(255,255,255,0.4)'} strokeWidth="1.6" strokeLinecap="round">
        <path d="M8 4v16M5 9l8-3M5 13l8-3M16 6c2 0 3 2 3 4-1 6-7 8-11 8"/>
      </svg>
    )},
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0, height: 64,
      background: 'rgba(20,20,20,0.85)', backdropFilter: 'blur(20px)',
      borderTop: '1px solid rgba(255,255,255,0.06)',
      display: 'flex', paddingBottom: 14, zIndex: 30,
    }}>
      {tabs.map(t => {
        const active = tab === t.id;
        return (
          <button key={t.id} onClick={() => setTab(t.id)} style={{
            flex: 1, background: 'transparent', border: 'none', cursor: 'pointer',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, paddingTop: 6,
          }}>
            {t.icon(active)}
            <span style={{ fontSize: 10, fontWeight: 600, color: active ? '#C9A961' : 'rgba(255,255,255,0.45)' }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// Main app — composes all screens, manages state, handles modal navigation
function App({ initialTab = 'food', initialModal = null }) {
  const dateLabel = '3 Mayıs Pazar';
  const today = '2026-05-03';

  // Default content
  const [foods, setFoods] = React.useState([
    { id: 'f1', name: 'Yumurta', kcal: 78, p: 6, c: 0.6, f: 5, unit: 'adet', serving: 1 },
    { id: 'f2', name: 'Ekmek', kcal: 80, p: 3, c: 15, f: 1, unit: 'dilim', serving: 1 },
    { id: 'f3', name: 'Yoğurt', kcal: 60, p: 4, c: 5, f: 3, unit: 'g', serving: 100 },
    { id: 'f4', name: 'Tavuk göğsü', kcal: 165, p: 31, c: 0, f: 3.6, unit: 'g', serving: 100 },
    { id: 'f5', name: 'Pirinç', kcal: 130, p: 2.7, c: 28, f: 0.3, unit: 'g', serving: 100 },
    { id: 'f6', name: 'Yulaf sütü', kcal: 50, p: 1, c: 7, f: 1.5, unit: 'ml', serving: 100 },
  ]);
  const [exercises, setExercises] = React.useState([
    { id: 'e1', name: 'Bench Press', group: 'Göğüs' },
    { id: 'e2', name: 'Squat', group: 'Bacak' },
    { id: 'e3', name: 'Deadlift', group: 'Sırt' },
    { id: 'e4', name: 'Pull Up', group: 'Sırt' },
    { id: 'e5', name: 'Push Ups', group: 'Göğüs' },
    { id: 'e6', name: 'Shoulder Press', group: 'Omuz' },
    { id: 'e7', name: 'Bicep Curl', group: 'Kol' },
    { id: 'e8', name: 'Plank', group: 'Core' },
  ]);
  const [goals, setGoals] = React.useState({ kcal: 2400, p: 180, c: 240, f: 80 });
  const [spendGoal, setSpendGoal] = React.useState(5000);

  // Per-day data: foodQty, fitnessLog, spendEntries
  const [foodQty, setFoodQty] = React.useState({ f1: 2, f2: 2, f3: 1, f4: 1, f5: 1 });
  const [fitnessLog, setFitnessLog] = React.useState({
    e1: [{ reps: 10, kg: 60 }, { reps: 8, kg: 70 }, { reps: 6, kg: 75 }],
    e3: [{ reps: 5, kg: 100 }, { reps: 5, kg: 110 }],
  });
  const [spendEntries, setSpendEntries] = React.useState([
    { cat: 'food', amount: 500 }, { cat: 'drink', amount: 200 },
    { cat: 'fun', amount: 800 }, { cat: 'cloth', amount: 2000 },
    { cat: 'market', amount: 800 },
  ]);

  React.useEffect(() => { window._allExercises = exercises; }, [exercises]);

  // Build last-7-days history (mock past days, real today)
  const totalKcal = foods.reduce((s, f) => s + (foodQty[f.id] || 0) * f.kcal, 0);
  const totalProt = foods.reduce((s, f) => s + (foodQty[f.id] || 0) * (f.p || 0), 0);
  const todaySpendByCat = spendEntries.reduce((acc, e) => {
    acc[e.cat] = (acc[e.cat] || 0) + e.amount; return acc;
  }, {});

  const dailyData = React.useMemo(() => {
    const data = {};
    // synthetic past days
    const seedDays = [
      { off: 6, kcal: 1850, protein: 140, sets: { e1: [{},{},{}], e5: [{},{}] }, spend: { food: 250, market: 600 } },
      { off: 5, kcal: 2100, protein: 165, sets: {}, spend: { drink: 80, fun: 400 } },
      { off: 4, kcal: 2300, protein: 175, sets: { e2: [{},{},{},{}], e3: [{},{},{}] }, spend: { food: 380 } },
      { off: 3, kcal: 1950, protein: 150, sets: { e6: [{},{},{}] }, spend: { market: 1200, food: 200 } },
      { off: 2, kcal: 2200, protein: 170, sets: { e1: [{},{},{},{}], e7: [{},{},{}] }, spend: { food: 320, drink: 150 } },
      { off: 1, kcal: 2050, protein: 160, sets: {}, spend: { cloth: 950, food: 180 } },
    ];
    seedDays.forEach(d => {
      const dt = new Date(2026, 4, 3); dt.setDate(dt.getDate() - d.off);
      const k = dt.toISOString().slice(0, 10);
      data[k] = { kcal: d.kcal, protein: d.protein, sets: d.sets, spend: d.spend };
    });
    data[today] = { kcal: totalKcal, protein: totalProt, sets: fitnessLog, spend: todaySpendByCat };
    return data;
  }, [totalKcal, totalProt, fitnessLog, todaySpendByCat]);

  const [tab, setTab] = React.useState(initialTab);
  const [modal, setModal] = React.useState(initialModal); // 'cal' | 'set' | null

  const openCal = () => setModal('cal');
  const openSet = () => setModal('set');
  const closeModal = () => setModal(null);

  let screen;
  if (tab === 'food') {
    screen = <FoodScreen onOpenCalendar={openCal} onOpenSettings={openSet}
      foods={foods} goals={goals} qty={foodQty} setQty={setFoodQty} dateLabel={dateLabel} />;
  } else if (tab === 'fit') {
    screen = <FitnessScreen onOpenCalendar={openCal} onOpenSettings={openSet}
      exercises={exercises} log={fitnessLog} setLog={setFitnessLog} dateLabel={dateLabel} />;
  } else {
    screen = <SpendingScreen onOpenCalendar={openCal} onOpenSettings={openSet}
      goal={spendGoal}
      entries={spendEntries}
      addEntry={(e) => setSpendEntries([...spendEntries, e])} />;
  }

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      {screen}
      <TabBar tab={tab} setTab={setTab} />
      {modal === 'cal' && (
        <div style={{ position: 'absolute', inset: 0, background: '#000', zIndex: 100 }}>
          <CalendarScreen onClose={closeModal} dailyData={dailyData} />
        </div>
      )}
      {modal === 'set' && (
        <div style={{ position: 'absolute', inset: 0, background: '#000', zIndex: 100 }}>
          <SettingsScreen onClose={closeModal}
            foods={foods} setFoods={setFoods}
            exercises={exercises} setExercises={setExercises}
            goals={goals} setGoals={setGoals}
            spendGoal={spendGoal} setSpendGoal={setSpendGoal} />
        </div>
      )}
    </div>
  );
}

window.App = App;
window.TabBar = TabBar;
