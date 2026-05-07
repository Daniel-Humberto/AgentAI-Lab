from fastapi import FastAPI
from agent_graph import build_agent_graph

app = FastAPI(title="Agentic Lab API", description="Núcleo A2A, LangGraph, y MCP Orchestration")

graph = build_agent_graph()

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "python-ai-core"}

@app.post("/api/v1/agent")
def run_agent(query: str):
    state = {"input": query, "output": ""}
    result = graph.invoke(state)
    return {"status": "success", "data": result}
