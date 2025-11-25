Parallel Market Exchange Rate App - AI Agent Specification Document
📋 Product Overview
Product Name: ParaRate Mobile
Target Users: General public (non-technical) in countries with significant parallel market premiums
Core Value Proposition: Instantly see the real street value of currencies vs official bank rates, automatically aggregated from multiple sources with intelligent weighting - with zero setup cost or technical knowledge required
🎯 Key Requirements (Non-Negotiable)
1. Zero User Cost & Complexity
No API keys: User never sees, enters, or pays for any API keys (Groq, scraping services, etc.)
No subscriptions: 100% free forever. Monetization (if any) via non-intrusive ads after 6 months of usage
No manual configuration: App works immediately after download
No technical knowledge: No mentions of "scraping", "servers", "databases", or "weights"
2. Full Automation
Self-initializing: App starts gathering data on first launch without user input
Background updates: Rates update automatically every 4 hours via mobile background fetch
Self-healing: If a data source fails, app automatically tries alternatives and degrades gracefully
Source management: The system (not the user) automatically adds/removes data sources based on reliability
3. Mobile-First Design
Platforms: iOS 15+ and Android 8+ (API level 26)
Offline-first: Last known rates always visible; sync indicator shows data freshness
Minimal permissions: Only internet access (no location, contacts, etc.)
Lightweight: App size < 50MB; data usage < 10MB/month
Battery efficient: Background updates use <1% battery per day
4. Intelligence & Accuracy
Weighted aggregation: Automatically calculates most accurate rate from 2-5 sources per country
Source scoring: Invisible to user; system automatically trusts reliable sources more
Outlier detection: Automatically discards obviously wrong rates (typos, stale data)
Official rate comparison: Shows premium/discount percentage vs official rate
Confidence indicator: Simple visual (green/yellow/red dot) shows data quality
5. Currency Coverage
Primary Countries (must have >80% uptime):
Algeria (DZD): EUR, USD, GBP, CAD
Tunisia (TND): EUR, USD, GBP
Libya (LYD): EUR, USD
Egypt (EGP): EUR, USD, GBP
Nigeria (NGN): USD, EUR
Morocco (MAD): EUR, USD
Secondary Countries (best effort):
Mauritania (MRU), Venezuela (VES), Russia (RUB), Malaysia (MYR), Singapore (SGD), Mali (XOF), Niger (XOF)
🏗️ Technical Architecture Specification
System Components
Copy
┌─────────────────────────────────────────────────────────────┐
│                    MOBILE APP (User-Facing)                  │
│  (React Native / Flutter - Single Codebase)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────┐    │
│  │   Dashboard  │  │  Rate Cards  │  │   Settings*    │    │
│  └──────────────┘  └──────────────┘  └────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                               │
                               │ HTTPS API Calls
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              CENTRAL AGGREGATION SERVER (Free Tier)          │
│  (CloudFlare Workers + D1 Database + Cron Triggers)         │
│  - 100,000 requests/day free                                │
│  - No server maintenance                                     │
│  - Automatic scaling                                         │
└─────────────────────────────────────────────────────────────┘
                               │
                               │ Web Scraping & AI Extraction
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATA SOURCES (Multi-Source)               │
│  - 12+ currency websites (devisesquare, etc.)               │
│  - Social media APIs (Facebook Graph - free tier)           │
│  - Telegram scraping (MTProto - free)                       │
│  - Official central bank APIs                               │
└─────────────────────────────────────────────────────────────┘
Free Infrastructure Stack (No Cost)
Table
Copy
Component	Service	Free Tier Limit	Why Chosen
Backend Runtime	CloudFlare Workers	100,000 req/day	Serverless, zero maintenance, global CDN
Database	CloudFlare D1	5GB storage, 5M reads/day	SQLite-compatible, edge-located
Scheduler	CloudFlare Cron Triggers	3 cron jobs	Triggers scraping every 4 hours
AI Processing	Self-hosted + DuckDuckGo	Unlimited	Avoid paid APIs; scrape + parse
Mobile Hosting	GitHub Pages / Vercel	Unlimited for static	For landing page & docs
📱 Mobile App Detailed Specifications
UI/UX Requirements
Home Screen (Dashboard)
Copy
┌─────────────────────────────────────────┐
│  ParaRate          🔄 Last: 2h ago     │
│  Refreshing...                         │
├─────────────────────────────────────────┤
│  ALGERIA 🇩🇿        ●●●●● High Conf.   │
│  EUR/DZD: 284.5 (↑53.2%)              │
│  [Buy: 281] [Sell: 287]               │
│                                        │
│  TUNISIA 🇹🇳        ●●●○○ Medium Conf. │
│  EUR/TND: 4.85 (↑47.8%)               │
│  [Buy: 4.80] [Sell: 4.90]             │
│                                        │
│  NIGERIA 🇳🇬        ●●●●● High Conf.   │
│  USD/NGN: 742 (↑60.9%)                │
│  [Buy: 735] [Sell: 749]               │
│                                        │
│  [View All Countries →]               │
└─────────────────────────────────────────┘
Key Elements:
Country flag + name: Clear identification
Confidence dots: 5 dots = quality score (5=excellent, 1=poor)
Rate display: Sell rate large; buy rate small. Always show premium % vs official
Color coding:
Green background: Premium < 20%
Orange: 20-50%
Red: >50%
Last updated: Relative time ("2h ago") with manual refresh button
Country Detail Screen (Tap to Enter)
Copy
┌─────────────────────────────────────────┐
│  ← Algeria 🇩🇿          ●●●●● High     │
├─────────────────────────────────────────┤
│  EUR/DZD                                │
│  ┌──────────────────────────────────┐ │
│  │ Rate: 284.5  Premium: +53.2%     │ │
│  │ [Graph showing last 24h trend]   │ │
│  │                                  │ │
│  │ Sources:                         │ │
│  │ • Devisesquare (weight: 90%)     │ │
│  │ • Facebook Group (weight: 70%)   │ │
│  │ • Telegram Bot (weight: 85%)     │ │
│  └──────────────────────────────────┘ │
│                                        │
│  USD/DZD                                │
│  ┌──────────────────────────────────┐ │
│  │ Rate: 245.0  Premium: +55.1%     │ │
│  │ [Similar graph]                  │ │
│  └──────────────────────────────────┘ │
└─────────────────────────────────────────┘
Note: Source list is collapsible/hidden by default - tapexpands for advanced users
Settings Screen (Minimal)
Copy
┌─────────────────────────────────────────┐
│  ⚙️ Settings                           │
├─────────────────────────────────────────┤
│  [ ] Enable Background Updates         │
│      (Uses ~1% battery per day)       │
│                                        │
│  Update Frequency:                     │
│  ○ Every 2 hours  ● Every 4 hours     │
│  ○ Every 8 hours  ○ Manual only       │
│                                        │
│  [ ] Notify on major changes (>10%)   │
│                                        │
│  About                                 │
│  Version: 1.0.0                       │
│  Data Sources: 12 tracked             │
│  Last server sync: 2h ago             │
│                                        │
│  [Privacy Policy] [Terms of Use]      │
└─────────────────────────────────────────┘
Core Mobile Features
1. Automatic Background Updates (iOS/Android)
JavaScript
Copy
// iOS: BGProcessingTask & BGAppRefreshTask
// Android: WorkManager

Configuration:
- Task: Fetch latest aggregated rates from central server
- Trigger: Every 4 hours IF device is charging OR battery > 30%
- Timeout: 30 seconds per attempt
- Retry: 3 times with exponential backoff
- On success: Update local SQLite DB, send silent push notification to refresh UI
- On failure: Mark data as "stale" (show grey indicator)
2. Offline Mode & Smart Caching
JavaScript
Copy
Storage Strategy:
- SQLite database: stores last 30 days of rates
- Cache headers: API responses cached for 1 hour
- Stale-while-revalidate: Show old data immediately while fetching new
- Data size: ~5KB per country per day = 2MB/month for all countries

Sync Indicators:
- 🟢 Green: Data <4h old
- 🟡 Yellow: Data 4-8h old
- 🔴 Red: Data >8h old
- ⚪ Grey: No internet connection (showing cached data)
3. Intelligent Error Handling (User Sees Nothing Technical)
Copy
APP BEHAVIOR TABLE:

Scenario                          User Sees
─────────────────────────────────────────────────────────────
All sources working              Normal rates with green dot
1 source fails                   No change (system auto-adjusts)
All sources fail for 1 country   "Limited data for Algeria" banner
Internet completely offline      "Offline mode - Last update: 3h ago"
Server down >24h                 "Temporarily unavailable" + cached rates
Rate variance >20% between sources "⚠️ High variance - check local market"
4. Push Notifications for Major Changes
JavaScript
Copy
Trigger: When rate changes >10% vs previous value
Frequency: Max 1 notification per currency pair per day
Content: "Algerian Dinar: EUR rate jumped 12% to 320 DZD. Check the app!"
Delivery: Silent notification (no sound) for <15% change, alert for >15%
🔧 Backend Server Specifications (Central Aggregation)
Design Philosophy
Runs once for all users: Scrape data centrally, not on each device
Cost-free: Use only free tiers without credit cards
No maintenance: Serverless functions, auto-scaling
CloudFlare Workers Implementation
JavaScript
Copy
// worker.js (runs every 4 hours via Cron)
export default {
  async scheduled(event, env, ctx) {
    // 1. SCRAPE PHASE (parallel execution)
    const results = await Promise.all([
      scrapeAlgeria(),    // Devisesquare + Facebook
      scrapeNigeria(),    // NGNRates + NairaRate
      scrapeTunisia(),    // CartesDinars + FB
      // ... other countries
    ]);
    
    // 2. AI EXTRACTION PHASE (if needed)
    const extracted = await Promise.all(
      results.map(r => extractRatesWithFallback(r.html))
    );
    
    // 3. WEIGHTED CALCULATION PHASE
    const weightedRates = calculateWeightedMeans(extracted);
    
    // 4. STORAGE PHASE
    await env.DB.batch([
      // Store raw rates for debugging
      ...weightedRates.map(r => env.DB.prepare(
        "INSERT INTO raw_rates ... VALUES (?, ?, ?)"
      ).bind(r.country, r.currency, JSON.stringify(r.sources))),
      
      // Store final weighted rates
      ...weightedRates.map(r => env.DB.prepare(
        "INSERT INTO weighted_rates (country, pair, buy, sell, premium, ts) VALUES (?, ?, ?, ?, ?, ?)"
      ).bind(r.country, r.pair, r.buy, r.sell, r.premium, new Date()))
    ]);
    
    // 5. PURGE OLD DATA (keep last 7 days)
    await env.DB.prepare("DELETE FROM weighted_rates WHERE ts < ?")
      .bind(new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)).run();
  }
}
Scraping Strategy (No Paid APIs)
For Structured Websites (Primary)
JavaScript
Copy
// Uses Cheerio-like parsing on CloudFlare Workers
function scrapeAlgeria() {
  const html = await fetch('https://devisesquare.com').then(r => r.text());
  
  // Regex + DOM parsing - no AI needed
  const rates = [];
  const pattern = /(EUR|USD|GBP|CAD)\s*:\s*Buy\s*(\d+)\s*Sell\s*(\d+)/gi;
  
  let match;
  while ((match = pattern.exec(html)) !== null) {
    rates.push({
      currency: match[1],
      buy: parseInt(match[2]),
      sell: parseInt(match[3]),
      source: 'devisesquare',
      confidence: 0.9
    });
  }
  
  return rates;
}
For Social Media/Unstructured (Fallback)
JavaScript
Copy
// Uses DuckDuckGo search + regex (no API keys)
async function scrapeFacebookFallback(country) {
  const query = `${country} black market exchange rate ${new Date().toISOString().split('T')[0]}`;
  const searchUrl = `https://duckduckgo.com/html/?q=${encodeURIComponent(query)}`;
  
  const html = await fetch(searchUrl).then(r => r.text());
  
  // Extract numbers from search results snippets
  const patterns = {
    'algeria': /(\d+)\s*DZD\s*(?:pour|for)?\s*(?:1\s*)?(EUR|USD)/gi,
    'nigeria': /₦?\s*(\d+)\s*(?:to|for)?\s*(?:1\s*)?USD/gi
  };
  
  const matches = [...html.matchAll(patterns[country] || patterns.default)];
  return matches.map(m => ({
    rate: parseInt(m[1]),
    currency: m[2],
    source: 'search_fallback',
    confidence: 0.5
  }));
}
AI Extraction (Last Resort)
JavaScript
Copy
// Using HuggingFace Inference API (free, no key for public models)
async function extractWithAI(text, currencyPair) {
  const response = await fetch('https://api-inference.huggingface.co/models/facebook/bart-large-mnli', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      inputs: `Extract the ${currencyPair} exchange rate from: "${text}"`,
      parameters: { candidate_labels: ["contains_rate", "no_rate"] }
    })
  });
  
  // Parse with regex after AI classification
  // This uses <1000 requests/day - well within free tier
  const numbers = text.match(/\d+\.?\d*/g);
  if (!numbers || numbers.length < 2) return null;
  
  return {
    buy: parseFloat(numbers[0]),
    sell: parseFloat(numbers[1]),
    confidence: 0.6
  };
}
Weighted Calculation Algorithm (Backend)
JavaScript
Copy
function calculateWeightedMeans(sources) {
  const grouped = {};
  
  // Group by country & currency
  sources.forEach(source => {
    const key = `${source.country}-${source.currency}`;
    if (!grouped[key]) grouped[key] = [];
    grouped[key].push(source);
  });
  
  return Object.entries(grouped).map(([key, rates]) => {
    const [country, currency] = key.split('-');
    
    // Filter outliers (>1.5 IQR)
    const sells = rates.map(r => r.sell).sort((a, b) => a - b);
    const q1 = sells[Math.floor(sells.length * 0.25)];
    const q3 = sells[Math.floor(sells.length * 0.75)];
    const iqr = q3 - q1;
    const filtered = rates.filter(r => r.sell >= q1 - 1.5*iqr && r.sell <= q3 + 1.5*iqr);
    
    // Calculate weighted average
    const totalWeight = filtered.reduce((sum, r) => sum + r.confidence, 0);
    const weightedSell = filtered.reduce((sum, r) => sum + r.sell * r.confidence, 0) / totalWeight;
    const weightedBuy = filtered.reduce((sum, r) => sum + r.buy * r.confidence, 0) / totalWeight;
    
    // Get official rate (hardcoded, updated manually monthly)
    const officialRates = getOfficialRates(country);
    const official = officialRates[currency] || 1;
    const premium = ((weightedSell - official) / official * 100).toFixed(1);
    
    return {
      country,
      pair: `${currency}/${getCurrencyCode(country)}`,
      buy: Math.round(weightedBuy * 100) / 100,
      sell: Math.round(weightedSell * 100) / 100,
      premium: parseFloat(premium),
      sources: filtered.length,
      timestamp: new Date().toISOString()
    };
  });
}
📱 Mobile App Implementation Guide (for AI Agent)
Framework Choice
JavaScript
Copy
// Use EXPO (React Native) - 100% free, no native code needed
// npx create-expo-app pararate-mobile

Key Libraries:
- @react-navigation/native (navigation)
- @tanstack/react-query (data caching)
- expo-sqlite (local storage)
- expo-background-fetch (4h updates)
- expo-notifications (push alerts)
- react-native-svg (charts)
- axios (API calls)
Folder Structure
Copy
/src
  /api
    rates.js          // API calls to our CloudFlare Worker
  /components
    RateCard.js       // Country card UI
    ConfidenceDots.js // 5-dot indicator
    PremiumBadge.js   // Colored percentage
  /hooks
    useRates.js       // React Query hook with caching
    useBackgroundSync.js // Background update logic
  /screens
    Dashboard.js      // Main screen
    CountryDetail.js  // Detailed view
    Settings.js       // Minimal settings
  /utils
    database.js       // SQLite wrapper
    sync.js           // Background sync logic
    calculations.js   // Premium calculations
  /assets
    flags/            // Country flags (emoji or SVG)
Core Mobile Functions
1. Initial App Launch (First Time)
JavaScript
Copy
// pseudocode for AI agent
async function initializeApp() {
  // Show welcome screen for 2 seconds
  // Immediately try to fetch rates from server
  // If success: Store in SQLite, show dashboard
  // If fail: Show "Welcome! Downloading initial data..." spinner
  //     Retry 3 times, then show "Offline mode" with demo data
  //     Explain: "App will work normally when online"
}
2. Background Sync Implementation
JavaScript
Copy
// iOS: AppDelegate.mm
- (void)application:(UIApplication *)application 
    didReceiveRemoteNotification:(NSDictionary *)userInfo 
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  [RateSyncManager syncInBackgroundWithCompletion:completion];
}

// Android: MainApplication.java
WorkManager.getInstance(this)
  .enqueueUniquePeriodicWork(
    "rateUpdate",
    ExistingPeriodicWorkPolicy.KEEP,
    PeriodicWorkRequest.Builder(RateUpdateWorker.class, 
                                  4, TimeUnit.HOURS)
      .setConstraints(new Constraints.Builder()
        .setRequiredNetworkType(NetworkType.CONNECTED)
        .setRequiresBatteryNotLow(true)
        .build())
      .build()
  );
3. Data Flow (Simplified)
Copy
User Opens App
    ↓
Check SQLite cache (<4h old?)
    ├─ YES → Show cached rates immediately
    └─ NO → Show cached + "Updating..." indicator
            ↓
Call CloudFlare API (https://pararate.workers.dev/rates)
    ↓
Parse JSON response (<5KB)
    ↓
Update SQLite database
    ↓
Refresh UI with smooth animation
    ↓
Update home screen widget (if supported)
📊 Quality & Performance Metrics
Target Metrics (Monitored via Firebase Analytics - Free Tier)
Table
Copy
Metric	Target	Measurement
First Launch Success Rate	>95%	App shows rates within 10s of first open
Background Update Success	>90%	Rate updated within 4h window
Offline Functionality	100%	All features work without internet (with cached data)
Crash Rate	<0.5%	Firebase Crashlytics
App Size	<50MB	Final APK/IPA size
Battery Usage	<1%/day	Background updates only
Data Usage	<10MB/month	Efficient caching, gzip compression
API Response Time	<500ms	Time from request to displayable data
Source Diversity	≥2 per country	Minimum data sources
Intelligence Targets
Outlier Detection: <5% false positive rate (flagging valid rates)
Source Weight Accuracy: Correlation between weight and actual rate accuracy >0.7
Stale Data Detection: 100% detection of sources not updated in 24h
Cross-validation: When ≥3 sources, median variance <3%
🔐 Privacy & Compliance
Data Collected (Minimal)
No personal data: No name, email, phone, location
Anonymous usage: Firebase Analytics tracks only feature usage (opt-in)
Cache data: Exchange rates stored locally only
Network logs: No IP logging on server (CloudFlare privacy mode)
Legal Disclaimers
Not financial advice: "Rates are for informational purposes only"
No transaction facilitation: App does not connect buyers/sellers
Source attribution: "Data aggregated from public sources"
Rate disclaimer: "Parallel market rates fluctuate rapidly and may vary by location"
🚀 Launch Checklist for AI Agent
Phase 1: MVP (Week 1)
[ ] Set up CloudFlare Workers + D1
[ ] Implement scraping for Algeria, Nigeria, Tunisia
[ ] Build weighted calculation algorithm
[ ] Create Expo app skeleton
[ ] Dashboard UI with 3 countries
[ ] SQLite local storage
[ ] Manual refresh button
[ ] Deploy to TestFlight + Internal Test Track
Phase 2: Intelligence (Week 2)
[ ] Add 9 more countries
[ ] Implement confidence scoring
[ ] Add background fetch (iOS)
[ ] Add WorkManager (Android)
[ ] Implement outlier detection
[ ] Build settings screen
[ ] Add push notifications
Phase 3: Polish (Week 3)
[ ] UI/UX animations
[ ] Country flags & icons
[ ] Offline mode banners
[ ] Error state handling
[ ] Onboarding flow (2 slides)
[ ] Privacy policy & terms
[ ] App store listings (descriptions, screenshots)
Phase 4: Launch (Week 4)
[ ] Submit to App Store
[ ] Submit to Google Play
[ ] Create landing page (GitHub Pages)
[ ] Set up Firebase monitoring
[ ] Community testing (Reddit, local forums)
💬 User Communication Examples
Error Messages (User-Friendly)
JavaScript
Copy
// Technical Error → User Message
"TIMEOUT_ERROR" → "Slow connection. Showing last available rates."
"PARSE_ERROR" → "Updating... some sources temporarily unavailable."
"NO_SOURCES" → "No parallel market data found for this country."
"STALE_DATA" → "Rates may be outdated. Connect to internet to refresh."
Onboarding Flow (2 Slides)
Copy
Slide 1:
"Welcome to ParaRate"
"See the real value of currencies in countries with parallel markets"

Slide 2:
"How it works"
"We automatically check 100+ sources every 4 hours and show you the most accurate street rate"

[Get Started] → Dashboard immediately shows data
🎨 Brand & Design Guidelines
Name: ParaRate (short, memorable, descriptive)
Color Palette:
Primary: #2563eb (blue - trust)
Success: #10b981 (green - good rate)
Warning: #f59e0b (orange - caution)
Error: #ef4444 (red - high premium)
Background: #f9fafb (light grey - clean)
Typography: Inter (free, readable)
Icons: Heroicons (free, MIT license)
Flags: Twemoji (free, color emoji flags)
📤 Final Deliverables for AI Agent
The AI agent should produce:
Backend Repository (pararate-server)
CloudFlare Workers code
D1 database schema
Scraping modules for 12 countries
Weighted calculation engine
API endpoints documentation
Mobile App Repository (pararate-mobile)
Expo React Native project
All screens & components
Background sync implementation
SQLite integration
App store ready configs
Deployment Scripts
deploy-server.sh - Deploys to CloudFlare
build-mobile.sh - Builds iOS/Android binaries
setup.sh - One-command dev environment setup
Documentation
README.md (user-facing)
API.md (for developers)
Privacy Policy
Terms of Use
App store copy (descriptions, keywords)
Monitoring Dashboard
Firebase Analytics configuration
Key metrics dashboard
Crash reporting setup
✅ Success Criteria
This project is successful when:
A non-technical user can install from app store and see accurate rates within 15 seconds
Rates update automatically without user intervention every 4 hours
App works offline showing last known rates
Zero crashes in first 1000 sessions
Average premium calculation within 5% of actual local market rate
Less than 1% battery impact per day
User rating >4.5 stars in first 100 reviews