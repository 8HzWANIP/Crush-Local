# Multi-Agent Orchestration with Reasoning Models

## Overview

This guide focuses on setting up and using multi-agent workflows with your local models, specifically leveraging **DeepSeek Coder v2 236B** for complex reasoning and agent orchestration despite VRAM constraints.

---

## Table of Contents

1. [Why Multi-Agent?](#why-multi-agent)
2. [Your Hardware Reality](#your-hardware-reality)
3. [Setting Up DeepSeek 236B for Multi-Agent](#setting-up-deepseek-236b-for-multi-agent)
4. [Multi-Agent Architecture Patterns](#multi-agent-architecture-patterns)
5. [Practical Examples](#practical-examples)
6. [Performance Optimization](#performance-optimization)
7. [Alternative Reasoning Models](#alternative-reasoning-models)

---

## Why Multi-Agent?

### Benefits of Multi-Agent Systems

**Single-Agent Limitations:**
- Limited context window
- Single perspective
- Sequential processing
- Quality degrades with complexity

**Multi-Agent Advantages:**
- **Specialization:** Different agents for different tasks
- **Parallel Processing:** Multiple sub-agents work simultaneously
- **Better Quality:** Lead agent synthesizes multiple perspectives
- **Scalability:** Add more agents as needed
- **Complex Reasoning:** Break down hard problems into manageable pieces

### When to Use Multi-Agent

✅ **Good Use Cases:**
- Large codebase analysis (>10k files)
- Architecture design and planning
- Comprehensive security audits
- Migration projects
- Complex refactoring
- Code review of large PRs

❌ **Overkill:**
- Simple code completion
- Single file analysis
- Quick bug fixes
- Straightforward refactors

---

## Your Hardware Reality

### Current Setup

- **RTX 5090:** 32GB VRAM
- **DeepSeek Coder v2 236B Q2:** 80GB model
- **DDR5 RAM:** 6000MHz+ (high bandwidth)

### The Math

```
Model Size:  80GB
VRAM:        32GB
Gap:         48GB (needs to go to RAM)

Solution: GPU/CPU Hybrid Inference
- First ~20-30 layers on GPU (fast)
- Remaining layers on CPU with DDR5 RAM (slower but doable)
```

### Performance Expectations

| Configuration | Response Time | Use Case |
|--------------|--------------|----------|
| **All GPU (30B Q4)** | 1-5 seconds | Real-time coding |
| **All GPU (32B Q6)** | 2-8 seconds | Code review |
| **Hybrid (236B Q2)** | 10-30 seconds | Multi-agent orchestration |
| **Hybrid (236B Q2, long context)** | 30-60 seconds | Complex planning |

**Key Insight:** For multi-agent workflows, a 20-second response from a reasoning model is perfectly acceptable because you're solving complex problems that would take humans hours or days.

---

## Setting Up DeepSeek 236B for Multi-Agent

### LM Studio Configuration

#### Step 1: Load the Model

1. Open LM Studio
2. Navigate to **"My Models"**
3. Find **"DeepSeek-Coder-V2-Instruct-GGUF"** (Q2_K, 80GB)
4. Click **"Load"**

#### Step 2: Configure GPU Offloading

1. Click **"Advanced Settings"** or gear icon
2. **GPU Offload:** Set to ~20-30 layers (not max!)
   - Start with 25 layers
   - This puts ~30-35GB on GPU, rest on RAM
3. **Context Length:** 8192 (balanced)
4. **Batch Size:** 512 (lower for hybrid inference)
5. **Thread Count:** Match physical CPU cores

#### Step 3: Monitor and Adjust

```bash
# Monitor GPU usage
nvidia-smi -l 1

# Look for:
# - GPU Memory: Should be near 32GB (full utilization)
# - GPU Utilization: Should be high when inferring
```

**If too slow:**
- Reduce context length (8192 → 4096)
- Reduce batch size (512 → 256)
- Close other applications

**If out of memory:**
- Reduce GPU layers (25 → 20)
- More will offload to RAM

#### Step 4: Start Server

1. **Local Server** tab
2. Select DeepSeek model
3. **Start Server**
4. Wait for "Server running on port 1234"

### Crush CLI Configuration

**File:** `.crush.json`

```json
{
  "$schema": "https://charm.land/crush.json",
  "providers": {
    "lmstudio-fast": {
      "name": "LM Studio - Fast Models",
      "base_url": "http://localhost:1234/v1/",
      "type": "openai-compat",
      "timeout": 120000,
      "models": [
        {
          "name": "Qwen3 Coder 30B Q4",
          "id": "qwen3-30b-q4",
          "context_window": 32768,
          "default_max_tokens": 4096,
          "description": "Fast sub-agents for specific tasks"
        }
      ]
    },
    "lmstudio-reasoning": {
      "name": "LM Studio - Reasoning (Hybrid)",
      "base_url": "http://localhost:1234/v1/",
      "type": "openai-compat",
      "timeout": 600000,
      "models": [
        {
          "name": "DeepSeek Coder v2 236B",
          "id": "deepseek-coder-v2-236b-q2",
          "context_window": 64000,
          "default_max_tokens": 8000,
          "temperature": 0.8,
          "description": "Lead orchestrator agent with advanced reasoning"
        }
      ]
    }
  },
  "default_provider": "lmstudio-fast"
}
```

**Key Settings:**
- **timeout: 600000** (10 minutes) for DeepSeek - gives enough time for slow inference
- **temperature: 0.8** - slightly higher for creative problem-solving
- **context_window: 64000** - DeepSeek supports very long context

---

## Multi-Agent Architecture Patterns

### Pattern 1: Lead Agent + Specialist Sub-Agents

**Architecture:**
```
┌─────────────────────────────────────────┐
│  Lead Agent (DeepSeek 236B)             │
│  - Understands the big picture          │
│  - Delegates tasks to specialists       │
│  - Synthesizes results                  │
└──────┬──────────────┬──────────────┬────┘
       │              │              │
       ▼              ▼              ▼
┌──────────┐   ┌──────────┐   ┌──────────┐
│ Scanner  │   │ Analyzer │   │ Reviewer │
│ (Qwen30B)│   │ (Qwen30B)│   │ (Qwen30B)│
└──────────┘   └──────────┘   └──────────┘
```

**Workflow:**
1. Lead agent receives complex task
2. Lead agent breaks it into sub-tasks
3. Lead agent creates specific prompts for each sub-agent
4. Sub-agents execute (can run in parallel)
5. Lead agent synthesizes results
6. Lead agent provides final output

**Crush Implementation:**

```bash
# Session 1: Lead Agent (DeepSeek 236B)
crush session create lead-agent --provider lmstudio-reasoning

crush chat --session lead-agent "
I need to analyze this large codebase for a migration from React 16 to React 18.

Please act as lead orchestrator and:
1. Break this into sub-tasks
2. Define specific analysis needed for each sub-task
3. Create detailed prompts for specialist agents
4. Outline how results should be synthesized

Project details: [...]
"

# Wait for response (10-30 seconds)
# Lead agent will define 3-5 sub-tasks with specific prompts

# Session 2-4: Sub-Agents (Qwen 30B - Fast)
crush chat --provider lmstudio-fast "Sub-task 1 prompt from lead agent..."
crush chat --provider lmstudio-fast "Sub-task 2 prompt from lead agent..."
crush chat --provider lmstudio-fast "Sub-task 3 prompt from lead agent..."

# Session 1: Synthesis (Back to DeepSeek)
crush chat --session lead-agent "
Here are the results from specialist agents:

Scanner Agent: [...]
Analyzer Agent: [...]
Reviewer Agent: [...]

Please synthesize these into a comprehensive migration plan.
"
```

### Pattern 2: Iterative Refinement

**Architecture:**
```
┌────────────────┐
│  Lead (DeepSeek│ ──> Initial Plan
└────────┬───────┘
         │
         ▼
┌────────────────┐
│  Critic (Qwen) │ ──> Identifies Issues
└────────┬───────┘
         │
         ▼
┌────────────────┐
│  Lead (DeepSeek│ ──> Refined Plan
└────────┬───────┘
         │
         ▼
┌────────────────┐
│  Validator     │ ──> Final Approval
└────────────────┘
```

**Use Cases:**
- Architecture design
- Complex refactoring plans
- API design
- Database schema design

### Pattern 3: Parallel Agents + Aggregator

**Architecture:**
```
                ┌─────────────────┐
                │  Task Splitter  │
                │   (DeepSeek)    │
                └────────┬────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
  ┌──────────┐     ┌──────────┐     ┌──────────┐
  │ Agent 1  │     │ Agent 2  │     │ Agent 3  │
  │ (Qwen)   │     │ (Qwen)   │     │ (Qwen)   │
  └────┬─────┘     └────┬─────┘     └────┬─────┘
       │                │                │
       └────────────────┼────────────────┘
                        ▼
                ┌─────────────────┐
                │   Aggregator    │
                │   (DeepSeek)    │
                └─────────────────┘
```

**Use Cases:**
- Large codebase scanning
- Security audit
- Dependency analysis
- Test generation

---

## Practical Examples

### Example 1: Comprehensive Code Review with Multi-Agent

**File:** `scripts/multi-agent-review.sh`

```bash
#!/bin/bash

RESULTS_DIR="multi-agent-review-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESULTS_DIR"

# Step 1: Lead Agent Plans Review
echo "Step 1: Lead agent planning review strategy..."

PLANNING_PROMPT="
Act as lead code review orchestrator for this PR.

PR Diff:
$(git diff main...HEAD)

Create a detailed review plan:
1. Categorize changed files by risk level
2. Define 3-4 specialist review agents needed
3. Create specific prompts for each agent
4. Define synthesis criteria

Output format: Numbered sub-tasks with exact prompts
"

PLAN=$(crush chat --provider lmstudio-reasoning "$PLANNING_PROMPT")
echo "$PLAN" > "$RESULTS_DIR/00-plan.md"

echo "Plan created. Review: $RESULTS_DIR/00-plan.md"
echo ""
read -p "Continue with sub-agents? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Step 2: Execute Sub-Agent Reviews
echo "Step 2: Executing specialist reviews..."

# Extract prompts from plan (simplified - you'd parse this better)
# For demo, we'll run 3 pre-defined agents

# Security Agent
echo "  - Security review..."
SECURITY_PROMPT="Review this PR for security issues only:

$(git diff main...HEAD)

Focus on:
- Input validation
- Authentication/authorization
- SQL injection, XSS, CSRF
- Secrets in code

Provide: Issue, Severity, Location, Fix"

crush chat --provider lmstudio-fast "$SECURITY_PROMPT" > "$RESULTS_DIR/01-security.md"

# Quality Agent
echo "  - Quality review..."
QUALITY_PROMPT="Review this PR for code quality:

$(git diff main...HEAD)

Focus on:
- Code complexity
- Best practices
- Maintainability
- DRY violations

Provide: Issue, Impact, Location, Suggestion"

crush chat --provider lmstudio-fast "$QUALITY_PROMPT" > "$RESULTS_DIR/02-quality.md"

# Performance Agent
echo "  - Performance review..."
PERF_PROMPT="Review this PR for performance:

$(git diff main...HEAD)

Focus on:
- Algorithmic efficiency
- Database queries
- Memory usage
- Caching opportunities

Provide: Issue, Impact, Location, Optimization"

crush chat --provider lmstudio-fast "$PERF_PROMPT" > "$RESULTS_DIR/03-performance.md"

# Step 3: Synthesis
echo "Step 3: Synthesizing results..."

SYNTHESIS_PROMPT="Synthesize these specialist reviews into final recommendation:

## Security Review
$(cat "$RESULTS_DIR/01-security.md")

## Quality Review
$(cat "$RESULTS_DIR/02-quality.md")

## Performance Review
$(cat "$RESULTS_DIR/03-performance.md")

Provide:
1. Overall Recommendation: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
2. Critical issues (must fix)
3. Important issues (should fix)
4. Minor issues (nice to have)
5. Positive highlights
6. Estimated time to address

Format as comprehensive PR review comment."

crush chat --provider lmstudio-reasoning "$SYNTHESIS_PROMPT" > "$RESULTS_DIR/04-final-review.md"

echo ""
echo "✓ Multi-agent review complete!"
echo "Results: $RESULTS_DIR"
echo ""
echo "Final review:"
cat "$RESULTS_DIR/04-final-review.md"
```

**Usage:**
```bash
chmod +x scripts/multi-agent-review.sh
./scripts/multi-agent-review.sh
```

**Expected Timeline:**
- Planning: 20 seconds (DeepSeek)
- Security review: 5 seconds (Qwen)
- Quality review: 5 seconds (Qwen)
- Performance review: 5 seconds (Qwen)
- Synthesis: 25 seconds (DeepSeek)
- **Total:** ~60 seconds for comprehensive multi-perspective review

### Example 2: Architecture Design Session

**Prompt for DeepSeek 236B:**

```
You are a lead software architect. Design a scalable architecture for:

PROJECT: E-commerce platform
REQUIREMENTS:
- 100k daily active users
- Product catalog (50k items)
- Real-time inventory
- Payment processing
- User authentication
- Admin dashboard

CONSTRAINTS:
- Budget: $5k/month AWS
- Team: 5 developers
- Timeline: 6 months
- Must be cloud-native

TASK:
Act as architecture lead. Create:
1. High-level architecture (3 options)
2. For each option, delegate detailed analysis to specialist agents:
   - Database Design Agent
   - API Design Agent
   - Security Architecture Agent
   - Scalability Agent

Provide specific prompts for each specialist agent. After they report back, you'll synthesize into final recommendation.
```

**This leverages DeepSeek's reasoning to:**
- Consider trade-offs
- Create coherent plan
- Delegate effectively
- Synthesize specialist feedback

### Example 3: Legacy Code Modernization

**Workflow:**

1. **DeepSeek (Lead):** Analyzes old codebase, creates modernization strategy
2. **Qwen (Analyzer):** Identifies deprecated APIs and patterns
3. **Qwen (Migrator):** Creates migration scripts for each file
4. **Qwen (Tester):** Generates test cases for validation
5. **DeepSeek (Lead):** Reviews all outputs, creates phased rollout plan

---

## Performance Optimization

### Maximizing DeepSeek 236B Performance

#### 1. LM Studio Settings

**GPU Layers:**
- Start: 25 layers
- If OOM: Reduce to 20
- If very slow: Increase to 30 (if memory allows)

**Context Management:**
- Use 8k context for planning
- Use 16k-32k only when really needed
- Longer context = slower inference

**Batch Size:**
- 512 for hybrid inference
- 256 if very slow
- Don't go above 1024

#### 2. Prompt Engineering

**Bad (Slow):**
```
Analyze this entire codebase [100 files pasted]
```

**Good (Fast):**
```
As lead agent, create analysis plan for codebase with:
- 50 Python files
- 30 JavaScript files
- 20 config files

Define what specialist agents should analyze, don't analyze yourself.
```

#### 3. Caching Strategies

**System Prompt Caching:**
```
# Define role once, reuse across session
SYSTEM_PROMPT="You are a lead software architect with 20 years experience..."

# All subsequent prompts reuse this
crush chat --session arch-session --system "$SYSTEM_PROMPT" "Task 1..."
crush chat --session arch-session "Task 2..."  # Reuses system prompt
```

#### 4. Parallel Sub-Agents

**Sequential (Slow):**
```bash
result1=$(crush chat "Task 1...")
result2=$(crush chat "Task 2...")
result3=$(crush chat "Task 3...")
```

**Parallel (Fast):**
```bash
crush chat "Task 1..." > /tmp/result1 &
PID1=$!

crush chat "Task 2..." > /tmp/result2 &
PID2=$!

crush chat "Task 3..." > /tmp/result3 &
PID3=$!

wait $PID1 $PID2 $PID3

result1=$(cat /tmp/result1)
result2=$(cat /tmp/result2)
result3=$(cat /tmp/result3)
```

---

## Alternative Reasoning Models

### If DeepSeek 236B is Too Slow

Consider downloading these reasoning-focused models that fit in 32GB:

#### 1. DeepSeek-R1-Distill-Qwen-32B (Recommended)

- **Size:** ~18GB (Q4), ~24GB (Q6)
- **Pros:** Distilled from larger R1 model, good reasoning, fits easily
- **Cons:** Slightly less capable than full 236B
- **Download:** Search "DeepSeek R1 Distill" in LM Studio

```json
{
  "models": [{
    "name": "DeepSeek R1 Distill 32B",
    "id": "deepseek-r1-distill-qwen-32b-q6",
    "context_window": 32768,
    "default_max_tokens": 4096
  }]
}
```

**Performance:** 2-8 seconds per response (much faster!)

#### 2. Qwen2.5-72B-Instruct Q2/Q3

- **Size:** ~28GB (Q2), ~35GB (Q3)
- **Pros:** Large context, good reasoning
- **Cons:** Needs some CPU offload (Q3) or lower quality (Q2)
- **Download:** Search "Qwen2.5-72B" in LM Studio

#### 3. Llama-3.1-70B-Instruct Q2

- **Size:** ~28GB
- **Pros:** Strong general reasoning
- **Cons:** Not specialized for code like DeepSeek
- **Download:** Search "Llama 3.1 70B" in LM Studio

### Comparison Table

| Model | Size (Q4) | Response Time | Reasoning Quality | Code Specialization |
|-------|-----------|--------------|-------------------|---------------------|
| DeepSeek 236B Q2 | 80GB | 10-30s | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| DeepSeek R1 32B Q6 | 24GB | 2-8s | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Qwen2.5-72B Q3 | 35GB | 5-15s | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Qwen2.5-32B Q6 | 25GB | 2-8s | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Llama-3.1-70B Q2 | 28GB | 5-15s | ⭐⭐⭐⭐ | ⭐⭐⭐ |

**Recommendation:**
- **Try first:** DeepSeek 236B Q2 with CPU offload (you have it!)
- **If too slow:** Download DeepSeek R1 Distill 32B Q6
- **Balanced:** Qwen2.5-72B Q3 (some offload, good reasoning)

---

## Best Practices

### 1. Use Lead Agent for Strategy, Sub-Agents for Execution

❌ **Don't:**
```
DeepSeek: Analyze all 1000 files in this repository
```

✅ **Do:**
```
DeepSeek: Create analysis strategy for 1000-file repo. Define prompts for sub-agents.
Qwen: Execute sub-agent analyses (parallel)
DeepSeek: Synthesize results
```

### 2. Parallelize When Possible

Sub-agents can run in parallel because they use Qwen (fast model), not DeepSeek.

### 3. Cache Lead Agent Context

Keep lead agent session open to avoid re-explaining context.

### 4. Start Simple, Scale Up

Begin with 2-agent system (lead + specialist), add more as needed.

### 5. Monitor Performance

```bash
# Watch GPU and RAM usage
watch -n 1 "nvidia-smi && free -h"

# Optimize based on bottleneck:
# - GPU maxed out: Good! Model fully utilizing GPU
# - RAM swap active: Reduce context window
# - Both underutilized: Increase batch size
```

---

## Troubleshooting Multi-Agent Setups

### Issue: DeepSeek Times Out

**Solution:**
- Increase timeout in .crush.json (600000 = 10 minutes)
- Reduce context window
- Simplify prompt (delegate more to sub-agents)

### Issue: Sub-Agents Give Inconsistent Results

**Solution:**
- Lead agent should provide more specific prompts
- Use lower temperature (0.7 instead of 0.9)
- Add examples to sub-agent prompts

### Issue: Synthesis Lacks Coherence

**Solution:**
- Provide lead agent with structured sub-agent outputs
- Use consistent format across sub-agents
- Give lead agent explicit synthesis criteria

---

## Conclusion

Your **DeepSeek Coder v2 236B** is a powerful reasoning model perfect for multi-agent orchestration. Yes, it requires CPU offloading and is slower, but for complex problems requiring multi-agent coordination, the 20-30 second response time is worth it.

**Quick Decision Tree:**

```
Need multi-agent orchestration?
├─ YES
│  ├─ Complex reasoning needed?
│  │  ├─ YES → DeepSeek 236B (lead) + Qwen 30B (sub-agents)
│  │  └─ NO → Qwen 32B Q6 (lead) + Qwen 30B Q4 (sub-agents)
│  └─ Simple delegation?
│     └─ Qwen 32B Q6 for everything
└─ NO
   └─ Single Qwen model (30B or 32B)
```

**Start Here:**
1. Configure DeepSeek 236B with ~25 GPU layers
2. Test with simple multi-agent workflow
3. Adjust GPU layers based on performance
4. Build more complex orchestrations as you learn

---

**Next:** Try the example scripts and experiment with different agent configurations!

*Last Updated: November 2025*
