# Weather Service
# Fetches METARs/TAFs from NOAA Aviation Weather Center
# Built by Byte (Backend Agent) - Day 6-7

import aiohttp
from typing import Optional
import logging
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

class WeatherService:
    """Service for fetching aviation weather data"""

    def __init__(self):
        """Initialize weather service"""
        self.base_url = "https://aviationweather.gov/api/data"
        self.cache = {}  # Simple in-memory cache
        self.cache_duration = timedelta(minutes=30)  # Dustin's offline requirement

    async def get_metar(self, airport_code: str) -> Optional[str]:
        """
        Fetch current METAR for an airport

        Args:
            airport_code: ICAO airport code (e.g., KAUS)

        Returns:
            METAR string or None if unavailable
        """
        # Check cache first (30-minute cache for offline support)
        cache_key = f"metar_{airport_code}"
        if cache_key in self.cache:
            cached_data, cached_time = self.cache[cache_key]
            if datetime.now() - cached_time < self.cache_duration:
                logger.info(f"📦 Using cached METAR for {airport_code}")
                return cached_data

        try:
            # Fetch from NOAA API
            url = f"{self.base_url}/metar"
            params = {
                "ids": airport_code,
                "format": "raw",
                "taf": "false",
                "hours": "2"  # Last 2 hours
            }

            async with aiohttp.ClientSession() as session:
                async with session.get(url, params=params, timeout=5) as response:
                    if response.status == 200:
                        metar_text = await response.text()

                        # Parse response (returns raw METAR text)
                        if metar_text and airport_code in metar_text:
                            # Cache the result
                            self.cache[cache_key] = (metar_text.strip(), datetime.now())
                            logger.info(f"✅ Fetched METAR for {airport_code}")
                            return metar_text.strip()
                        else:
                            logger.warning(f"⚠️ No METAR found for {airport_code}")
                            return None
                    else:
                        logger.error(f"❌ METAR fetch failed: HTTP {response.status}")
                        return None

        except aiohttp.ClientError as e:
            logger.error(f"❌ Network error fetching METAR: {str(e)}")
            # Return cached data even if expired (graceful degradation)
            if cache_key in self.cache:
                cached_data, cached_time = self.cache[cache_key]
                age_minutes = int((datetime.now() - cached_time).total_seconds() / 60)
                logger.warning(f"⚠️ Using stale METAR ({age_minutes} min old)")
                return f"{cached_data} [CACHED {age_minutes}m ago]"
            return None

        except Exception as e:
            logger.error(f"❌ Unexpected error fetching METAR: {str(e)}")
            return None

    async def get_taf(self, airport_code: str) -> Optional[str]:
        """
        Fetch Terminal Area Forecast (TAF) for an airport

        Args:
            airport_code: ICAO airport code

        Returns:
            TAF string or None if unavailable
        """
        cache_key = f"taf_{airport_code}"
        if cache_key in self.cache:
            cached_data, cached_time = self.cache[cache_key]
            if datetime.now() - cached_time < self.cache_duration:
                return cached_data

        try:
            url = f"{self.base_url}/taf"
            params = {
                "ids": airport_code,
                "format": "raw"
            }

            async with aiohttp.ClientSession() as session:
                async with session.get(url, params=params, timeout=5) as response:
                    if response.status == 200:
                        taf_text = await response.text()

                        if taf_text and airport_code in taf_text:
                            self.cache[cache_key] = (taf_text.strip(), datetime.now())
                            logger.info(f"✅ Fetched TAF for {airport_code}")
                            return taf_text.strip()
                        else:
                            logger.warning(f"⚠️ No TAF found for {airport_code}")
                            return None
                    else:
                        return None

        except Exception as e:
            logger.error(f"❌ Error fetching TAF: {str(e)}")
            # Graceful degradation
            if cache_key in self.cache:
                cached_data, _ = self.cache[cache_key]
                return f"{cached_data} [CACHED]"
            return None

    def clear_cache(self):
        """Clear weather cache (for testing)"""
        self.cache.clear()
        logger.info("🗑️ Weather cache cleared")
