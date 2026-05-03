from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from langchain_openai import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
memory = ConversationBufferMemory()
conversation = ConversationChain(llm=llm, memory=memory)

@csrf_exempt
def webhook(request):
    if request.method == "POST":
        data = json.loads(request.body)
        text = data.get("text", "")

        reply = conversation.run(text)

        return JsonResponse({"reply": reply})
    return JsonResponse({"error": "Invalid request"}, status=400)
