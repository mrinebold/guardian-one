# OpenAI Service
# GPT-4 integration for AI weather analysis and safety coaching
# Built by Byte (Backend Agent) - Day 6-7
# Requirement: Conservative, safety-first AI recommendations

import os
from openai import AsyncOpenAI
from typing import Dict, Any, Optional
import logging
import json

logger = logging.getLogger(__name__)

class OpenAIService:
    """OpenAI GPT-4 service for aviation coaching"""

    def __init__(self):
        """Initialize OpenAI client"""
        self.api_key = os.getenv("OPENAI_API_KEY")
        if not self.api_key:
            logger.error("❌ OPENAI_API_KEY not set in environment")
            raise ValueError("OPENAI_API_KEY environment variable is required")

        self.client = AsyncOpenAI(api_key=self.api_key)
        self.model = "gpt-4-turbo-preview"  # 128k context, faster responses

        # Aviation safety system prompt (conservative bias)
        self.SAFETY_SYSTEM_PROMPT = """You are Guardian One AI, an aviation safety advisor for general aviation pilots.

**Your Prime Directive**: Safety first. Always.

**Your Role**:
- Analyze weather conditions and provide tactical go/no-go recommendations
- Explain your reasoning (not just "don't fly" but WHY)
- Cite specific weather data, pilot minimums, and safety margins
- When in doubt, recommend the conservative option

**Your Constraints**:
- You are an ADVISOR, not a decision-maker. The pilot-in-command has final authority.
- If data is insufficient or ambiguous, say "Insufficient data - recommend consulting Flight Service"
- NEVER hallucinate weather data. Only use provided METARs/TAFs.
- Consider pilot experience level (low-time pilots = more conservative)
- Factor in aircraft limitations (VFR-only = no IMC, fuel range, etc.)

**Your Output Format for Weather Analysis**:
{
    "recommendation": "GO" | "NO-GO" | "WAIT" | "DIVERT",
    "reasoning": "Detailed explanation with weather citations",
    "weather_summary": "Current conditions in plain English",
    "hazards": ["Low ceilings", "Gusty winds", "Icing potential"],
    "alternatives": ["Wait 2 hours for front to pass", "File IFR with instructor"],
    "confidence": "High" | "Medium" | "Low"
}

**Example Scenarios**:
- METAR shows OVC015 (overcast 1,500 ft) for VFR pilot → "NO-GO: Ceilings below VFR minimums (3,000 AGL for Class E)"
- 15G25KT winds → "CAUTION: Crosswind component may exceed aircraft limits. Check POH."
- Marginal VFR with get-there-itis → "WAIT: Weather improving in 2 hours. Patience saves lives."

**Remember**: You're protecting pilots from themselves. Be conservative but not alarmist. Explain, educate, empower."""

    async def validate_api_key(self) -> bool:
        """Validate OpenAI API key on startup"""
        try:
            # Test API key with minimal request
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": "test"}],
                max_tokens=5
            )
            logger.info("✅ OpenAI API key validated")
            return True
        except Exception as e:
            logger.error(f"❌ OpenAI API key validation failed: {str(e)}")
            return False

    async def analyze_weather_decision(
        self,
        context: Dict[str, Any],
        custom_question: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Analyze weather and provide go/no-go recommendation

        Args:
            context: Weather data, aircraft info, pilot experience
            custom_question: Optional custom question from pilot

        Returns:
            Analysis with recommendation, reasoning, hazards, alternatives
        """
        try:
            # Build user prompt with weather context
            user_prompt = f"""Analyze this flight scenario and provide a safety recommendation:

**Departure Airport**: {context['departure']['airport']}
**Departure METAR**: {context['departure']['metar']}

**Arrival Airport**: {context['arrival']['airport']}
**Arrival METAR**: {context['arrival']['metar']}

**Aircraft**: {context['aircraft']}
**Pilot Experience**: {context['pilot_hours']} hours
**Fuel Remaining**: {context['fuel_remaining']}
"""

            if context.get('current_position'):
                user_prompt += f"\n**Current Position**: {context['current_position']}"

            if custom_question:
                user_prompt += f"\n\n**Pilot Question**: {custom_question}"

            user_prompt += "\n\nProvide your analysis in JSON format as specified in your instructions."

            # Call GPT-4
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.SAFETY_SYSTEM_PROMPT},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.3,  # Lower temperature = more conservative
                max_tokens=1000,
                response_format={"type": "json_object"}  # Force JSON output
            )

            # Parse response
            analysis_json = response.choices[0].message.content
            analysis = json.loads(analysis_json)

            # Log token usage for cost tracking
            logger.info(f"📊 OpenAI tokens used: {response.usage.total_tokens}")

            return analysis

        except json.JSONDecodeError as e:
            logger.error(f"❌ Failed to parse AI response as JSON: {str(e)}")
            # Fallback to safe default
            return {
                "recommendation": "NO-GO",
                "reasoning": "AI analysis failed. Recommend consulting Flight Service before departure.",
                "weather_summary": "Unable to analyze weather data",
                "hazards": ["AI service error"],
                "alternatives": ["Contact Flight Service (1-800-WX-BRIEF)"],
                "confidence": "Low"
            }

        except Exception as e:
            logger.error(f"❌ Weather analysis error: {str(e)}")
            raise

    async def get_coaching_response(
        self,
        user_message: str,
        context: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        General AI coaching chat (non-weather questions)

        Args:
            user_message: User's question
            context: Optional flight context

        Returns:
            AI response text
        """
        try:
            # Build prompt with context
            prompt = user_message
            if context:
                prompt = f"Context: {json.dumps(context)}\n\nQuestion: {user_message}"

            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.SAFETY_SYSTEM_PROMPT},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.5,
                max_tokens=500
            )

            answer = response.choices[0].message.content

            # Log token usage
            logger.info(f"📊 OpenAI tokens used: {response.usage.total_tokens}")

            return answer

        except Exception as e:
            logger.error(f"❌ Coaching chat error: {str(e)}")
            return "I'm experiencing technical difficulties. Please try again in a moment."
