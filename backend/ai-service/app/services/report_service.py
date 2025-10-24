"""
Report Service - Handles comprehensive report generation
"""

import logging
import time
from typing import Dict, Any
from app.agents.base_agent import BaseAgent
from app.agents.jyotisha_agent import JyotishaAgent

logger = logging.getLogger(__name__)


class ReportService:
    """Service for generating comprehensive reports"""

    def __init__(self, agent: BaseAgent):
        """
        Initialize report service

        Args:
            agent: AI agent to use for report generation
        """
        self.agent = agent

    def generate_report(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Generate a comprehensive report

        Args:
            data: Input data for report generation

        Returns:
            Dict containing the generated report
        """
        try:
            start_time = time.time()

            logger.info(f"Generating report for agent: {self.agent.agent_type}")

            # Use specialized report generation if available
            if isinstance(self.agent, JyotishaAgent) and hasattr(self.agent, 'generate_kundali_report'):
                result = self.agent.generate_kundali_report(data)
            else:
                # Generic report generation
                result = self._generate_generic_report(data)

            # Calculate processing time
            processing_time = int((time.time() - start_time) * 1000)  # ms

            result['processing_time_ms'] = processing_time
            result['timestamp'] = time.time()
            result['agent_type'] = self.agent.agent_type

            logger.info(f"Report generated successfully in {processing_time}ms")

            return result

        except Exception as e:
            logger.error(f"Error generating report: {str(e)}", exc_info=True)
            raise

    def _generate_generic_report(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Generate a generic report

        Args:
            data: Input data

        Returns:
            Generated report
        """
        # Build comprehensive query based on agent type
        query = self._build_report_query(data)

        # Generate response
        result = self.agent.generate_response(query, data)

        return {
            'report': {
                'title': f'{self.agent.agent_type.title()} Report',
                'sections': [
                    {
                        'title': 'Analysis',
                        'content': result['answer']
                    }
                ]
            },
            'sources': result['sources'],
            'confidence': result['confidence']
        }

    def _build_report_query(self, data: Dict[str, Any]) -> str:
        """
        Build a comprehensive report query based on agent type

        Args:
            data: Input data

        Returns:
            Query string
        """
        agent_type = self.agent.agent_type

        if agent_type == 'vastu':
            return f"""Generate a comprehensive Vastu report for:
Property Type: {data.get('property_type', 'Residential')}
Location: {data.get('location', 'N/A')}

The report should include:
1. Overall Vastu analysis
2. Directional energies and their impact
3. Room placements and recommendations
4. Vastu doshas (if any) and their effects
5. Remedial measures and corrections
6. Suggestions for improvement
"""

        elif agent_type == 'numerology':
            return f"""Generate a comprehensive Numerology report for:
Name: {data.get('full_name', 'N/A')}
Date of Birth: {data.get('date_of_birth', 'N/A')}

The report should include:
1. Life Path Number analysis
2. Destiny/Expression Number
3. Soul Urge Number
4. Personality Number
5. Personal year cycle
6. Lucky numbers and colors
7. Compatibility insights
8. Recommendations for growth
"""

        elif agent_type == 'palmistry':
            return f"""Generate a comprehensive Palmistry report for:
Name: {data.get('full_name', 'N/A')}
Gender: {data.get('gender', 'N/A')}

The report should include:
1. Analysis of major lines (Life, Head, Heart, Fate)
2. Mounts and their significance
3. Finger characteristics
4. Important markings and their meanings
5. Health indicators
6. Career and financial prospects
7. Relationship patterns
8. Overall personality assessment
"""

        else:
            # Default generic query
            return f"Generate a comprehensive {agent_type} report with all relevant analysis and guidance."
