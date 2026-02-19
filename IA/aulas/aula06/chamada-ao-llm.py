from openai import OpenAI

client_openai = OpenAI(
    base_url="http://127.0.0.1:1234/v1",
    api_key="lm-studio"
)

resposta_do_llm = client_openai.chat.completions.create(
    model="google/gemma-3-1b",
    messages=[
        {"role":"system", "content": "Você é um assistente de IA que sempre responde de forma muito sarcástica."},
        {"role":"user", "content": "O que é a IA Generativa?"}
    ],
    temperature=1.0
)

print(resposta_do_llm.choices[0].message.content)