// app.js — ElizAstro Progressive Web App
// Main application module: navigation, views, data persistence, chart wheel.

import { Ephemeris } from './ephemeris.js';
import { ChartEngine } from './chart-engine.js';
import { Interpretations } from './interpretations.js';

// ============================================================
// Constants
// ============================================================

const ZODIAC_NAMES = {
  aries: 'Aries', taurus: 'Taurus', gemini: 'Gemini', cancer: 'Cancer',
  leo: 'Leo', virgo: 'Virgo', libra: 'Libra', scorpio: 'Scorpio',
  sagittarius: 'Sagittarius', capricorn: 'Capricorn', aquarius: 'Aquarius', pisces: 'Pisces',
};

const ELEMENT_COLORS = {
  fire: '#D4603A', earth: '#7B9E6B', air: '#6B9EC4', water: '#5B6BAA',
};

const ELEMENT_FOR_SIGN = ChartEngine.ELEMENT_MAP;

// ============================================================
// Data Persistence (localStorage)
// ============================================================

function getProfile() {
  try {
    const data = localStorage.getItem('elizastro_profile');
    return data ? JSON.parse(data) : null;
  } catch { return null; }
}

function saveProfile(profile) {
  localStorage.setItem('elizastro_profile', JSON.stringify(profile));
}

function deleteProfile() {
  localStorage.removeItem('elizastro_profile');
}

function getFriends() {
  try {
    const data = localStorage.getItem('elizastro_friends');
    return data ? JSON.parse(data) : [];
  } catch { return []; }
}

function saveFriends(friends) {
  localStorage.setItem('elizastro_friends', JSON.stringify(friends));
}

// ============================================================
// Chart Calculation Helpers
// ============================================================

function buildDateUTC(profile) {
  // birthDate is "YYYY-MM-DD", birthTime is "HH:MM" or empty
  const [year, month, day] = profile.birthDate.split('-').map(Number);
  let hour = 12, minute = 0; // default to noon if no birth time
  if (profile.hasBirthTime && profile.birthTime) {
    const parts = profile.birthTime.split(':').map(Number);
    hour = parts[0] || 0;
    minute = parts[1] || 0;
  }
  // birthTimezoneOffset is in seconds from GMT
  const tzOffsetHours = (profile.birthTimezoneOffset || 0) / 3600;
  return new Date(Date.UTC(year, month - 1, day, hour - tzOffsetHours, minute));
}

function calculateChart(profile) {
  const date = buildDateUTC(profile);
  return ChartEngine.calculateChart(date, profile.birthLat, profile.birthLon);
}

// ============================================================
// Zodiac icon helper
// ============================================================

function zodiacIconHTML(sign, className = 'zodiac-icon') {
  return `<img src="icons/${sign}.png" alt="${ZODIAC_NAMES[sign] || sign}" class="${className}">`;
}

// ============================================================
// Navigation State
// ============================================================

let currentView = 'home';
let subView = null; // for friend detail etc.
let subViewData = null;
const contentEl = () => document.getElementById('app-content');
const tabBar = () => document.getElementById('tab-bar');

function showView(viewName, sub = null, data = null) {
  currentView = viewName;
  subView = sub;
  subViewData = data;

  // Update tab bar active state
  document.querySelectorAll('.tab-bar-item').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.view === viewName);
  });

  const el = contentEl();
  el.classList.add('transitioning');

  setTimeout(() => {
    switch (viewName) {
      case 'home': renderHome(el); break;
      case 'chart': renderChart(el); break;
      case 'friends':
        if (sub === 'detail') renderFriendDetail(el, data);
        else if (sub === 'add') renderAddFriend(el);
        else renderFriends(el);
        break;
      case 'synastry': renderSynastry(el); break;
      default: renderHome(el);
    }
    el.classList.remove('transitioning');
  }, 150);
}

// ============================================================
// Onboarding View
// ============================================================

function renderOnboarding(el) {
  tabBar().style.display = 'none';

  el.innerHTML = `
    <div class="onboarding slide-up">
      <img src="icons/sagittarius.png" alt="ElizAstro" class="onboarding-logo">
      <h1>ElizAstro</h1>
      <p>Your personal celestial companion. Enter your birth details to discover your natal chart.</p>
      <div class="form-card">
        ${profileFormHTML()}
        <button class="btn-primary" id="save-profile-btn" disabled>Discover My Chart</button>
      </div>
    </div>
  `;

  attachProfileFormHandlers('save-profile-btn', (profile) => {
    saveProfile(profile);
    tabBar().style.display = 'flex';
    showView('home');
  });
}

// ============================================================
// Shared Profile Form HTML + Handlers
// ============================================================

function profileFormHTML(existing = null) {
  const name = existing ? existing.name : '';
  const date = existing ? existing.birthDate : '';
  const time = existing ? (existing.birthTime || '') : '';
  const hasBirthTime = existing ? existing.hasBirthTime : true;
  const locationName = existing ? (existing.birthLocationName || '') : '';

  return `
    <div class="form-group">
      <label for="profile-name">Name</label>
      <input type="text" id="profile-name" placeholder="Enter name" value="${name}" autocomplete="off">
    </div>
    <div class="form-row">
      <div class="form-group">
        <label for="profile-date">Birth Date</label>
        <input type="date" id="profile-date" value="${date}">
      </div>
      <div class="form-group">
        <label for="profile-time">Birth Time</label>
        <input type="time" id="profile-time" value="${time}" ${!hasBirthTime ? 'disabled' : ''}>
        <div class="checkbox-row">
          <input type="checkbox" id="profile-has-time" ${hasBirthTime ? 'checked' : ''}>
          <label for="profile-has-time">I know my birth time</label>
        </div>
      </div>
    </div>
    <div class="form-group location-search">
      <label for="profile-location">Birth City</label>
      <input type="text" id="profile-location" placeholder="Search for a city..." autocomplete="off" value="${locationName}">
      <div class="location-results" id="location-results" style="display:none;"></div>
      ${locationName ? `<div class="location-selected" id="location-selected"><span class="check">&#10003;</span> ${locationName}</div>` : '<div class="location-selected" id="location-selected" style="display:none;"></div>'}
    </div>
    <input type="hidden" id="profile-lat" value="${existing ? existing.birthLat : ''}">
    <input type="hidden" id="profile-lon" value="${existing ? existing.birthLon : ''}">
    <input type="hidden" id="profile-tz" value="${existing ? existing.birthTimezoneOffset : ''}">
    <input type="hidden" id="profile-locname" value="${locationName}">
  `;
}

function attachProfileFormHandlers(saveBtnId, onSave) {
  const nameInput = document.getElementById('profile-name');
  const dateInput = document.getElementById('profile-date');
  const timeInput = document.getElementById('profile-time');
  const hasTimeCheck = document.getElementById('profile-has-time');
  const locationInput = document.getElementById('profile-location');
  const locationResults = document.getElementById('location-results');
  const locationSelected = document.getElementById('location-selected');
  const latInput = document.getElementById('profile-lat');
  const lonInput = document.getElementById('profile-lon');
  const tzInput = document.getElementById('profile-tz');
  const locNameInput = document.getElementById('profile-locname');
  const saveBtn = document.getElementById(saveBtnId);

  // Birth time checkbox
  hasTimeCheck.addEventListener('change', () => {
    timeInput.disabled = !hasTimeCheck.checked;
    if (!hasTimeCheck.checked) timeInput.value = '';
    validateForm();
  });

  // Location search with debounce
  let searchTimeout = null;
  locationInput.addEventListener('input', () => {
    const query = locationInput.value.trim();
    if (query.length < 2) {
      locationResults.style.display = 'none';
      return;
    }
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => searchLocation(query), 400);
  });

  // Click outside to close results
  document.addEventListener('click', (e) => {
    if (!e.target.closest('.location-search')) {
      locationResults.style.display = 'none';
    }
  });

  async function searchLocation(query) {
    try {
      const resp = await fetch(
        `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=5`,
        { headers: { 'Accept-Language': 'en' } }
      );
      const results = await resp.json();
      if (results.length === 0) {
        locationResults.innerHTML = '<div class="location-result-item" style="color:var(--cream-dim);">No results found</div>';
        locationResults.style.display = 'block';
        return;
      }
      locationResults.innerHTML = results.map(r =>
        `<div class="location-result-item" data-lat="${r.lat}" data-lon="${r.lon}" data-name="${escapeHTML(r.display_name)}">${escapeHTML(r.display_name)}</div>`
      ).join('');
      locationResults.style.display = 'block';

      locationResults.querySelectorAll('.location-result-item').forEach(item => {
        item.addEventListener('click', () => {
          const lat = parseFloat(item.dataset.lat);
          const lon = parseFloat(item.dataset.lon);
          const name = item.dataset.name;
          latInput.value = lat;
          lonInput.value = lon;
          locNameInput.value = name;
          // Timezone approximation from longitude
          const tzOffsetSeconds = Math.round(lon / 15) * 3600;
          tzInput.value = tzOffsetSeconds;
          locationInput.value = name;
          locationResults.style.display = 'none';
          locationSelected.innerHTML = `<span class="check">&#10003;</span> ${escapeHTML(name)}`;
          locationSelected.style.display = 'flex';
          validateForm();
        });
      });
    } catch {
      locationResults.innerHTML = '<div class="location-result-item" style="color:var(--cream-dim);">Search unavailable offline</div>';
      locationResults.style.display = 'block';
    }
  }

  // Validate
  function validateForm() {
    const valid = nameInput.value.trim() &&
                  dateInput.value &&
                  latInput.value &&
                  lonInput.value;
    saveBtn.disabled = !valid;
  }

  nameInput.addEventListener('input', validateForm);
  dateInput.addEventListener('input', validateForm);
  validateForm();

  // Save
  saveBtn.addEventListener('click', () => {
    if (saveBtn.disabled) return;
    const profile = {
      name: nameInput.value.trim(),
      birthDate: dateInput.value,
      birthTime: timeInput.value || '',
      hasBirthTime: hasTimeCheck.checked,
      birthLat: parseFloat(latInput.value),
      birthLon: parseFloat(lonInput.value),
      birthTimezoneOffset: parseInt(tzInput.value) || 0,
      birthLocationName: locNameInput.value,
    };
    onSave(profile);
  });
}

function escapeHTML(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

// ============================================================
// Home View
// ============================================================

function renderHome(el) {
  const profile = getProfile();
  if (!profile) { renderOnboarding(el); return; }

  const chart = calculateChart(profile);
  const report = ChartEngine.TransitEngine.weeklyReport(chart, profile.birthLat, profile.birthLon);

  const sunPos = chart.positions.find(p => p.body === 'sun');
  const moonPos = chart.positions.find(p => p.body === 'moon');

  el.innerHTML = `
    <div class="fade-in">
      <!-- Greeting -->
      <div class="greeting">
        <div class="greeting-name">Hello, ${escapeHTML(profile.name)}</div>
        <div class="greeting-sub">
          ${zodiacIconHTML(chart.sunSign)}
          <span>${ZODIAC_NAMES[chart.sunSign]} Sun</span>
        </div>
      </div>

      <!-- Big Three -->
      <div class="section">
        <div class="heading-sm">Your Big Three</div>
        <div class="big-three">
          <div class="big-three-item">
            ${zodiacIconHTML(chart.sunSign)}
            <div class="big-three-label">Sun</div>
            <div class="big-three-sign">${ZODIAC_NAMES[chart.sunSign]}</div>
            <div class="big-three-degree">${sunPos ? sunPos.formattedDegree : ''}</div>
          </div>
          <div class="big-three-item">
            ${zodiacIconHTML(chart.moonSign)}
            <div class="big-three-label">Moon</div>
            <div class="big-three-sign">${ZODIAC_NAMES[chart.moonSign]}</div>
            <div class="big-three-degree">${moonPos ? moonPos.formattedDegree : ''}</div>
          </div>
          <div class="big-three-item">
            ${zodiacIconHTML(chart.risingSign)}
            <div class="big-three-label">Rising</div>
            <div class="big-three-sign">${ZODIAC_NAMES[chart.risingSign]}</div>
            <div class="big-three-degree">${ChartEngine.formattedDegree({ body: 'asc', longitude: chart.ascendantLongitude })}</div>
          </div>
        </div>
      </div>

      <!-- Current Moon -->
      <div class="section">
        <div class="heading-sm">Current Moon</div>
        <div class="moon-badge" style="margin-top:8px;">
          ${zodiacIconHTML(report.currentMoonSign)}
          <span>Moon in ${ZODIAC_NAMES[report.currentMoonSign]}</span>
        </div>
      </div>

      <!-- Active Retrogrades -->
      ${report.retrogrades.length > 0 ? `
        <div class="section">
          <div class="heading-sm">Active Retrogrades</div>
          <div class="retrogrades-row">
            ${report.retrogrades.map(r =>
              `<div class="retrograde-badge">${ChartEngine.BODY_SYMBOLS[r.body] || ''} ${ChartEngine.BODY_NAMES[r.body]} in ${ZODIAC_NAMES[r.sign]}</div>`
            ).join('')}
          </div>
        </div>
      ` : ''}

      <!-- This Week's Energy -->
      <div class="section">
        <div class="heading-sm">This Week's Energy</div>
        <div class="stagger" style="margin-top:10px;">
          ${report.topTransits.length > 0 ? report.topTransits.map(t => transitCardHTML(t)).join('') : '<p class="caption-text" style="margin-top:8px;">No major transits this week. A quiet sky can be a gift.</p>'}
        </div>
      </div>
    </div>
  `;
}

function transitCardHTML(transit) {
  const aspectDef = ChartEngine.AspectType[transit.aspectType];
  const isHarm = aspectDef && aspectDef.isHarmonious;
  const cls = isHarm ? 'harmonious' : 'challenging';
  const transitName = ChartEngine.BODY_NAMES[transit.transitingPosition.body] || transit.transitingPosition.body;
  const natalName = ChartEngine.BODY_NAMES[transit.natalPosition.body] || transit.natalPosition.body;
  const aspectName = aspectDef ? aspectDef.name : transit.aspectType;
  const interp = Interpretations.transitInterpretation(transit.transitingPosition.body, transit.natalPosition.body, transit.aspectType);

  return `
    <div class="transit-card ${cls} fade-in">
      <div class="transit-indicator ${cls}"></div>
      <div class="transit-body">
        <div class="transit-title">${transitName} ${aspectDef ? aspectDef.symbol : ''} ${natalName}</div>
        <div class="caption-text" style="margin-bottom:4px;">${aspectName} &middot; House ${transit.houseAffected}</div>
        <div class="transit-description">${interp}</div>
      </div>
    </div>
  `;
}

// ============================================================
// Chart View
// ============================================================

function renderChart(el) {
  const profile = getProfile();
  if (!profile) { renderOnboarding(el); return; }

  const chart = calculateChart(profile);
  const sunPos = chart.positions.find(p => p.body === 'sun');
  const moonPos = chart.positions.find(p => p.body === 'moon');

  el.innerHTML = `
    <div class="fade-in">
      <div class="greeting" style="padding-bottom:0;">
        <div class="heading-lg">${escapeHTML(profile.name)}'s Natal Chart</div>
      </div>

      <!-- Big Three -->
      <div class="big-three">
        <div class="big-three-item">
          ${zodiacIconHTML(chart.sunSign)}
          <div class="big-three-label">Sun</div>
          <div class="big-three-sign">${ZODIAC_NAMES[chart.sunSign]}</div>
        </div>
        <div class="big-three-item">
          ${zodiacIconHTML(chart.moonSign)}
          <div class="big-three-label">Moon</div>
          <div class="big-three-sign">${ZODIAC_NAMES[chart.moonSign]}</div>
        </div>
        <div class="big-three-item">
          ${zodiacIconHTML(chart.risingSign)}
          <div class="big-three-label">Rising</div>
          <div class="big-three-sign">${ZODIAC_NAMES[chart.risingSign]}</div>
        </div>
      </div>

      <!-- Chart Wheel -->
      <div class="chart-wheel-container">
        <canvas id="chart-wheel" width="600" height="600"></canvas>
      </div>

      <!-- Planet Positions -->
      <div class="section">
        <div class="heading-sm">Planet Positions</div>
        <div class="card" style="margin-top:10px;">
          ${chart.positions.map(pos => {
            const sign = ChartEngine.signFromLongitude(pos.longitude);
            const house = chart.house(pos.longitude);
            const retro = pos.isRetrograde && pos.body !== 'northNode' ? '<span class="planet-retrograde">Rx</span>' : '';
            return `
              <div class="planet-row">
                <span class="planet-symbol">${ChartEngine.BODY_SYMBOLS[pos.body] || ''}</span>
                <span class="planet-name">${ChartEngine.BODY_NAMES[pos.body] || pos.body}</span>
                <img src="icons/${sign}.png" class="zodiac-icon" style="width:20px;height:20px;margin-right:6px;filter:sepia(0.3) saturate(1.5) brightness(0.9);opacity:0.8;">
                <span class="planet-position">${pos.formattedDegree} &middot; H${house}</span>
                ${retro}
              </div>
            `;
          }).join('')}
        </div>
      </div>

      <!-- Natal Aspects -->
      <div class="section">
        <div class="heading-sm">Natal Aspects</div>
        <div class="card" style="margin-top:10px;">
          ${chart.aspects.length > 0 ? chart.aspects.map(a => {
            const def = ChartEngine.AspectType[a.type];
            const isHarm = def && def.isHarmonious;
            return `
              <div class="aspect-row">
                <span class="aspect-symbol ${isHarm ? 'harmonious' : 'challenging'}">${def ? def.symbol : ''}</span>
                <span class="aspect-bodies">${ChartEngine.BODY_SYMBOLS[a.body1] || ''} ${ChartEngine.BODY_NAMES[a.body1]} ${def ? def.symbol : ''} ${ChartEngine.BODY_SYMBOLS[a.body2] || ''} ${ChartEngine.BODY_NAMES[a.body2]}</span>
                <span class="aspect-type">${def ? def.name : a.type}</span>
                <span class="aspect-orb">${a.orb.toFixed(1)}&deg;</span>
              </div>
            `;
          }).join('') : '<p class="caption-text">No major aspects found.</p>'}
        </div>
      </div>

      <!-- Edit / Reset -->
      <div style="text-align:center;margin:20px 0 40px;">
        <button class="btn-ghost btn-danger" id="reset-profile-btn">Reset Profile</button>
      </div>
    </div>
  `;

  // Draw chart wheel
  requestAnimationFrame(() => {
    const canvas = document.getElementById('chart-wheel');
    if (canvas) drawChartWheel(canvas, chart);
  });

  // Reset handler
  document.getElementById('reset-profile-btn')?.addEventListener('click', () => {
    if (confirm('Reset your profile? This will delete your birth data.')) {
      deleteProfile();
      showView('home');
    }
  });
}

// ============================================================
// Chart Wheel Drawing (Canvas)
// ============================================================

function drawChartWheel(canvas, chart) {
  const dpr = window.devicePixelRatio || 1;
  const displaySize = Math.min(canvas.parentElement.offsetWidth, 600);
  canvas.style.width = displaySize + 'px';
  canvas.style.height = displaySize + 'px';
  canvas.width = displaySize * dpr;
  canvas.height = displaySize * dpr;

  const ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);

  const cx = displaySize / 2;
  const cy = displaySize / 2;
  const outerR = displaySize / 2 - 8;
  const zodiacR = outerR;
  const zodiacInnerR = outerR - 36;
  const houseR = zodiacInnerR;
  const innerR = houseR * 0.38;
  const planetR = (zodiacInnerR + innerR) / 2 + 10;

  const ascLon = chart.ascendantLongitude;

  // Convert ecliptic longitude to canvas angle (ASC on left, CCW)
  function lonToAngle(lon) {
    return (ascLon - lon) * Math.PI / 180;
  }

  function posOnCircle(angle, r) {
    return { x: cx + r * Math.cos(angle), y: cy - r * Math.sin(angle) };
  }

  // --- Background ---
  ctx.fillStyle = '#171933';
  ctx.fillRect(0, 0, displaySize, displaySize);

  // --- Zodiac Ring ---
  const signColors = {
    fire: '#3D2222', earth: '#2A3326', air: '#222A36', water: '#252238',
  };

  for (let i = 0; i < 12; i++) {
    const sign = ChartEngine.ZODIAC_SIGNS[i];
    const element = ELEMENT_FOR_SIGN[sign];
    const startLon = i * 30;
    const endLon = (i + 1) * 30;
    const startAngle = lonToAngle(endLon);
    const endAngle = lonToAngle(startLon);

    ctx.beginPath();
    ctx.arc(cx, cy, zodiacR, -startAngle, -endAngle, false);
    ctx.arc(cx, cy, zodiacInnerR, -endAngle, -startAngle, true);
    ctx.closePath();
    ctx.fillStyle = signColors[element] || '#222';
    ctx.fill();
    ctx.strokeStyle = '#2D3048';
    ctx.lineWidth = 0.5;
    ctx.stroke();

    // Zodiac symbol in the middle of the segment
    const midAngle = lonToAngle(startLon + 15);
    const symR = (zodiacR + zodiacInnerR) / 2;
    const symPos = posOnCircle(midAngle, symR);
    ctx.font = '14px serif';
    ctx.fillStyle = '#F5F0E1';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(ChartEngine.ZODIAC_SYMBOLS[sign], symPos.x, symPos.y);
  }

  // --- Outer ring border ---
  ctx.beginPath();
  ctx.arc(cx, cy, zodiacR, 0, Math.PI * 2);
  ctx.strokeStyle = '#E6BF59';
  ctx.lineWidth = 1.5;
  ctx.stroke();

  ctx.beginPath();
  ctx.arc(cx, cy, zodiacInnerR, 0, Math.PI * 2);
  ctx.strokeStyle = '#2D3048';
  ctx.lineWidth = 1;
  ctx.stroke();

  // --- Inner circle ---
  ctx.beginPath();
  ctx.arc(cx, cy, innerR, 0, Math.PI * 2);
  ctx.strokeStyle = '#2D3048';
  ctx.lineWidth = 1;
  ctx.stroke();

  // --- House Lines ---
  if (chart.houseCusps) {
    for (let i = 0; i < 12; i++) {
      const angle = lonToAngle(chart.houseCusps[i]);
      const isAngular = (i === 0 || i === 3 || i === 6 || i === 9);
      const from = posOnCircle(angle, isAngular ? zodiacR : zodiacInnerR);
      const to = posOnCircle(angle, innerR);

      ctx.beginPath();
      ctx.moveTo(from.x, from.y);
      ctx.lineTo(to.x, to.y);
      ctx.strokeStyle = isAngular ? '#E6BF59' : '#2D3048';
      ctx.lineWidth = isAngular ? 1.5 : 0.7;
      ctx.stroke();

      // House number
      const nextCusp = chart.houseCusps[(i + 1) % 12];
      let midLon = (chart.houseCusps[i] + nextCusp) / 2;
      // Handle wraparound
      if (Math.abs(chart.houseCusps[i] - nextCusp) > 180) {
        midLon = Ephemeris.normalizeAngle(midLon + 180);
      }
      const numAngle = lonToAngle(midLon);
      const numPos = posOnCircle(numAngle, innerR + 14);
      ctx.font = '10px sans-serif';
      ctx.fillStyle = 'rgba(245, 240, 225, 0.5)';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(String(i + 1), numPos.x, numPos.y);
    }
  }

  // --- ASC / MC labels ---
  const ascAngle = lonToAngle(chart.ascendantLongitude);
  const mcAngle = lonToAngle(chart.midheavenLongitude);

  function drawAngleLabel(angle, label, r) {
    const pos = posOnCircle(angle, r);
    ctx.font = 'bold 11px sans-serif';
    ctx.fillStyle = '#E6BF59';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(label, pos.x, pos.y);
  }

  drawAngleLabel(ascAngle, 'ASC', zodiacR + 14 < displaySize / 2 ? zodiacInnerR - 14 : innerR - 14);
  drawAngleLabel(mcAngle, 'MC', zodiacInnerR - 14);

  // --- Aspect Lines ---
  for (const aspect of chart.aspects) {
    const pos1 = chart.positions.find(p => p.body === aspect.body1);
    const pos2 = chart.positions.find(p => p.body === aspect.body2);
    if (!pos1 || !pos2) continue;

    const angle1 = lonToAngle(pos1.longitude);
    const angle2 = lonToAngle(pos2.longitude);
    const p1 = posOnCircle(angle1, innerR + 2);
    const p2 = posOnCircle(angle2, innerR + 2);

    const def = ChartEngine.AspectType[aspect.type];
    const isHarm = def && def.isHarmonious;

    ctx.beginPath();
    ctx.moveTo(p1.x, p1.y);
    ctx.lineTo(p2.x, p2.y);
    ctx.strokeStyle = isHarm ? 'rgba(107, 191, 138, 0.35)' : 'rgba(232, 150, 90, 0.35)';
    ctx.lineWidth = 0.6;
    ctx.stroke();
  }

  // --- Planet Symbols ---
  // Spread planets that are close together
  const planetAngles = chart.positions.map(pos => ({
    body: pos.body,
    rawAngle: lonToAngle(pos.longitude),
    longitude: pos.longitude,
  }));

  // Simple collision avoidance: sort by angle, then push apart
  const sorted = [...planetAngles].sort((a, b) => a.rawAngle - b.rawAngle);
  const minSep = 14 / planetR; // minimum angular separation in radians
  for (let pass = 0; pass < 3; pass++) {
    for (let i = 1; i < sorted.length; i++) {
      let diff = sorted[i].rawAngle - sorted[i - 1].rawAngle;
      if (diff < minSep && diff >= 0) {
        const adj = (minSep - diff) / 2;
        sorted[i - 1].rawAngle -= adj;
        sorted[i].rawAngle += adj;
      }
    }
  }

  const adjustedMap = {};
  for (const s of sorted) adjustedMap[s.body] = s.rawAngle;

  for (const pos of chart.positions) {
    const angle = adjustedMap[pos.body] !== undefined ? adjustedMap[pos.body] : lonToAngle(pos.longitude);
    const p = posOnCircle(angle, planetR);

    // Small dot at true position on inner ring edge
    const trueAngle = lonToAngle(pos.longitude);
    const dotPos = posOnCircle(trueAngle, zodiacInnerR - 4);
    ctx.beginPath();
    ctx.arc(dotPos.x, dotPos.y, 2, 0, Math.PI * 2);
    ctx.fillStyle = '#E6BF59';
    ctx.fill();

    // Symbol
    ctx.font = '15px serif';
    ctx.fillStyle = '#F5F0E1';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(ChartEngine.BODY_SYMBOLS[pos.body] || '?', p.x, p.y);

    // Retrograde indicator
    if (pos.isRetrograde && pos.body !== 'northNode') {
      ctx.font = '8px sans-serif';
      ctx.fillStyle = '#E8965A';
      ctx.fillText('R', p.x + 8, p.y - 6);
    }
  }
}

// ============================================================
// Friends View
// ============================================================

function renderFriends(el) {
  const friends = getFriends();

  el.innerHTML = `
    <div class="fade-in">
      <div class="greeting" style="padding-bottom:12px;">
        <div class="heading-lg">Friends</div>
      </div>

      <button class="btn-secondary" id="add-friend-btn" style="width:100%;margin-bottom:20px;">
        + Add a Friend
      </button>

      ${friends.length > 0 ? `
        <div class="friends-list stagger">
          ${friends.map((f, i) => {
            const chart = calculateChart(f);
            return `
              <div class="friend-card fade-in" data-friend-idx="${i}">
                ${zodiacIconHTML(chart.sunSign)}
                <span class="friend-name">${escapeHTML(f.name)}</span>
                <span class="friend-sign">${ZODIAC_NAMES[chart.sunSign]}</span>
                <span class="friend-arrow">&rsaquo;</span>
              </div>
            `;
          }).join('')}
        </div>
      ` : `
        <div class="empty-state">
          <div class="empty-state-icon">&#x2728;</div>
          <p>Add friends to see their charts and compare your cosmic connections.</p>
        </div>
      `}
    </div>
  `;

  document.getElementById('add-friend-btn')?.addEventListener('click', () => {
    showView('friends', 'add');
  });

  el.querySelectorAll('.friend-card').forEach(card => {
    card.addEventListener('click', () => {
      const idx = parseInt(card.dataset.friendIdx);
      showView('friends', 'detail', idx);
    });
  });
}

function renderAddFriend(el) {
  el.innerHTML = `
    <div class="fade-in">
      <div class="detail-header">
        <button class="back-button" id="back-btn">&lsaquo; Friends</button>
      </div>
      <div class="heading-lg" style="margin-bottom:16px;">Add a Friend</div>
      <div class="form-card" style="max-width:100%;">
        ${profileFormHTML()}
        <button class="btn-primary" id="save-friend-btn" disabled>Add Friend</button>
      </div>
    </div>
  `;

  document.getElementById('back-btn')?.addEventListener('click', () => showView('friends'));

  attachProfileFormHandlers('save-friend-btn', (profile) => {
    const friends = getFriends();
    friends.push(profile);
    saveFriends(friends);
    showView('friends');
  });
}

function renderFriendDetail(el, friendIdx) {
  const friends = getFriends();
  const friend = friends[friendIdx];
  if (!friend) { showView('friends'); return; }

  const chart = calculateChart(friend);
  const sunPos = chart.positions.find(p => p.body === 'sun');
  const moonPos = chart.positions.find(p => p.body === 'moon');

  el.innerHTML = `
    <div class="fade-in">
      <div class="detail-header">
        <button class="back-button" id="back-btn">&lsaquo; Friends</button>
        <span class="detail-title">${escapeHTML(friend.name)}'s Chart</span>
      </div>

      <!-- Big Three -->
      <div class="big-three">
        <div class="big-three-item">
          ${zodiacIconHTML(chart.sunSign)}
          <div class="big-three-label">Sun</div>
          <div class="big-three-sign">${ZODIAC_NAMES[chart.sunSign]}</div>
        </div>
        <div class="big-three-item">
          ${zodiacIconHTML(chart.moonSign)}
          <div class="big-three-label">Moon</div>
          <div class="big-three-sign">${ZODIAC_NAMES[chart.moonSign]}</div>
        </div>
        <div class="big-three-item">
          ${zodiacIconHTML(chart.risingSign)}
          <div class="big-three-label">Rising</div>
          <div class="big-three-sign">${ZODIAC_NAMES[chart.risingSign]}</div>
        </div>
      </div>

      <!-- Chart Wheel -->
      <div class="chart-wheel-container">
        <canvas id="friend-chart-wheel" width="600" height="600"></canvas>
      </div>

      <!-- Planet Positions -->
      <div class="section">
        <div class="heading-sm">Planet Positions</div>
        <div class="card" style="margin-top:10px;">
          ${chart.positions.map(pos => {
            const sign = ChartEngine.signFromLongitude(pos.longitude);
            const house = chart.house(pos.longitude);
            const retro = pos.isRetrograde && pos.body !== 'northNode' ? '<span class="planet-retrograde">Rx</span>' : '';
            return `
              <div class="planet-row">
                <span class="planet-symbol">${ChartEngine.BODY_SYMBOLS[pos.body] || ''}</span>
                <span class="planet-name">${ChartEngine.BODY_NAMES[pos.body] || pos.body}</span>
                <img src="icons/${sign}.png" class="zodiac-icon" style="width:20px;height:20px;margin-right:6px;filter:sepia(0.3) saturate(1.5) brightness(0.9);opacity:0.8;">
                <span class="planet-position">${pos.formattedDegree} &middot; H${house}</span>
                ${retro}
              </div>
            `;
          }).join('')}
        </div>
      </div>

      <!-- Remove Friend -->
      <div style="text-align:center;margin:20px 0 40px;">
        <button class="btn-ghost btn-danger" id="remove-friend-btn">Remove Friend</button>
      </div>
    </div>
  `;

  document.getElementById('back-btn')?.addEventListener('click', () => showView('friends'));

  requestAnimationFrame(() => {
    const canvas = document.getElementById('friend-chart-wheel');
    if (canvas) drawChartWheel(canvas, chart);
  });

  document.getElementById('remove-friend-btn')?.addEventListener('click', () => {
    if (confirm(`Remove ${friend.name} from your friends?`)) {
      friends.splice(friendIdx, 1);
      saveFriends(friends);
      showView('friends');
    }
  });
}

// ============================================================
// Synastry View
// ============================================================

function renderSynastry(el) {
  const profile = getProfile();
  if (!profile) { renderOnboarding(el); return; }

  const friends = getFriends();
  const allProfiles = [profile, ...friends];

  el.innerHTML = `
    <div class="fade-in">
      <div class="greeting" style="padding-bottom:12px;">
        <div class="heading-lg">Synastry</div>
        <p class="caption-text" style="margin-top:4px;">Compare the cosmic connection between two charts.</p>
      </div>

      ${allProfiles.length < 2 ? `
        <div class="empty-state">
          <div class="empty-state-icon">&#x1F49B;</div>
          <p>Add at least one friend to compare charts and explore your cosmic compatibility.</p>
          <button class="btn-secondary" id="goto-friends-btn" style="margin-top:16px;">Add a Friend</button>
        </div>
      ` : `
        <div class="synastry-selectors">
          <select id="synastry-person1">
            ${allProfiles.map((p, i) => `<option value="${i}">${escapeHTML(p.name)}</option>`).join('')}
          </select>
          <select id="synastry-person2">
            ${allProfiles.map((p, i) => `<option value="${i}" ${i === 1 ? 'selected' : ''}>${escapeHTML(p.name)}</option>`).join('')}
          </select>
        </div>
        <div id="synastry-result"></div>
      `}
    </div>
  `;

  document.getElementById('goto-friends-btn')?.addEventListener('click', () => showView('friends', 'add'));

  const sel1 = document.getElementById('synastry-person1');
  const sel2 = document.getElementById('synastry-person2');
  if (sel1 && sel2) {
    const updateSynastry = () => {
      const idx1 = parseInt(sel1.value);
      const idx2 = parseInt(sel2.value);
      const p1 = allProfiles[idx1];
      const p2 = allProfiles[idx2];
      if (!p1 || !p2) return;

      const chart1 = calculateChart(p1);
      const chart2 = calculateChart(p2);
      const report = ChartEngine.SynastryCalculator.compare(chart1, chart2);

      const circumference = 2 * Math.PI * 60;
      const dashOffset = circumference - (report.overallHarmony / 100) * circumference;

      const resultEl = document.getElementById('synastry-result');
      resultEl.innerHTML = `
        <div class="fade-in">
          <!-- Harmony Gauge -->
          <div class="harmony-gauge">
            <div class="harmony-circle">
              <svg viewBox="0 0 140 140">
                <circle class="gauge-bg" cx="70" cy="70" r="60"/>
                <circle class="gauge-fill" cx="70" cy="70" r="60"
                  stroke-dasharray="${circumference}"
                  stroke-dashoffset="${dashOffset}"/>
              </svg>
              <div class="harmony-value">
                <div class="harmony-number">${Math.round(report.overallHarmony)}</div>
                <div class="harmony-label">Harmony</div>
              </div>
            </div>
            <div class="harmony-message">${Interpretations.compatibilityMessage(report.overallHarmony)}</div>
          </div>

          <!-- Harmonious Aspects -->
          ${report.harmonious.length > 0 ? `
            <div class="section">
              <div class="heading-sm" style="color:var(--harmonious);">Harmonious Aspects</div>
              <div class="card" style="margin-top:10px;">
                ${report.harmonious.map(a => {
                  const def = ChartEngine.AspectType[a.type];
                  return `
                    <div class="aspect-row">
                      <span class="aspect-symbol harmonious">${def ? def.symbol : ''}</span>
                      <span class="aspect-bodies">${ChartEngine.BODY_NAMES[a.body1] || a.body1} &ndash; ${ChartEngine.BODY_NAMES[a.body2] || a.body2}</span>
                      <span class="aspect-type">${def ? def.name : a.type}</span>
                      <span class="aspect-orb">${a.orb.toFixed(1)}&deg;</span>
                    </div>
                  `;
                }).join('')}
              </div>
            </div>
          ` : ''}

          <!-- Challenging Aspects -->
          ${report.challenging.length > 0 ? `
            <div class="section">
              <div class="heading-sm" style="color:var(--challenging);">Growth Aspects</div>
              <div class="card" style="margin-top:10px;">
                ${report.challenging.map(a => {
                  const def = ChartEngine.AspectType[a.type];
                  return `
                    <div class="aspect-row">
                      <span class="aspect-symbol challenging">${def ? def.symbol : ''}</span>
                      <span class="aspect-bodies">${ChartEngine.BODY_NAMES[a.body1] || a.body1} &ndash; ${ChartEngine.BODY_NAMES[a.body2] || a.body2}</span>
                      <span class="aspect-type">${def ? def.name : a.type}</span>
                      <span class="aspect-orb">${a.orb.toFixed(1)}&deg;</span>
                    </div>
                  `;
                }).join('')}
              </div>
            </div>
          ` : ''}
        </div>
      `;
    };

    sel1.addEventListener('change', updateSynastry);
    sel2.addEventListener('change', updateSynastry);
    updateSynastry();
  }
}

// ============================================================
// Initialization
// ============================================================

function init() {
  // Register Service Worker
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('sw.js').catch(() => {});
  }

  // Tab bar handlers
  document.querySelectorAll('.tab-bar-item').forEach(btn => {
    btn.addEventListener('click', () => {
      showView(btn.dataset.view);
    });
  });

  // Show initial view
  const profile = getProfile();
  if (profile) {
    tabBar().style.display = 'flex';
    showView('home');
  } else {
    renderOnboarding(contentEl());
  }
}

// Start the app when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
