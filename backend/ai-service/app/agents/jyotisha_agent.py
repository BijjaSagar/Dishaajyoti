"""
Jyotisha (Vedic Astrology) AI Agent
"""

from app.agents.base_agent import BaseAgent


class JyotishaAgent(BaseAgent):
    """AI Agent for Vedic Jyotish / Astrology services"""

    def __init__(self):
        super().__init__(agent_type='jyotisha', namespace='jyotisha')

    def get_system_prompt(self) -> str:
        return """You are an expert Vedic Jyotish (astrologer) with deep knowledge of:
- Vedic astrology principles and classical texts (Brihat Parashara Hora Shastra, Jataka Parijata, etc.)
- Planetary positions, houses, and their significations
- Dasha systems (Vimshottari, Yogini, etc.)
- Yogas and their effects
- Remedial measures and gemstone recommendations
- Marriage compatibility (Ashtakoota Guna Milan)
- Career, health, and relationship analysis
- Muhurta (electional astrology)
- Prashna (horary astrology)

Your role is to provide accurate, insightful readings based on traditional Vedic principles while being compassionate and ethical.

IMPORTANT GUIDELINES:
1. Base your analysis on the knowledge base references provided
2. Be honest about limitations - don't make up information
3. Provide practical, actionable guidance
4. Consider both classical principles and modern context
5. Be sensitive to the querent's situation
6. Suggest remedies when appropriate, but don't be overly prescriptive
7. Always cite traditional sources when making assertions
8. Explain astrological concepts in an understandable way

Remember: You are helping people gain insights into their lives, not making absolute predictions."""

    def get_agent_description(self) -> str:
        return "Vedic Astrology expert providing birth chart analysis, predictions, compatibility readings, and guidance based on traditional Jyotish principles."


    def generate_kundali_report(self, birth_data: dict) -> dict:
        """
        Generate a comprehensive Kundali report

        Args:
            birth_data: Dictionary containing birth details

        Returns:
            Structured report with multiple sections
        """
        sections = []

        # Build detailed report query
        query = f"""Generate a comprehensive Vedic Jyotish report for:
Name: {birth_data.get('full_name', 'N/A')}
Date of Birth: {birth_data.get('date_of_birth', 'N/A')}
Time of Birth: {birth_data.get('time_of_birth', 'N/A')}
Place of Birth: {birth_data.get('place_of_birth', 'N/A')}

The report should include:
1. Planetary positions and their strength
2. Ascendant (Lagna) analysis
3. Important yogas present in the chart
4. Dasha periods and predictions
5. Career and professional life
6. Relationships and marriage
7. Health and well-being
8. Remedial measures and gemstone recommendations
"""

        # Generate comprehensive response
        result = self.generate_response(query, birth_data)

        return {
            'report': {
                'title': f'Vedic Jyotish Report for {birth_data.get("full_name", "Individual")}',
                'sections': [
                    {
                        'title': 'Complete Analysis',
                        'content': result['answer']
                    }
                ]
            },
            'sources': result['sources'],
            'confidence': result['confidence']
        }
