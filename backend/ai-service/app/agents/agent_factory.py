"""
Agent Factory - Creates appropriate AI agents based on type
"""

import logging
from typing import Dict, Type
from app.agents.base_agent import BaseAgent
from app.agents.jyotisha_agent import JyotishaAgent
from app.agents.vastu_agent import VastuAgent
from app.agents.numerology_agent import NumerologyAgent
from app.agents.palmistry_agent import PalmistryAgent

logger = logging.getLogger(__name__)


class AgentFactory:
    """Factory class for creating AI agents"""

    # Registry of available agents
    _agents: Dict[str, Type[BaseAgent]] = {
        'jyotisha': JyotishaAgent,
        'vastu': VastuAgent,
        'numerology': NumerologyAgent,
        'palmistry': PalmistryAgent,
        # Add more agents as needed
        'gems-stones': JyotishaAgent,  # Can use same agent
        'muhurta': JyotishaAgent,      # Can use same agent
        'prashna': JyotishaAgent,      # Can use same agent
        'remedies': JyotishaAgent,     # Can use same agent
    }

    @classmethod
    def create_agent(cls, agent_type: str) -> BaseAgent:
        """
        Create an agent of the specified type

        Args:
            agent_type: Type of agent to create (jyotisha, vastu, etc.)

        Returns:
            Instance of the appropriate agent

        Raises:
            ValueError: If agent type is not supported
        """
        agent_type = agent_type.lower().strip()

        if agent_type not in cls._agents:
            available = ', '.join(cls._agents.keys())
            raise ValueError(
                f"Agent type '{agent_type}' is not supported. "
                f"Available agents: {available}"
            )

        agent_class = cls._agents[agent_type]
        logger.info(f"Creating agent of type: {agent_type}")

        return agent_class()

    @classmethod
    def list_available_agents(cls) -> list:
        """
        List all available agent types

        Returns:
            List of available agent types with descriptions
        """
        agents_info = []

        # Get unique agent classes
        seen_classes = set()
        for agent_type, agent_class in cls._agents.items():
            if agent_class not in seen_classes:
                seen_classes.add(agent_class)
                try:
                    agent = agent_class()
                    agents_info.append({
                        'type': agent_type,
                        'description': agent.get_agent_description()
                    })
                except Exception as e:
                    logger.error(f"Error getting description for {agent_type}: {str(e)}")

        return agents_info

    @classmethod
    def register_agent(cls, agent_type: str, agent_class: Type[BaseAgent]) -> None:
        """
        Register a new agent type

        Args:
            agent_type: Type identifier for the agent
            agent_class: Agent class to register
        """
        cls._agents[agent_type.lower()] = agent_class
        logger.info(f"Registered new agent type: {agent_type}")
