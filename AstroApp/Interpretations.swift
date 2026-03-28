import Foundation

// MARK: - Sign Descriptions

enum SignDescriptions {
    static func description(for sign: ZodiacSign) -> String {
        switch sign {
        case .aries:
            "Bold, pioneering, and fiercely independent. You lead with courage and aren't afraid to blaze your own trail. Your fire burns bright with initiative and the drive to start new things."
        case .taurus:
            "Grounded, sensual, and steadfast. You build beautiful things that last and appreciate the finer things in life. Your strength comes from patience and unwavering determination."
        case .gemini:
            "Curious, adaptable, and brilliantly communicative. Your mind moves at lightning speed, connecting dots others miss. You thrive on variety and intellectual stimulation."
        case .cancer:
            "Nurturing, intuitive, and deeply emotional. You create safe spaces for those you love and have an incredible memory for feelings. Your strength lies in your emotional intelligence."
        case .leo:
            "Radiant, generous, and boldly creative. You light up every room you enter and inspire others with your warmth. Your heart is as big as your presence."
        case .virgo:
            "Analytical, devoted, and quietly powerful. You see the details others overlook and work tirelessly to improve everything you touch. Your care shows in your precision."
        case .libra:
            "Harmonious, fair-minded, and naturally elegant. You seek balance in all things and have a gift for bringing people together. Beauty and justice are your guiding stars."
        case .scorpio:
            "Intense, transformative, and deeply perceptive. You see beneath every surface and aren't afraid of the depths. Your power comes from your ability to transform and regenerate."
        case .sagittarius:
            "Adventurous, philosophical, and endlessly optimistic. You're on a quest for truth and meaning, always aiming your arrow higher. Freedom and wisdom are your greatest treasures."
        case .capricorn:
            "Ambitious, disciplined, and quietly powerful. You play the long game and build empires through patience and hard work. Your determination is your superpower."
        case .aquarius:
            "Innovative, humanitarian, and refreshingly original. You see the future before it arrives and work to make the world better for everyone. You're the change you wish to see."
        case .pisces:
            "Compassionate, imaginative, and deeply spiritual. You feel the world on a soul level and channel those feelings into creative magic. Your empathy is boundless."
        }
    }
}

// MARK: - Planet in Sign Interpretations

enum PlanetSignInterpretations {
    static func interpretation(body: CelestialBody, sign: ZodiacSign) -> String {
        switch body {
        case .sun:
            sunIn(sign)
        case .moon:
            moonIn(sign)
        case .mercury:
            mercuryIn(sign)
        case .venus:
            venusIn(sign)
        case .mars:
            marsIn(sign)
        default:
            "\(body.name) in \(sign.name) colors your \(outerPlanetTheme(body)) with \(sign.name) energy."
        }
    }

    private static func outerPlanetTheme(_ body: CelestialBody) -> String {
        switch body {
        case .jupiter: "growth, expansion, and where you find your luck"
        case .saturn: "life lessons, discipline, and long-term commitments"
        case .uranus: "innovation, rebellion, and sudden breakthroughs"
        case .neptune: "dreams, intuition, and spiritual connection"
        case .pluto: "transformation, power, and deep evolution"
        case .northNode: "soul path and life purpose direction"
        default: "experience"
        }
    }

    private static func sunIn(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries: "Your core identity is the trailblazer. You're here to lead, initiate, and show the world what courage looks like."
        case .taurus: "Your core identity is the builder. You're here to create lasting beauty and show the world what devotion looks like."
        case .gemini: "Your core identity is the communicator. You're here to connect ideas and people, bridging worlds with your words."
        case .cancer: "Your core identity is the nurturer. You're here to create emotional safety and show the world what real care looks like."
        case .leo: "Your core identity is the creative force. You're here to shine, inspire, and remind everyone of the power of authentic self-expression."
        case .virgo: "Your core identity is the healer. You're here to refine, improve, and show the world that devotion to craft matters."
        case .libra: "Your core identity is the harmonizer. You're here to create balance, beauty, and meaningful partnerships."
        case .scorpio: "Your core identity is the transformer. You're here to go deep, uncover truth, and show the world what real power looks like."
        case .sagittarius: "Your core identity is the seeker. You're here to expand horizons, share wisdom, and inspire others with your vision."
        case .capricorn: "Your core identity is the architect. You're here to build structures that stand the test of time and lead by example."
        case .aquarius: "Your core identity is the visionary. You're here to innovate, liberate, and show the world what's possible when we think differently."
        case .pisces: "Your core identity is the dreamer. You're here to channel the divine through creativity and show the world what compassion looks like."
        }
    }

    private static func moonIn(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries: "Emotionally, you need action and independence. You process feelings by doing something about them. You recharge through physical activity and taking initiative."
        case .taurus: "Emotionally, you need comfort and stability. You process feelings through your senses \u{2014} good food, soft textures, nature. Security is everything to you."
        case .gemini: "Emotionally, you need to talk it out. You process feelings through conversation and intellectual exploration. Variety keeps your emotional world fresh."
        case .cancer: "Emotionally, you feel everything deeply. Home, family, and close bonds are your sanctuary. You nurture others as a way of processing your own feelings."
        case .leo: "Emotionally, you need to be seen and appreciated. You process feelings through creative expression and generous acts. Recognition fuels your emotional wellbeing."
        case .virgo: "Emotionally, you need order and purpose. You process feelings by analyzing and problem-solving. Being helpful to others grounds your emotional world."
        case .libra: "Emotionally, you need harmony and partnership. You process feelings through relationship and dialogue. Beauty and fairness soothe your soul."
        case .scorpio: "Emotionally, you feel with incredible intensity. You process feelings in private, going deep before surfacing. Transformation is your emotional superpower."
        case .sagittarius: "Emotionally, you need freedom and meaning. You process feelings through adventure and philosophical exploration. Optimism is your emotional anchor."
        case .capricorn: "Emotionally, you need structure and achievement. You process feelings through work and long-term planning. Respect and accomplishment ground you."
        case .aquarius: "Emotionally, you need space and intellectual stimulation. You process feelings by stepping back and analyzing from a distance. Community feeds your soul."
        case .pisces: "Emotionally, you absorb everything around you. You process feelings through creativity, music, and spiritual practice. Boundaries are your biggest growth edge."
        }
    }

    private static func mercuryIn(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries: "Your mind is quick, direct, and pioneering. You think fast, speak boldly, and love a good debate."
        case .taurus: "Your mind is thorough and practical. You think things through carefully and communicate with steady clarity."
        case .gemini: "Your mind is brilliantly versatile. You juggle multiple ideas effortlessly and communicate with sparkling wit."
        case .cancer: "Your mind is intuitive and memory-rich. You think with your feelings and communicate from the heart."
        case .leo: "Your mind is creative and dramatic. You think in grand visions and communicate with warmth and flair."
        case .virgo: "Your mind is precise and analytical. You notice every detail and communicate with clarity and helpfulness."
        case .libra: "Your mind seeks balance and fairness. You weigh every side before speaking and communicate with diplomacy and grace."
        case .scorpio: "Your mind is penetrating and investigative. You see through surface-level talk and communicate with powerful intensity."
        case .sagittarius: "Your mind is expansive and philosophical. You think in big pictures and communicate with enthusiasm and humor."
        case .capricorn: "Your mind is strategic and focused. You think in terms of practical outcomes and communicate with authority."
        case .aquarius: "Your mind is innovative and unconventional. You think ahead of your time and communicate progressive ideas."
        case .pisces: "Your mind is imaginative and intuitive. You think in images and feelings, communicating with poetic sensitivity."
        }
    }

    private static func venusIn(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries: "In love, you're passionate and direct. You fall fast, love boldly, and need a partner who matches your fire."
        case .taurus: "In love, you're devoted and sensual. You show love through comfort, loyalty, and creating beautiful shared experiences."
        case .gemini: "In love, you need mental stimulation. Flirty conversations and shared curiosity keep the spark alive for you."
        case .cancer: "In love, you're nurturing and deeply loyal. You create emotional sanctuaries and love through care and protection."
        case .leo: "In love, you're generous and romantic. You love grand gestures, creative dates, and making your partner feel like royalty."
        case .virgo: "In love, you show devotion through acts of service. You notice what your partner needs before they even ask."
        case .libra: "In love, you're the ultimate romantic. Partnership is your art form, and you create beauty in every relationship."
        case .scorpio: "In love, you go all in. You crave depth, loyalty, and soul-level connection. Half-hearted love isn't in your vocabulary."
        case .sagittarius: "In love, you need adventure and growth. You want a partner who's also your travel buddy and philosophical sparring partner."
        case .capricorn: "In love, you're committed and traditional. You build relationships that last and show love through steady dedication."
        case .aquarius: "In love, you need friendship first. You're attracted to unique souls and need space to be your authentic self."
        case .pisces: "In love, you're dreamy and compassionate. You love on a soul level and see the best in everyone you care about."
        }
    }

    private static func marsIn(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries: "You take action immediately and fearlessly. Your drive is pure fire \u{2014} competitive, pioneering, and unstoppable."
        case .taurus: "You take action slowly but with incredible persistence. Once you start, nothing can stop your momentum."
        case .gemini: "You take action through words and ideas. Your energy is versatile and you can juggle multiple projects at once."
        case .cancer: "You take action to protect what you love. Your drive is fueled by emotional connections and family bonds."
        case .leo: "You take action with dramatic flair. Your energy is creative, confident, and impossible to ignore."
        case .virgo: "You take action methodically and precisely. Your drive comes from wanting to perfect and improve everything."
        case .libra: "You take action through collaboration and strategy. Your energy works best when directed toward fairness and balance."
        case .scorpio: "You take action with laser focus and intensity. Your drive runs deep and your determination is transformative."
        case .sagittarius: "You take action with enthusiasm and vision. Your energy is adventurous, bold, and always aimed at the bigger picture."
        case .capricorn: "You take action with discipline and strategy. Your drive is ambitious, patient, and built for the long haul."
        case .aquarius: "You take action for the collective. Your energy goes toward innovation, progress, and breaking outdated systems."
        case .pisces: "You take action guided by intuition and compassion. Your drive is gentle but carries the force of the ocean."
        }
    }
}

// MARK: - Transit Interpretations

enum TransitInterpretations {
    static func interpret(_ transit: Transit) -> String {
        let transiting = transit.transitingPosition.body
        let natal = transit.natalPosition.body
        let aspect = transit.aspectType

        // Check for specific high-impact combinations first
        if let specific = specificTransit(transiting: transiting, natal: natal, aspect: aspect) {
            return specific
        }

        // Fall back to template-based interpretation
        return templateInterpretation(transit: transit)
    }

    private static func specificTransit(
        transiting: CelestialBody,
        natal: CelestialBody,
        aspect: AspectType
    ) -> String? {
        switch (transiting, natal, aspect) {
        case (.saturn, .sun, .conjunction):
            return "Saturn is sitting right on your Sun \u{2014} this is a defining moment. It might feel heavy, like the universe is asking you to prove what you're made of. But this is where you build something real. Show up for yourself even when it's hard."
        case (.saturn, .sun, .opposition):
            return "Saturn is staring down your Sun from across the sky. Relationships and external pressures are testing your sense of self. Remember: you are not defined by other people's expectations of you."
        case (.saturn, .sun, .square):
            return "Saturn is squaring your Sun \u{2014} friction city. Things feel harder than they should. But this tension is building something in you. The pressure creates diamonds if you don't give up."
        case (.saturn, .moon, .conjunction):
            return "Saturn on your Moon can feel emotionally heavy, like carrying a weight in your chest. It's okay to feel tired. Honor your emotions but don't let them convince you this is permanent."
        case (.jupiter, .sun, .conjunction):
            return "Jupiter is blessing your Sun \u{2014} this is your expansion moment. Doors are opening, confidence is rising, and the universe is giving you a cosmic green light. Say yes to opportunities."
        case (.jupiter, .sun, .trine):
            return "Jupiter is flowing beautiful energy to your Sun. Things feel easier, more optimistic. Trust the good vibes \u{2014} you deserve good things happening for you."
        case (.jupiter, .venus, .conjunction):
            return "Jupiter meets your Venus \u{2014} love and abundance are amplified. This is gorgeous energy for relationships, creativity, and financial blessings. Open your heart wide."
        case (.pluto, .sun, .conjunction):
            return "Pluto on your Sun is a once-in-a-lifetime transformation of who you are at your core. You're being reborn. Let the old version of you go \u{2014} who you're becoming is even more powerful."
        case (.pluto, .sun, .square):
            return "Pluto squaring your Sun brings intense power dynamics to the surface. Something in your life is demanding transformation. Resist the urge to control \u{2014} surrender to the metamorphosis."
        case (.uranus, .sun, .conjunction):
            return "Uranus on your Sun \u{2014} expect the unexpected. Your identity is being shaken up in the best way. Embrace the weird, the new, the things that make you feel most alive."
        case (.neptune, .sun, .conjunction):
            return "Neptune on your Sun dissolves old boundaries of self. You might feel foggy about who you are, but you're actually downloading a new spiritual vision. Trust the process."
        case (.saturn, .venus, .conjunction):
            return "Saturn on your Venus is teaching you about what real love and real value look like. Relationships get real. It might feel restrictive, but you're building love that actually lasts."
        case (.mars, .sun, .conjunction):
            return "Mars is firing up your Sun \u{2014} energy is high, you're feeling bold, and you want to make moves. Channel this into your goals. Just watch the temper \u{2014} this fire needs direction."
        case (.venus, .sun, .conjunction):
            return "Venus gracing your Sun brings a glow to everything. You're magnetic right now. Great energy for love, creativity, and feeling beautiful in your own skin."
        default:
            return nil
        }
    }

    private static func templateInterpretation(transit: Transit) -> String {
        let transiting = transit.transitingPosition.body
        let natal = transit.natalPosition.body
        let aspect = transit.aspectType

        let transitEnergy = transitingBodyEnergy(transiting)
        let natalArea = natalBodyArea(natal)
        let aspectFlow = aspectDescription(aspect)

        return "\(transiting.name) is bringing \(transitEnergy) to your \(natalArea) through a \(aspect.name.lowercased()). \(aspectFlow) This energy is moving through your \(ordinalHouse(transit.houseAffected)) house."
    }

    private static func transitingBodyEnergy(_ body: CelestialBody) -> String {
        switch body {
        case .sun: "vitality and clarity"
        case .moon: "emotional awareness"
        case .mercury: "new ideas and conversations"
        case .venus: "love, beauty, and connection"
        case .mars: "drive, energy, and motivation"
        case .jupiter: "expansion and opportunity"
        case .saturn: "structure, lessons, and discipline"
        case .uranus: "sudden change and innovation"
        case .neptune: "dreams, intuition, and spiritual downloads"
        case .pluto: "deep transformation and power"
        case .northNode: "destined encounters"
        }
    }

    private static func natalBodyArea(_ body: CelestialBody) -> String {
        switch body {
        case .sun: "core identity and life purpose"
        case .moon: "emotional world and inner needs"
        case .mercury: "mind, communication, and daily routines"
        case .venus: "love life, values, and creative expression"
        case .mars: "drive, ambition, and how you take action"
        case .jupiter: "growth path and beliefs"
        case .saturn: "responsibilities and life structures"
        case .uranus: "need for freedom and individuality"
        case .neptune: "spiritual life and creative vision"
        case .pluto: "deepest transformations"
        case .northNode: "soul path"
        }
    }

    private static func aspectDescription(_ type: AspectType) -> String {
        switch type {
        case .conjunction:
            "This is a powerful merging of energies \u{2014} intense and impossible to ignore."
        case .sextile:
            "This is a gentle opportunity knocking. It won't force anything, but if you lean into it, beautiful things can flow."
        case .square:
            "This creates friction that demands growth. It's uncomfortable but it's building something stronger in you."
        case .trine:
            "This is the universe sending you a gift \u{2014} easy, flowing energy that supports you. Lean into it."
        case .opposition:
            "This pulls you between two forces. The key is balance, not choosing sides. Both energies have wisdom for you."
        }
    }

    static func retrogradeInterpretation(_ info: RetrogradeInfo) -> String {
        switch info.body {
        case .mercury:
            "Mercury is retrograde in \(info.sign.name) \u{2014} the classic cosmic slowdown. Miscommunications, tech glitches, and travel delays are possible. Review, revise, and reconnect with old friends. Don't start major new contracts if you can help it."
        case .venus:
            "Venus retrograde in \(info.sign.name) is asking you to reassess what you truly value. Old flames might reappear. This is about getting clear on what real love and real worth look like for you."
        case .mars:
            "Mars retrograde in \(info.sign.name) slows your drive. Frustration might build as plans stall. This is the universe asking you to refine your strategy before charging forward again."
        case .jupiter:
            "Jupiter retrograde in \(info.sign.name) turns your growth inward. External expansion pauses so you can develop inner wisdom. Reflect on your beliefs and what true abundance means to you."
        case .saturn:
            "Saturn retrograde in \(info.sign.name) is a review of your commitments and boundaries. Are the structures you've built actually serving you? Time to reassess what you're responsible for."
        case .uranus:
            "Uranus retrograde in \(info.sign.name) brings internal revolution. The changes happening now are subtle, internal shifts in how you think about freedom and authenticity."
        case .neptune:
            "Neptune retrograde in \(info.sign.name) lifts the fog slightly. Dreams get a reality check, and you may see spiritual or creative situations more clearly now."
        case .pluto:
            "Pluto retrograde in \(info.sign.name) deepens your inner transformation. The power shifts happening now are internal \u{2014} you're processing on a soul level."
        default:
            "\(info.body.name) retrograde in \(info.sign.name) invites you to slow down and review this area of your life."
        }
    }

    private static func ordinalHouse(_ house: Int) -> String {
        switch house {
        case 1: "1st"
        case 2: "2nd"
        case 3: "3rd"
        case 21: "21st"
        case 22: "22nd"
        case 23: "23rd"
        default: "\(house)th"
        }
    }
}

// MARK: - House Descriptions

enum HouseDescriptions {
    static func description(_ house: Int) -> String {
        switch house {
        case 1: "Self, identity, and first impressions"
        case 2: "Money, possessions, and personal values"
        case 3: "Communication, siblings, and local travel"
        case 4: "Home, family, and emotional foundations"
        case 5: "Creativity, romance, and self-expression"
        case 6: "Health, daily routines, and service"
        case 7: "Partnerships, marriage, and close relationships"
        case 8: "Transformation, shared resources, and intimacy"
        case 9: "Higher learning, travel, and philosophy"
        case 10: "Career, reputation, and public image"
        case 11: "Friends, community, and future visions"
        case 12: "Spirituality, solitude, and the subconscious"
        default: ""
        }
    }
}

// MARK: - Compatibility Interpretations

enum CompatibilityInterpretations {
    static func overallMessage(harmony: Double) -> String {
        switch harmony {
        case 80...: "There's a beautiful natural flow between you two. Your energies complement each other in ways that feel almost effortless. This connection has a lot of cosmic support."
        case 60..<80: "You two have a strong connection with a healthy mix of ease and growth. The harmonious aspects keep you bonded while the challenging ones keep things interesting."
        case 40..<60: "Your connection has real depth to it. There's enough harmony to hold you together and enough tension to help you both grow. This is a dynamic that never gets boring."
        case 20..<40: "This connection is intense and growth-oriented. There are real challenges here, but also the potential for profound transformation if you both show up with open hearts."
        default: "This is a connection that will push you both to evolve. The friction here isn't easy, but it's the kind that can forge something powerful if you're both willing to do the work."
        }
    }

    static func aspectMeaning(_ aspect: ChartAspect) -> String {
        let b1 = aspect.body1
        let b2 = aspect.body2

        if (b1 == .sun && b2 == .moon) || (b1 == .moon && b2 == .sun) {
            return aspect.type.isHarmonious
                ? "Your core self and their emotional world are in beautiful sync. There's an intuitive understanding between you."
                : "Your core self and their emotional needs create some tension. This requires conscious understanding from both sides."
        }

        if (b1 == .venus && b2 == .mars) || (b1 == .mars && b2 == .venus) {
            return aspect.type.isHarmonious
                ? "The attraction between you is magnetic. Venus-Mars connections bring romantic chemistry and creative spark."
                : "There's intense attraction here, but it can also bring friction in how you each express desire and affection."
        }

        if b1 == .sun && b2 == .sun {
            return aspect.type.isHarmonious
                ? "Your core identities resonate with each other. You get each other on a fundamental level."
                : "Your core identities challenge each other. This creates growth but requires mutual respect."
        }

        if b1 == .moon && b2 == .moon {
            return aspect.type.isHarmonious
                ? "Your emotional worlds are in harmony. You comfort each other naturally and feel emotionally safe together."
                : "Your emotional needs are quite different. Understanding each other's inner world takes extra effort."
        }

        return "\(b1.name) \(aspect.type.name.lowercased()) \(b2.name) brings \(aspect.type.briefDescription) to this area of your connection."
    }
}
