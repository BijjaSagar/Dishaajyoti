/**
 * Vedic Astrology Calculations Utility
 * Handles astronomical calculations for planetary positions, houses, and nakshatras
 *
 * Requirements: 4.1, 4.2
 */

// Zodiac signs
export const ZODIAC_SIGNS = [
  "Aries",
  "Taurus",
  "Gemini",
  "Cancer",
  "Leo",
  "Virgo",
  "Libra",
  "Scorpio",
  "Sagittarius",
  "Capricorn",
  "Aquarius",
  "Pisces",
];

// Nakshatras (27 lunar mansions)
export const NAKSHATRAS = [
  "Ashwini",
  "Bharani",
  "Krittika",
  "Rohini",
  "Mrigashira",
  "Ardra",
  "Punarvasu",
  "Pushya",
  "Ashlesha",
  "Magha",
  "Purva Phalguni",
  "Uttara Phalguni",
  "Hasta",
  "Chitra",
  "Swati",
  "Vishakha",
  "Anuradha",
  "Jyeshtha",
  "Mula",
  "Purva Ashadha",
  "Uttara Ashadha",
  "Shravana",
  "Dhanishta",
  "Shatabhisha",
  "Purva Bhadrapada",
  "Uttara Bhadrapada",
  "Revati",
];

// Planets
export const PLANETS = [
  "Sun",
  "Moon",
  "Mars",
  "Mercury",
  "Jupiter",
  "Venus",
  "Saturn",
  "Rahu",
  "Ketu",
];

export interface PlanetaryPosition {
  longitude: number;
  sign: string;
  degree: number;
  house: number;
  retrograde: boolean;
}

export interface HouseCusp {
  cusp_degree: number;
  sign: string;
  degree_in_sign: number;
}

export interface NakshatraDetails {
  name: string;
  index: number;
  lord: string;
  deity: string;
  symbol: string;
  start_degree: number;
  end_degree: number;
  sign: string;
  nature: string;
  gana: string;
  quality: string;
}

export interface NakshatraCalculation {
  nakshatra: string;
  index: number;
  pada: number;
  degree_in_nakshatra: number;
  degree_in_pada: number;
  lord: string;
  deity: string;
  symbol: string;
  sign: string;
  nature: string;
  gana: string;
  quality: string;
}

export interface DashaPeriod {
  planet: string;
  start_date: string;
  end_date: string;
  duration_years: number;
  is_balance?: boolean;
}

/**
 * Calculate planetary positions for given date, time, and location
 * TODO: Integrate with Swiss Ephemeris or external API
 */
export function calculatePlanetaryPositions(
  date: string,
  time: string,
  latitude: number,
  longitude: number,
  timezone = "Asia/Kolkata"
): Record<string, PlanetaryPosition> {
  const positions: Record<string, PlanetaryPosition> = {};

  PLANETS.forEach((planet) => {
    const longitudeDeg = Math.floor(Math.random() * 360);
    const signIndex = Math.floor(longitudeDeg / 30);
    const degreeInSign = longitudeDeg % 30;

    positions[planet] = {
      longitude: longitudeDeg,
      sign: ZODIAC_SIGNS[signIndex],
      degree: degreeInSign,
      house: Math.floor(Math.random() * 12) + 1,
      retrograde: planet !== "Sun" && planet !== "Moon" && Math.random() < 0.15,
    };
  });

  return positions;
}

/**
 * Calculate house cusps using Placidus system
 * TODO: Implement proper house calculation
 */
export function calculateHouses(
  date: string,
  time: string,
  latitude: number,
  longitude: number
): Record<number, HouseCusp> {
  const houses: Record<number, HouseCusp> = {};
  const startDegree = Math.floor(Math.random() * 30);

  for (let i = 1; i <= 12; i++) {
    const degree = (startDegree + (i - 1) * 30) % 360;
    const signIndex = Math.floor(degree / 30);

    houses[i] = {
      cusp_degree: degree,
      sign: ZODIAC_SIGNS[signIndex],
      degree_in_sign: degree % 30,
    };
  }

  return houses;
}

/**
 * Get complete nakshatra mapping with all details
 */
export function getNakshatraMapping(): NakshatraDetails[] {
  return [
    {
      name: "Ashwini",
      index: 0,
      lord: "Ketu",
      deity: "Ashwini Kumaras",
      symbol: "Horse Head",
      start_degree: 0,
      end_degree: 13.333333,
      sign: "Aries",
      nature: "Light/Swift",
      gana: "Deva (Divine)",
      quality: "Healing, swift action, beginnings",
    },
    {
      name: "Bharani",
      index: 1,
      lord: "Venus",
      deity: "Yama",
      symbol: "Yoni (Female organ)",
      start_degree: 13.333333,
      end_degree: 26.666667,
      sign: "Aries",
      nature: "Fierce",
      gana: "Manushya (Human)",
      quality: "Transformation, restraint, nurturing",
    },
    {
      name: "Krittika",
      index: 2,
      lord: "Sun",
      deity: "Agni",
      symbol: "Razor/Flame",
      start_degree: 26.666667,
      end_degree: 40,
      sign: "Aries/Taurus",
      nature: "Sharp/Mixed",
      gana: "Rakshasa (Demon)",
      quality: "Cutting, purification, sharpness",
    },
    {
      name: "Rohini",
      index: 3,
      lord: "Moon",
      deity: "Brahma",
      symbol: "Chariot/Cart",
      start_degree: 40,
      end_degree: 53.333333,
      sign: "Taurus",
      nature: "Fixed",
      gana: "Manushya (Human)",
      quality: "Growth, beauty, fertility",
    },
    {
      name: "Mrigashira",
      index: 4,
      lord: "Mars",
      deity: "Soma",
      symbol: "Deer Head",
      start_degree: 53.333333,
      end_degree: 66.666667,
      sign: "Taurus/Gemini",
      nature: "Soft/Tender",
      gana: "Deva (Divine)",
      quality: "Searching, curiosity, gentleness",
    },
    {
      name: "Ardra",
      index: 5,
      lord: "Rahu",
      deity: "Rudra",
      symbol: "Teardrop/Diamond",
      start_degree: 66.666667,
      end_degree: 80,
      sign: "Gemini",
      nature: "Sharp",
      gana: "Manushya (Human)",
      quality: "Destruction, transformation, storms",
    },
    {
      name: "Punarvasu",
      index: 6,
      lord: "Jupiter",
      deity: "Aditi",
      symbol: "Bow and Quiver",
      start_degree: 80,
      end_degree: 93.333333,
      sign: "Gemini/Cancer",
      nature: "Movable",
      gana: "Deva (Divine)",
      quality: "Renewal, return, abundance",
    },
    {
      name: "Pushya",
      index: 7,
      lord: "Saturn",
      deity: "Brihaspati",
      symbol: "Cow Udder/Lotus",
      start_degree: 93.333333,
      end_degree: 106.666667,
      sign: "Cancer",
      nature: "Light",
      gana: "Deva (Divine)",
      quality: "Nourishment, spirituality, auspiciousness",
    },
    {
      name: "Ashlesha",
      index: 8,
      lord: "Mercury",
      deity: "Nagas (Serpents)",
      symbol: "Coiled Serpent",
      start_degree: 106.666667,
      end_degree: 120,
      sign: "Cancer",
      nature: "Sharp",
      gana: "Rakshasa (Demon)",
      quality: "Clinging, wisdom, kundalini",
    },
    {
      name: "Magha",
      index: 9,
      lord: "Ketu",
      deity: "Pitris (Ancestors)",
      symbol: "Royal Throne",
      start_degree: 120,
      end_degree: 133.333333,
      sign: "Leo",
      nature: "Fierce",
      gana: "Rakshasa (Demon)",
      quality: "Authority, tradition, ancestral power",
    },
    {
      name: "Purva Phalguni",
      index: 10,
      lord: "Venus",
      deity: "Bhaga",
      symbol: "Front Legs of Bed",
      start_degree: 133.333333,
      end_degree: 146.666667,
      sign: "Leo",
      nature: "Fierce",
      gana: "Manushya (Human)",
      quality: "Pleasure, creativity, procreation",
    },
    {
      name: "Uttara Phalguni",
      index: 11,
      lord: "Sun",
      deity: "Aryaman",
      symbol: "Back Legs of Bed",
      start_degree: 146.666667,
      end_degree: 160,
      sign: "Leo/Virgo",
      nature: "Fixed",
      gana: "Manushya (Human)",
      quality: "Patronage, friendship, contracts",
    },
    {
      name: "Hasta",
      index: 12,
      lord: "Moon",
      deity: "Savitar",
      symbol: "Hand/Palm",
      start_degree: 160,
      end_degree: 173.333333,
      sign: "Virgo",
      nature: "Light",
      gana: "Deva (Divine)",
      quality: "Skill, craftsmanship, dexterity",
    },
    {
      name: "Chitra",
      index: 13,
      lord: "Mars",
      deity: "Tvashtar",
      symbol: "Bright Jewel/Pearl",
      start_degree: 173.333333,
      end_degree: 186.666667,
      sign: "Virgo/Libra",
      nature: "Soft",
      gana: "Rakshasa (Demon)",
      quality: "Beauty, artistry, illusion",
    },
    {
      name: "Swati",
      index: 14,
      lord: "Rahu",
      deity: "Vayu",
      symbol: "Young Sprout/Coral",
      start_degree: 186.666667,
      end_degree: 200,
      sign: "Libra",
      nature: "Movable",
      gana: "Deva (Divine)",
      quality: "Independence, flexibility, trade",
    },
    {
      name: "Vishakha",
      index: 15,
      lord: "Jupiter",
      deity: "Indra-Agni",
      symbol: "Triumphal Arch",
      start_degree: 200,
      end_degree: 213.333333,
      sign: "Libra/Scorpio",
      nature: "Sharp",
      gana: "Rakshasa (Demon)",
      quality: "Goal-oriented, determination, achievement",
    },
    {
      name: "Anuradha",
      index: 16,
      lord: "Saturn",
      deity: "Mitra",
      symbol: "Lotus/Staff",
      start_degree: 213.333333,
      end_degree: 226.666667,
      sign: "Scorpio",
      nature: "Soft",
      gana: "Deva (Divine)",
      quality: "Friendship, devotion, balance",
    },
    {
      name: "Jyeshtha",
      index: 17,
      lord: "Mercury",
      deity: "Indra",
      symbol: "Circular Amulet/Umbrella",
      start_degree: 226.666667,
      end_degree: 240,
      sign: "Scorpio",
      nature: "Sharp",
      gana: "Rakshasa (Demon)",
      quality: "Seniority, protection, responsibility",
    },
    {
      name: "Mula",
      index: 18,
      lord: "Ketu",
      deity: "Nirriti",
      symbol: "Bundle of Roots",
      start_degree: 240,
      end_degree: 253.333333,
      sign: "Sagittarius",
      nature: "Sharp",
      gana: "Rakshasa (Demon)",
      quality: "Foundation, investigation, destruction",
    },
    {
      name: "Purva Ashadha",
      index: 19,
      lord: "Venus",
      deity: "Apas",
      symbol: "Elephant Tusk/Fan",
      start_degree: 253.333333,
      end_degree: 266.666667,
      sign: "Sagittarius",
      nature: "Fierce",
      gana: "Manushya (Human)",
      quality: "Invincibility, purification, victory",
    },
    {
      name: "Uttara Ashadha",
      index: 20,
      lord: "Sun",
      deity: "Vishvadevas",
      symbol: "Elephant Tusk/Planks",
      start_degree: 266.666667,
      end_degree: 280,
      sign: "Sagittarius/Capricorn",
      nature: "Fixed",
      gana: "Manushya (Human)",
      quality: "Final victory, permanence, leadership",
    },
    {
      name: "Shravana",
      index: 21,
      lord: "Moon",
      deity: "Vishnu",
      symbol: "Three Footprints/Ear",
      start_degree: 280,
      end_degree: 293.333333,
      sign: "Capricorn",
      nature: "Movable",
      gana: "Deva (Divine)",
      quality: "Listening, learning, connection",
    },
    {
      name: "Dhanishta",
      index: 22,
      lord: "Mars",
      deity: "Eight Vasus",
      symbol: "Drum/Flute",
      start_degree: 293.333333,
      end_degree: 306.666667,
      sign: "Capricorn/Aquarius",
      nature: "Movable",
      gana: "Rakshasa (Demon)",
      quality: "Wealth, music, adaptability",
    },
    {
      name: "Shatabhisha",
      index: 23,
      lord: "Rahu",
      deity: "Varuna",
      symbol: "Empty Circle/1000 Flowers",
      start_degree: 306.666667,
      end_degree: 320,
      sign: "Aquarius",
      nature: "Movable",
      gana: "Rakshasa (Demon)",
      quality: "Healing, secrecy, mysticism",
    },
    {
      name: "Purva Bhadrapada",
      index: 24,
      lord: "Jupiter",
      deity: "Aja Ekapada",
      symbol: "Front Legs of Funeral Cot",
      start_degree: 320,
      end_degree: 333.333333,
      sign: "Aquarius/Pisces",
      nature: "Fierce",
      gana: "Manushya (Human)",
      quality: "Transformation, intensity, duality",
    },
    {
      name: "Uttara Bhadrapada",
      index: 25,
      lord: "Saturn",
      deity: "Ahir Budhnya",
      symbol: "Back Legs of Funeral Cot",
      start_degree: 333.333333,
      end_degree: 346.666667,
      sign: "Pisces",
      nature: "Fixed",
      gana: "Manushya (Human)",
      quality: "Depth, wisdom, kundalini",
    },
    {
      name: "Revati",
      index: 26,
      lord: "Mercury",
      deity: "Pushan",
      symbol: "Fish/Drum",
      start_degree: 346.666667,
      end_degree: 360,
      sign: "Pisces",
      nature: "Soft",
      gana: "Deva (Divine)",
      quality: "Nourishment, journey, completion",
    },
  ];
}

/**
 * Calculate nakshatra from planetary longitude
 */
export function calculateNakshatra(longitude: number): NakshatraCalculation {
  let normalizedLong = longitude % 360;
  if (normalizedLong < 0) normalizedLong += 360;

  const nakshatraSpan = 360 / 27;
  const nakshatraIndex = Math.floor(normalizedLong / nakshatraSpan);
  const degreeInNakshatra = normalizedLong % nakshatraSpan;

  const padaSpan = nakshatraSpan / 4;
  const padaIndex = Math.floor(degreeInNakshatra / padaSpan) + 1;
  const degreeInPada = degreeInNakshatra % padaSpan;

  const nakshatraDetails = getNakshatraMapping()[nakshatraIndex];

  return {
    nakshatra: nakshatraDetails.name,
    index: nakshatraIndex,
    pada: padaIndex,
    degree_in_nakshatra: parseFloat(degreeInNakshatra.toFixed(4)),
    degree_in_pada: parseFloat(degreeInPada.toFixed(4)),
    lord: nakshatraDetails.lord,
    deity: nakshatraDetails.deity,
    symbol: nakshatraDetails.symbol,
    sign: nakshatraDetails.sign,
    nature: nakshatraDetails.nature,
    gana: nakshatraDetails.gana,
    quality: nakshatraDetails.quality,
  };
}

/**
 * Calculate nakshatra for all planets
 */
export function calculateAllNakshatras(
  planetaryPositions: Record<string, PlanetaryPosition>
): Record<string, NakshatraCalculation> {
  const allNakshatras: Record<string, NakshatraCalculation> = {};

  Object.entries(planetaryPositions).forEach(([planet, data]) => {
    if (data.longitude !== undefined) {
      allNakshatras[planet] = calculateNakshatra(data.longitude);
    }
  });

  return allNakshatras;
}

/**
 * Get Vimshottari Dasha periods in years
 */
export function getDashaPeriods(): Record<string, number> {
  return {
    Ketu: 7,
    Venus: 20,
    Sun: 6,
    Moon: 10,
    Mars: 7,
    Rahu: 18,
    Jupiter: 16,
    Saturn: 19,
    Mercury: 17,
  };
}

/**
 * Get Vimshottari Dasha sequence
 */
export function getDashaSequence(): string[] {
  return ["Ketu", "Venus", "Sun", "Moon", "Mars", "Rahu", "Jupiter", "Saturn", "Mercury"];
}

/**
 * Calculate Vimshottari Dasha periods (Mahadasha)
 */
export function calculateVimshottariDasha(
  birthDate: string,
  nakshatraData: NakshatraCalculation
): DashaPeriod[] {
  const dashaPeriods = getDashaPeriods();
  const lords = getDashaSequence();
  const birthNakshatraLord = nakshatraData.lord;
  const startIndex = lords.indexOf(birthNakshatraLord);

  const totalNakshatraDegree = 13.333333;
  const degreeCompleted = nakshatraData.degree_in_nakshatra;
  const percentageCompleted = degreeCompleted / totalNakshatraDegree;
  const firstDashaPeriod = dashaPeriods[birthNakshatraLord];
  const balanceYears = firstDashaPeriod * (1 - percentageCompleted);

  const dashas: DashaPeriod[] = [];
  const currentDate = new Date(birthDate);

  const endDate = new Date(currentDate);
  endDate.setDate(endDate.getDate() + Math.floor(balanceYears * 365.25));

  dashas.push({
    planet: birthNakshatraLord,
    start_date: currentDate.toISOString().split("T")[0],
    end_date: endDate.toISOString().split("T")[0],
    duration_years: parseFloat(balanceYears.toFixed(2)),
    is_balance: true,
  });

  let nextDate = new Date(endDate);
  for (let i = 1; i < 9; i++) {
    const lordIndex = (startIndex + i) % 9;
    const lord = lords[lordIndex];
    const period = dashaPeriods[lord];

    const startDate = new Date(nextDate);
    const newEndDate = new Date(nextDate);
    newEndDate.setDate(newEndDate.getDate() + Math.floor(period * 365.25));

    dashas.push({
      planet: lord,
      start_date: startDate.toISOString().split("T")[0],
      end_date: newEndDate.toISOString().split("T")[0],
      duration_years: period,
      is_balance: false,
    });

    nextDate = new Date(newEndDate);
  }

  return dashas;
}

/**
 * Calculate Lagna (Ascendant) sign
 */
export function calculateLagna(houses: Record<number, HouseCusp>): string {
  return houses[1].sign;
}

/**
 * Calculate Moon sign (Rashi)
 */
export function calculateMoonSign(planetaryPositions: Record<string, PlanetaryPosition>): string {
  return planetaryPositions.Moon.sign;
}

/**
 * Calculate Sun sign
 */
export function calculateSunSign(planetaryPositions: Record<string, PlanetaryPosition>): string {
  return planetaryPositions.Sun.sign;
}
