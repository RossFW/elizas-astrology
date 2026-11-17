// interpretations.js — Human-readable astrological text
// Warm, insightful, genuinely helpful. Not generic horoscope fluff.

// --- Sign Descriptions ---

const SIGN_DESCRIPTIONS = {
  aries: "Aries carries the spark of initiation. Bold and instinctive, Aries energy moves toward what it wants without apology. There is a beautiful directness here, a willingness to begin again and again. Aries reminds us that courage is not the absence of fear but the decision to act anyway.",

  taurus: "Taurus finds truth in what can be touched, tasted, and savored. This is the energy of deep roots and patient devotion. Taurus teaches us that stability is its own form of magic, that showing up consistently is one of the most radical things a person can do. There is profound wisdom in learning to rest.",

  gemini: "Gemini is the bridge between worlds, endlessly curious and beautifully adaptable. This energy collects experiences like seashells, turning each one over to examine its facets. Gemini reminds us that asking questions is more important than having answers, and that every conversation holds the seed of transformation.",

  cancer: "Cancer carries the memory of what it means to belong. Deeply intuitive and fiercely protective, this energy builds sanctuaries wherever it goes. Cancer teaches us that vulnerability is strength, that tending to the inner world is not retreat but the most essential kind of work.",

  leo: "Leo radiates the warmth of genuine self-expression. This is not ego but the courage to be fully, unapologetically alive. Leo energy lights rooms and lifts spirits, reminding us that joy is not frivolous but fundamental. When Leo shines, it gives everyone else permission to shine too.",

  virgo: "Virgo sees the sacred in the small things. This is the energy of devotion expressed through craft, care, and attention to what others overlook. Virgo teaches us that healing often lives in the details, that showing love through practical acts of service is its own form of poetry.",

  libra: "Libra holds the space between self and other with uncommon grace. This energy understands that beauty is not superficial but a reflection of inner harmony. Libra reminds us that relationship is the mirror through which we most clearly see ourselves, and that peace is something worth working toward.",

  scorpio: "Scorpio dives where others will not go. This is the energy of transformation through total honesty, the willingness to sit with uncomfortable truths until they yield their wisdom. Scorpio teaches us that endings are necessary for rebirth, that the deepest intimacy requires the deepest trust.",

  sagittarius: "Sagittarius seeks meaning in the vast expanse. This is the energy of the philosopher and the wanderer, always reaching toward the next horizon. Sagittarius reminds us that wisdom is not about certainty but about staying open, that the journey itself is the destination.",

  capricorn: "Capricorn understands that meaningful things take time. This is the energy of quiet determination, of building something that lasts. Capricorn teaches us that discipline is a form of self-respect, that the mountain is climbed one step at a time, and that the view from the summit is earned.",

  aquarius: "Aquarius sees the world not as it is but as it could be. This is the energy of the visionary, the one who cares deeply enough about the collective to challenge convention. Aquarius reminds us that belonging does not require conformity, that the most important truths often begin as the loneliest ones.",

  pisces: "Pisces dissolves the boundaries between self and cosmos. This is the energy of the dreamer, the mystic, the artist who translates the ineffable into feeling. Pisces teaches us that compassion is not weakness, that imagination is a legitimate way of knowing, and that sometimes the most real things cannot be seen.",
};

// --- Planet-in-Sign Interpretations ---
// Covers Sun, Moon, Mercury, Venus, Mars for all 12 signs.

const PLANET_SIGN = {
  sun: {
    aries: "Your Sun in Aries gives you a pioneering spirit. You lead with instinct and act with conviction. Your vitality comes from forward motion, from being the first to step into unknown territory. You teach others that it is safe to take initiative.",
    taurus: "Your Sun in Taurus grounds you in sensory wisdom. You build your life slowly and deliberately, valuing quality over speed. Your strength lies in your steadfastness. You teach others that patience and presence are radical acts.",
    gemini: "Your Sun in Gemini makes you a natural communicator and connector. Your mind moves quickly between ideas, seeing links others miss. You are at your best when learning, sharing, and staying curious about everything.",
    cancer: "Your Sun in Cancer centers your identity around emotional depth and belonging. You have an extraordinary ability to make others feel seen and safe. Your sensitivity is your superpower, not your vulnerability.",
    leo: "Your Sun in Leo means your essential nature radiates warmth and creative confidence. You are meant to express yourself fully and generously. When you share your light without agenda, you become magnetic.",
    virgo: "Your Sun in Virgo gives you a sharp, devoted mind. You notice what others overlook and find deep satisfaction in being genuinely useful. Your perfectionism is best when directed toward growth, not self-criticism.",
    libra: "Your Sun in Libra orients you toward harmony and connection. You have an innate sense of fairness and beauty. Your gift lies in creating balance, but remember that your own needs matter as much as anyone else's.",
    scorpio: "Your Sun in Scorpio gives you transformative intensity. You experience life at depth, unwilling to settle for surface-level anything. Your power lies in your honesty and your willingness to face what others avoid.",
    sagittarius: "Your Sun in Sagittarius makes you a seeker of truth and meaning. You need room to explore, both physically and philosophically. Your optimism is authentic, born from a genuine belief that life has purpose.",
    capricorn: "Your Sun in Capricorn gives you quiet ambition and deep integrity. You understand that meaningful achievement requires sustained effort. Your authority comes naturally because you hold yourself to the highest standards.",
    aquarius: "Your Sun in Aquarius gives you a unique perspective that does not easily fit into categories. You care deeply about progress and fairness. Your independence of thought is your greatest contribution to the world.",
    pisces: "Your Sun in Pisces gives you extraordinary empathy and creative intuition. You experience the world through feeling, often absorbing the emotional atmosphere around you. Your compassion and imagination are gifts.",
  },

  moon: {
    aries: "Your Moon in Aries means your emotions are direct and fiery. You process feelings quickly and need physical outlets for emotional energy. You feel most secure when you are free to act on your instincts.",
    taurus: "Your Moon in Taurus gives you deep emotional stability. You need comfort, beauty, and routine to feel centered. You process feelings slowly and thoroughly, and your emotional loyalty is unshakeable once given.",
    gemini: "Your Moon in Gemini means you process emotions through language and thought. Talking about your feelings helps you understand them. You need intellectual stimulation to feel emotionally alive.",
    cancer: "Your Moon in Cancer is in its home sign, giving you profound emotional intelligence. You feel everything deeply and have an extraordinary memory for emotional experiences. Your nurturing instinct is powerful.",
    leo: "Your Moon in Leo needs warmth, recognition, and creative expression to feel emotionally fulfilled. You have a generous heart and a natural flair for making others feel special. You need to feel appreciated.",
    virgo: "Your Moon in Virgo processes emotions through analysis and practical action. You show love through acts of service and feel most secure when life is orderly. Be gentle with yourself when things are imperfect.",
    libra: "Your Moon in Libra craves harmony in relationships. You are emotionally attuned to others and feel unsettled by conflict. Your emotional intelligence in social situations is remarkable.",
    scorpio: "Your Moon in Scorpio gives you intense emotional depth. You feel things with your whole being and have powerful intuition about others. Trust takes time for you, but once given, your devotion is absolute.",
    sagittarius: "Your Moon in Sagittarius needs freedom and meaning to feel emotionally whole. You process feelings through philosophy, humor, and adventure. You bounce back from difficulties with genuine optimism.",
    capricorn: "Your Moon in Capricorn processes emotions with quiet dignity. You may appear reserved, but your feelings run deep. You feel most secure when you have structure and are working toward something meaningful.",
    aquarius: "Your Moon in Aquarius gives you an unusual emotional makeup. You need space and intellectual engagement to feel centered. You care deeply about humanity while sometimes finding individual emotions puzzling.",
    pisces: "Your Moon in Pisces makes you extraordinarily sensitive and empathic. You absorb the feelings of those around you like a sponge. Your emotional world is rich, dreamy, and sometimes overwhelming in its beauty.",
  },

  mercury: {
    aries: "Mercury in Aries gives you quick, decisive thinking. You speak directly and process information rapidly. Your ideas come in flashes of insight, and you have little patience for drawn-out deliberation.",
    taurus: "Mercury in Taurus gives you methodical, practical thinking. You take your time forming opinions, but once you do, they are well-considered and grounded. Your communication style is calm and reassuring.",
    gemini: "Mercury in Gemini is in its home sign, making you brilliantly versatile in thought and speech. You pick up new information effortlessly and can discuss almost anything with almost anyone.",
    cancer: "Mercury in Cancer means your thinking is colored by emotion and intuition. You have excellent emotional memory and communicate with empathy. You think best when you feel safe.",
    leo: "Mercury in Leo gives your communication warmth and dramatic flair. You think in big pictures and express ideas with confidence. You have a gift for storytelling and inspiring others.",
    virgo: "Mercury in Virgo is in its home sign, giving you a precise, analytical mind. You notice details others miss and communicate with clarity. Your thinking is practical and solution-oriented.",
    libra: "Mercury in Libra gives you a diplomatic mind. You naturally consider all sides of an issue and communicate with grace. You think best in dialogue and partnership.",
    scorpio: "Mercury in Scorpio gives you penetrating insight. You see beneath the surface of things and ask the questions others avoid. Your mind is investigative and nothing superficial satisfies you.",
    sagittarius: "Mercury in Sagittarius gives you expansive, philosophical thinking. You are drawn to big ideas and broad perspectives. You communicate with enthusiasm and humor.",
    capricorn: "Mercury in Capricorn gives you structured, strategic thinking. You are practical in your communication and think in terms of long-term outcomes. Your mind is disciplined and thorough.",
    aquarius: "Mercury in Aquarius gives you innovative, unconventional thinking. You see patterns and possibilities that others miss. Your mind works in original ways and you value intellectual freedom.",
    pisces: "Mercury in Pisces gives you intuitive, imaginative thinking. You understand things through feeling and metaphor. Your communication style is gentle and often poetic.",
  },

  venus: {
    aries: "Venus in Aries loves boldly and pursues what the heart wants without hesitation. You are attracted to passion, honesty, and independence in relationships. You need a partner who matches your fire.",
    taurus: "Venus in Taurus is in its home sign, giving you a deep, sensual approach to love. You value loyalty, physical affection, and shared comforts. Your love is steady, devoted, and enduring.",
    gemini: "Venus in Gemini loves through conversation and intellectual connection. You are attracted to wit and versatility. You need mental stimulation and variety to stay engaged in relationships.",
    cancer: "Venus in Cancer loves with protective tenderness. You are attracted to emotional depth and domestic warmth. You need to feel emotionally safe before you can fully open your heart.",
    leo: "Venus in Leo loves with grand, generous gestures. You are attracted to confidence and warmth. You need to feel adored and you return that adoration tenfold. Your love is theatrical in the best way.",
    virgo: "Venus in Virgo shows love through thoughtful acts of care. You are attracted to intelligence and humility. You express affection by paying attention to what someone actually needs.",
    libra: "Venus in Libra is in its home sign, giving you a natural gift for partnership. You are attracted to beauty, grace, and fairness. You create harmony in relationships and value genuine connection.",
    scorpio: "Venus in Scorpio loves with total intensity. You are attracted to depth, mystery, and emotional honesty. Surface connections do not interest you. When you love, you love completely.",
    sagittarius: "Venus in Sagittarius loves with optimism and openness. You are attracted to adventure, humor, and philosophical depth. You need a partner who shares your love of exploration.",
    capricorn: "Venus in Capricorn loves with quiet devotion and long-term commitment. You are attracted to ambition, integrity, and maturity. You show love through reliability and building something together.",
    aquarius: "Venus in Aquarius loves with respect for individuality. You are attracted to uniqueness and intellectual depth. You need freedom within relationships and value friendship as the foundation of love.",
    pisces: "Venus in Pisces loves with extraordinary compassion and romantic idealism. You are attracted to sensitivity and creative souls. Your love is selfless, dreamy, and deeply healing.",
  },

  mars: {
    aries: "Mars in Aries is in its home sign, giving you powerful drive and physical energy. You act decisively and compete honestly. Your anger flares quickly but passes just as fast. You thrive on challenge.",
    taurus: "Mars in Taurus gives you steady, persistent energy. You pursue goals with quiet determination and do not give up easily. Your strength lies in endurance rather than speed.",
    gemini: "Mars in Gemini channels energy into communication and mental activity. You pursue multiple interests at once and fight with words rather than fists. Your mind is your sharpest tool.",
    cancer: "Mars in Cancer channels energy through emotional conviction. You fight fiercely for those you love and for your sense of home and security. Your protectiveness is a form of strength.",
    leo: "Mars in Leo gives you confident, creative energy. You pursue goals with dramatic flair and natural leadership. You are motivated by pride and the desire to create something meaningful.",
    virgo: "Mars in Virgo channels energy into precise, productive work. You pursue goals methodically and take satisfaction in doing things well. Your drive is expressed through competence and service.",
    libra: "Mars in Libra channels energy into creating fairness and harmony. You fight for justice and balance. You are motivated by partnership and may do your best work in collaboration.",
    scorpio: "Mars in Scorpio gives you intense, focused willpower. You pursue goals with unwavering determination and strategic thinking. Your emotional depth fuels your drive. You do not do anything halfway.",
    sagittarius: "Mars in Sagittarius gives you adventurous, expansive energy. You pursue goals with enthusiasm and optimism. You need a cause or a vision to channel your considerable fire.",
    capricorn: "Mars in Capricorn is exalted, giving you disciplined, ambitious drive. You pursue long-term goals with patience and strategy. Your energy is best used building something enduring.",
    aquarius: "Mars in Aquarius channels energy into innovation and collective causes. You pursue goals in unconventional ways and are motivated by progress. Your drive is fueled by vision.",
    pisces: "Mars in Pisces channels energy through compassion and imagination. You pursue goals intuitively rather than forcefully. Your strength lies in your ability to adapt and flow with circumstances.",
  },
};

// --- Transit Interpretations ---
// Keys: `${transitingBody}_${natalBody}_${aspectType}`
// Falls back to generic patterns when specific combo unavailable.

const TRANSIT_TEXTS = {
  // Sun transits to natal Sun
  sun_sun_conjunction: "The Sun returns to its natal position, marking a personal new year. This is a time for setting intentions and reconnecting with your core identity. What do you want to grow toward this year?",
  sun_sun_opposition: "The Sun opposes your natal Sun, illuminating the balance between self and other. This is a time for honest reflection on how well your outer life matches your inner truth.",
  sun_sun_square: "The Sun squares your natal Sun, creating productive tension. This friction is purposeful, pushing you to adjust course or recommit to what truly matters.",
  sun_sun_trine: "The Sun trines your natal Sun, bringing a period of easy flow and alignment. Your energy and confidence are naturally heightened. This is a good time to take initiative on personal projects.",
  sun_sun_sextile: "The Sun sextiles your natal Sun, opening a window of gentle opportunity. Pay attention to invitations and openings that align with your deeper goals.",

  // Sun transits to natal Moon
  sun_moon_conjunction: "The Sun illuminates your emotional world. Feelings that have been running quietly in the background may surface for acknowledgment. Honor what comes up.",
  sun_moon_opposition: "The Sun opposes your natal Moon, highlighting the balance between your public role and private needs. Both deserve attention right now.",
  sun_moon_square: "The Sun squares your natal Moon, creating tension between what you want and what you feel. This discomfort often precedes important emotional clarity.",
  sun_moon_trine: "The Sun trines your natal Moon, harmonizing your will and emotions. You feel centered and emotionally grounded. Relationships flow more easily.",
  sun_moon_sextile: "The Sun sextiles your natal Moon, supporting emotional expression. This is a gentle time to share feelings and nurture important connections.",

  // Jupiter transits
  jupiter_sun_conjunction: "Jupiter conjuncts your natal Sun, amplifying your vitality and opening doors. This is one of the most fortunate transits, bringing expansion and opportunity to your core identity. Trust the growth that comes.",
  jupiter_sun_trine: "Jupiter trines your natal Sun, bringing a period of optimism and natural luck. Opportunities arrive without struggle. This is a time to say yes to expansion.",
  jupiter_sun_square: "Jupiter squares your natal Sun, creating overconfidence or restlessness. Growth is available but requires discernment. Not every opportunity needs to be seized right now.",
  jupiter_moon_conjunction: "Jupiter conjuncts your natal Moon, expanding your emotional world and sense of belonging. Generosity of spirit flows naturally. Home and family matters may blossom.",
  jupiter_venus_conjunction: "Jupiter conjuncts your natal Venus, amplifying love, pleasure, and creative joy. Relationships may deepen or new romantic connections may form. Let yourself enjoy this.",
  jupiter_venus_trine: "Jupiter trines your natal Venus, bringing harmony to relationships and a heightened appreciation for beauty. This is a lovely time for creative pursuits and social connection.",
  jupiter_mars_conjunction: "Jupiter conjuncts your natal Mars, supercharging your ambition and physical energy. You feel capable of taking on the world. Channel this abundant drive into your most important goals.",

  // Saturn transits
  saturn_sun_conjunction: "Saturn conjuncts your natal Sun, a serious and defining transit. This is a time of maturation and taking full responsibility for your life direction. It may feel heavy, but the structures you build now will last.",
  saturn_sun_opposition: "Saturn opposes your natal Sun, bringing a reality check on your goals and identity. External pressures force you to examine what is truly important and release what is not working.",
  saturn_sun_square: "Saturn squares your natal Sun, testing your resolve and discipline. Obstacles are not punishments but invitations to prove your commitment to your path. Persist through this.",
  saturn_moon_conjunction: "Saturn conjuncts your natal Moon, asking you to grow up emotionally. Old patterns of seeking comfort may be disrupted so that healthier foundations can be built.",
  saturn_venus_conjunction: "Saturn conjuncts your natal Venus, bringing seriousness to relationships and values. This transit tests love and asks what is truly worth keeping. Relationships that survive this become stronger.",

  // Uranus transits
  uranus_sun_conjunction: "Uranus conjuncts your natal Sun, a once-in-a-lifetime awakening. Your sense of self is being radically updated. Embrace the changes even when they feel destabilizing; you are becoming more authentically yourself.",
  uranus_moon_conjunction: "Uranus conjuncts your natal Moon, shaking up your emotional foundations. Old securities may feel unstable. This disruption ultimately leads to greater emotional freedom and authenticity.",
  uranus_venus_conjunction: "Uranus conjuncts your natal Venus, electrifying your relationships and values. Sudden attractions, unexpected changes in partnerships, or radical shifts in what you find beautiful are all possible.",

  // Neptune transits
  neptune_sun_conjunction: "Neptune conjuncts your natal Sun, dissolving old identities so something more spiritually authentic can emerge. This is a deeply mystical but sometimes confusing transit. Trust the process of becoming.",
  neptune_moon_conjunction: "Neptune conjuncts your natal Moon, heightening sensitivity and intuition to extraordinary levels. Boundaries may feel thin. Creative and spiritual practices are especially powerful now.",
  neptune_venus_conjunction: "Neptune conjuncts your natal Venus, casting a romantic, dreamy haze over love and beauty. Art and music may feel transcendent. Be mindful of idealizing partners during this enchanting transit.",

  // Pluto transits
  pluto_sun_conjunction: "Pluto conjuncts your natal Sun, the most profound transformation transit. Your identity undergoes a complete metamorphosis. Old versions of yourself must die so the truest version can emerge. This is phoenix energy.",
  pluto_moon_conjunction: "Pluto conjuncts your natal Moon, transforming your emotional life from the roots. Deep psychological material surfaces for healing. This is intense but ultimately liberating.",
  pluto_venus_conjunction: "Pluto conjuncts your natal Venus, bringing obsessive intensity to love and desire. Relationships undergo profound transformation. Power dynamics in partnerships demand honest reckoning.",
};

// --- Generic Transit Fallbacks ---

function genericTransitText(transitingBody, natalBody, aspectType) {
  const bodyNames = {
    sun: 'the Sun', moon: 'the Moon', mercury: 'Mercury', venus: 'Venus',
    mars: 'Mars', jupiter: 'Jupiter', saturn: 'Saturn', uranus: 'Uranus',
    neptune: 'Neptune', pluto: 'Pluto',
  };

  const aspectDescriptions = {
    conjunction: { verb: 'merges with', quality: 'This fusion intensifies and activates the energies involved, marking a significant new beginning in this area of your life.' },
    opposition: { verb: 'opposes', quality: 'This creates awareness through contrast. Something external mirrors back what needs attention in your inner world.' },
    trine: { verb: 'harmonizes with', quality: 'Energy flows easily and supportively. Take advantage of this natural alignment to move things forward.' },
    square: { verb: 'challenges', quality: 'This friction is purposeful, creating the tension needed for real growth. What feels like an obstacle is actually a catalyst.' },
    sextile: { verb: 'supports', quality: 'A gentle opening is available. This is an invitation, not a command. Pay attention to small opportunities that appear.' },
  };

  const transitName = bodyNames[transitingBody] || transitingBody;
  const natalName = bodyNames[natalBody] || natalBody;
  const aspect = aspectDescriptions[aspectType] || aspectDescriptions.conjunction;

  return `${transitName} ${aspect.verb} your natal ${natalName}. ${aspect.quality}`;
}

// --- Retrograde Interpretations ---

const RETROGRADE_TEXTS = {
  mercury: "Mercury retrograde invites you to slow down communication and revisit old plans. Rather than seeing this as disruption, treat it as a pause for reflection. Review, revise, reconnect. The best ideas often come from looking back before moving forward.",
  venus: "Venus retrograde turns your attention inward to questions of love, beauty, and values. Old relationships or feelings may resurface for re-examination. This is a time for honest reflection on what truly fulfills your heart.",
  mars: "Mars retrograde slows your drive and asks you to reconsider your approach to goals and conflict. Frustration may build, but this pause prevents wasted energy. Internalize your fire and refine your strategy.",
  jupiter: "Jupiter retrograde turns expansion inward. Instead of seeking growth externally, reflect on whether the paths you are pursuing align with your deeper beliefs. Wisdom comes from philosophical introspection now.",
  saturn: "Saturn retrograde asks you to review the structures and commitments in your life. Are your responsibilities authentically chosen or inherited? This is a time to rebuild foundations from the inside out.",
  uranus: "Uranus retrograde internalizes the urge for change. Instead of external rebellion, this is a time for inner revolution. Question the assumptions you have never questioned. Freedom begins in the mind.",
  neptune: "Neptune retrograde clarifies the fog. Illusions you have been holding may gently dissolve, revealing what has always been true. Spiritual growth comes through honest seeing rather than beautiful imagining.",
  pluto: "Pluto retrograde takes the transformative process underground. Deep psychological work happens below the surface now. Power dynamics in your life are being renegotiated from the inside.",
};

// --- House Descriptions ---

const HOUSE_DESCRIPTIONS = {
  1: "The First House is the house of self and identity. It represents how you present yourself to the world, your physical body, your first impressions, and your instinctive approach to life. Planets here strongly color your personality.",
  2: "The Second House governs your resources, values, and self-worth. It reflects your relationship with money, possessions, and what you truly value. This house asks: what do you need to feel secure?",
  3: "The Third House rules communication, learning, and immediate environment. It governs siblings, neighbors, short trips, and the everyday exchange of information. This is the house of the curious mind.",
  4: "The Fourth House is the foundation. It governs home, family, roots, and your innermost emotional life. This is the most private part of your chart, representing where you retreat to feel safe.",
  5: "The Fifth House celebrates creativity, joy, romance, and self-expression. It governs children, artistic pursuits, pleasure, and play. This is the house of what makes your heart sing.",
  6: "The Sixth House governs daily routines, health, work, and service. It reflects how you structure your days and care for your body. This is the house of devotion to craft and well-being.",
  7: "The Seventh House is the house of partnership. It governs committed relationships, marriage, business partnerships, and any significant one-on-one bond. This house reveals what you seek in others.",
  8: "The Eighth House governs transformation, shared resources, intimacy, and the mysteries of life and death. It rules deep psychological processes, inheritance, and the merging of lives and finances.",
  9: "The Ninth House rules philosophy, higher education, travel, and the search for meaning. It governs belief systems, ethics, and the expansion of consciousness through experience and study.",
  10: "The Tenth House governs career, public reputation, and your contribution to the world. This is the most visible part of your chart, representing your legacy and how you are known.",
  11: "The Eleventh House rules community, friendship, and collective vision. It governs groups, social causes, hopes, and dreams for the future. This is the house of belonging to something larger.",
  12: "The Twelfth House is the house of the unseen. It governs the unconscious, spiritual life, solitude, and hidden strengths. This is the most mystical part of the chart, where endings become new beginnings.",
};

// --- Compatibility Messages ---

function compatibilityMessage(harmonyScore) {
  if (harmonyScore >= 85) {
    return "A remarkable resonance between these charts. The cosmic threads weave together with unusual harmony. This connection has a quality of recognition, as though these souls have important work to do together.";
  } else if (harmonyScore >= 70) {
    return "These charts share a strong natural affinity. The connection flows with warmth and understanding. Differences exist but they complement rather than clash, creating space for mutual growth.";
  } else if (harmonyScore >= 55) {
    return "A balanced blend of harmony and creative tension. This connection is dynamic and growth-oriented. The friction here is not a problem to solve but an engine for mutual evolution.";
  } else if (harmonyScore >= 40) {
    return "These charts carry significant tension alongside genuine attraction. The challenges here are catalysts for deep personal growth. This connection asks both people to stretch beyond comfort zones.";
  } else {
    return "A highly charged and complex connection. The intensity here can be transformative if both people are willing to do the inner work. This is not an easy bond, but it can be a profound one.";
  }
}

// --- Public Interface ---

const Interpretations = {
  /**
   * Get a transit interpretation.
   * @param {string} transitingBody - e.g. 'jupiter'
   * @param {string} natalBody - e.g. 'sun'
   * @param {string} aspectType - e.g. 'conjunction'
   * @returns {string} Interpretation text
   */
  transitInterpretation(transitingBody, natalBody, aspectType) {
    const key = `${transitingBody}_${natalBody}_${aspectType}`;
    return TRANSIT_TEXTS[key] || genericTransitText(transitingBody, natalBody, aspectType);
  },

  /**
   * Brief description of a zodiac sign.
   * @param {string} sign - e.g. 'sagittarius'
   * @returns {string}
   */
  signDescription(sign) {
    return SIGN_DESCRIPTIONS[sign] || '';
  },

  /**
   * Interpretation of a planet in a sign.
   * @param {string} planet - e.g. 'sun', 'moon', 'mercury', 'venus', 'mars'
   * @param {string} sign - e.g. 'sagittarius'
   * @returns {string}
   */
  planetSignInterpretation(planet, sign) {
    const planetTexts = PLANET_SIGN[planet];
    if (!planetTexts) return '';
    return planetTexts[sign] || '';
  },

  /**
   * What a planet's retrograde means.
   * @param {string} body - e.g. 'mercury'
   * @returns {string}
   */
  retrogradeInterpretation(body) {
    return RETROGRADE_TEXTS[body] || `${body.charAt(0).toUpperCase() + body.slice(1)} is retrograde, inviting you to revisit and reflect on the themes this planet governs in your life.`;
  },

  /**
   * Description of what a house represents.
   * @param {number} houseNumber - 1 through 12
   * @returns {string}
   */
  houseDescription(houseNumber) {
    return HOUSE_DESCRIPTIONS[houseNumber] || '';
  },

  /**
   * Overall compatibility message based on harmony score.
   * @param {number} harmonyScore - 0 to 100
   * @returns {string}
   */
  compatibilityMessage,

  // Expose raw data for advanced use
  SIGN_DESCRIPTIONS,
  PLANET_SIGN,
  TRANSIT_TEXTS,
  RETROGRADE_TEXTS,
  HOUSE_DESCRIPTIONS,
};

export { Interpretations };
export default Interpretations;
