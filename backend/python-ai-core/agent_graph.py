from typing import TypedDict
from langgraph.graph import StateGraph, END

class AgentState(TypedDict):
    input: str
    output: str

def adk_mcp_node(state: AgentState):
    """
    Nodo de procesamiento usando Google ADK (A2UI) y conectando con el servidor MCP de Manufact.
    """
    state["output"] = f"Mock A2A/A2UI Processed: {state['input']} con MCP Manufact."
    return state

def build_agent_graph():
    """
    Construye el grafo LangGraph para orquestación multi-agente.
    """
    workflow = StateGraph(AgentState)
    workflow.add_node("adk_mcp_node", adk_mcp_node)
    workflow.set_entry_point("adk_mcp_node")
    workflow.add_edge("adk_mcp_node", END)
    return workflow.compile()
