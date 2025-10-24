"""
DishaAjyoti AI Service
Main Flask application for AI-powered astrology, vastu, and related services
"""

import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import logging
from functools import wraps

# Load environment variables
load_dotenv()

# Import our modules
from app.agents.agent_factory import AgentFactory
from app.services.query_service import QueryService
from app.services.report_service import ReportService
from config.logging_config import setup_logging

# Setup logging
setup_logging()
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Configuration
app.config['JSON_AS_ASCII'] = False
app.config['JSON_SORT_KEYS'] = False

# API Key authentication decorator
def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        if api_key != os.getenv('API_KEY'):
            return jsonify({'error': 'Unauthorized', 'message': 'Invalid API key'}), 401
        return f(*args, **kwargs)
    return decorated_function


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'DishaAjyoti AI Service',
        'version': '1.0.0'
    }), 200


@app.route('/api/query', methods=['POST'])
@require_api_key
def query():
    """
    Handle AI query

    Request body:
    {
        "agent_type": "jyotisha",
        "query": "What does my birth chart say about career?",
        "context": {
            "date_of_birth": "1990-05-15",
            "time_of_birth": "14:30",
            "place_of_birth": "New Delhi"
        }
    }
    """
    try:
        data = request.get_json()

        if not data or 'agent_type' not in data or 'query' not in data:
            return jsonify({
                'error': 'Bad Request',
                'message': 'agent_type and query are required'
            }), 400

        agent_type = data['agent_type']
        query_text = data['query']
        context = data.get('context', {})

        logger.info(f"Processing query for agent: {agent_type}")

        # Get the appropriate agent
        agent = AgentFactory.create_agent(agent_type)

        # Process the query
        query_service = QueryService(agent)
        result = query_service.process_query(query_text, context)

        return jsonify(result), 200

    except ValueError as e:
        logger.error(f"Validation error: {str(e)}")
        return jsonify({'error': 'Bad Request', 'message': str(e)}), 400
    except Exception as e:
        logger.error(f"Error processing query: {str(e)}", exc_info=True)
        return jsonify({
            'error': 'Internal Server Error',
            'message': 'Failed to process query'
        }), 500


@app.route('/api/chat', methods=['POST'])
@require_api_key
def chat():
    """
    Handle conversational chat

    Request body:
    {
        "agent_type": "jyotisha",
        "message": "Tell me more about that",
        "history": [
            {"role": "user", "content": "..."},
            {"role": "assistant", "content": "..."}
        ],
        "context": {}
    }
    """
    try:
        data = request.get_json()

        if not data or 'agent_type' not in data or 'message' not in data:
            return jsonify({
                'error': 'Bad Request',
                'message': 'agent_type and message are required'
            }), 400

        agent_type = data['agent_type']
        message = data['message']
        history = data.get('history', [])
        context = data.get('context', {})

        logger.info(f"Processing chat for agent: {agent_type}")

        # Get the appropriate agent
        agent = AgentFactory.create_agent(agent_type)

        # Process the chat
        query_service = QueryService(agent)
        result = query_service.process_chat(message, history, context)

        return jsonify(result), 200

    except ValueError as e:
        logger.error(f"Validation error: {str(e)}")
        return jsonify({'error': 'Bad Request', 'message': str(e)}), 400
    except Exception as e:
        logger.error(f"Error processing chat: {str(e)}", exc_info=True)
        return jsonify({
            'error': 'Internal Server Error',
            'message': 'Failed to process chat'
        }), 500


@app.route('/api/generate-report', methods=['POST'])
@require_api_key
def generate_report():
    """
    Generate a comprehensive report

    Request body:
    {
        "agent_type": "jyotisha",
        "data": {
            "full_name": "John Doe",
            "date_of_birth": "1990-05-15",
            "time_of_birth": "14:30",
            "place_of_birth": "New Delhi"
        }
    }
    """
    try:
        data = request.get_json()

        if not data or 'agent_type' not in data or 'data' not in data:
            return jsonify({
                'error': 'Bad Request',
                'message': 'agent_type and data are required'
            }), 400

        agent_type = data['agent_type']
        report_data = data['data']

        logger.info(f"Generating report for agent: {agent_type}")

        # Get the appropriate agent
        agent = AgentFactory.create_agent(agent_type)

        # Generate the report
        report_service = ReportService(agent)
        result = report_service.generate_report(report_data)

        return jsonify(result), 200

    except ValueError as e:
        logger.error(f"Validation error: {str(e)}")
        return jsonify({'error': 'Bad Request', 'message': str(e)}), 400
    except Exception as e:
        logger.error(f"Error generating report: {str(e)}", exc_info=True)
        return jsonify({
            'error': 'Internal Server Error',
            'message': 'Failed to generate report'
        }), 500


@app.route('/api/agents', methods=['GET'])
@require_api_key
def list_agents():
    """List available AI agents"""
    agents = AgentFactory.list_available_agents()
    return jsonify({'agents': agents}), 200


@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not Found', 'message': 'Endpoint not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    logger.error(f"Internal server error: {str(error)}", exc_info=True)
    return jsonify({'error': 'Internal Server Error'}), 500


if __name__ == '__main__':
    host = os.getenv('HOST', '0.0.0.0')
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'

    logger.info(f"Starting AI Service on {host}:{port}")
    app.run(host=host, port=port, debug=debug)
