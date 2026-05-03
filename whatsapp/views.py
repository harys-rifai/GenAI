import os
import requests
import json
from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from dotenv import load_dotenv

from langchain_openai import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain
from langchain.prompts import PromptTemplate
from .context_manager import get_project_summary

# Load environment variables from .env
load_dotenv()

# System prompt to give the AI context about the project
PROJECT_CONTEXT = get_project_summary().replace("{", "{{").replace("}", "}}")
OPENCODE_PROMPT = PromptTemplate(
    input_variables=["history", "input"],
    template=f"""You are OpenCode AI Assistant, a specialized AI for reading and understanding the code in this repository.
You help the user with coding tasks, explaining logic, and managing this specific app.

PROJECT CONTEXT:
{PROJECT_CONTEXT}

Current conversation:
{{history}}
User: {{input}}
OpenCode:"""
)

# Initialize LLM lazily to avoid startup crashes if key is missing
def get_llm():
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key or api_key == "your_openai_api_key_here":
        return None
    return ChatOpenAI(model="gpt-3.5-turbo", temperature=0, openai_api_key=api_key)

# Global store for user memories (In-memory, cleared on server restart)
user_memories = {}

@csrf_exempt
def webhook(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            number = data.get("number", "unknown")
            text = data.get("text", "")

            print(f"📩 Received message from {number}: {text}")

            llm = get_llm()
            if not llm:
                error_msg = "❌ Error: OPENAI_API_KEY is not set or invalid in .env"
                print(error_msg)
                return JsonResponse({"error": error_msg}, status=500)

            # Get or create memory for this specific user
            if number not in user_memories:
                user_memories[number] = ConversationBufferMemory()
            
            memory = user_memories[number]
            conversation = ConversationChain(
                llm=llm, 
                memory=memory,
                prompt=OPENCODE_PROMPT
            )

            # Generate reply
            reply = conversation.run(text)
            print(f"🤖 AI Reply to {number}: {reply}")

            # Send reply back to Node.js WhatsApp Gateway
            gateway_url = "http://localhost:3000/send"
            try:
                response = requests.post(gateway_url, json={
                    "number": number,
                    "text": reply
                }, timeout=5)
                print(f"✅ Gateway response: {response.status_code}")
            except Exception as e:
                print(f"⚠️ Failed to send to gateway: {e}")

            return JsonResponse({"status": "success", "reply": reply})
            
        except Exception as e:
            print(f"❌ View error: {str(e)}")
            return JsonResponse({"error": str(e)}, status=500)
            
    if request.method == "GET":
        return render(request, "whatsapp/index.html")

    return JsonResponse({"error": "Invalid request. Please use POST method."}, status=400)

