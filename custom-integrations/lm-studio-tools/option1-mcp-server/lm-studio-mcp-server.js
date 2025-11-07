#!/usr/bin/env node

/**
 * LM Studio MCP Server
 *
 * This Model Context Protocol (MCP) server exposes local LM Studio models
 * as tools that can be called by Crush CLI or other MCP clients.
 *
 * Usage:
 *   node lm-studio-mcp-server.js
 *
 * Environment Variables:
 *   LM_STUDIO_BASE_URL - LM Studio API base URL (default: http://localhost:1234/v1)
 *   LM_STUDIO_MODEL - Default model to use (default: auto-detect)
 *   LM_STUDIO_TIMEOUT - Request timeout in ms (default: 60000)
 *   LM_STUDIO_LABEL - Label for tool names (default: "")
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema
} = require('@modelcontextprotocol/sdk/types.js');

// Configuration
const CONFIG = {
  baseUrl: process.env.LM_STUDIO_BASE_URL || 'http://localhost:1234/v1',
  defaultModel: process.env.LM_STUDIO_MODEL || null,
  timeout: parseInt(process.env.LM_STUDIO_TIMEOUT || '60000'),
  label: process.env.LM_STUDIO_LABEL || '',
  enableCache: process.env.LM_STUDIO_ENABLE_CACHE === 'true',
  cacheTTL: parseInt(process.env.LM_STUDIO_CACHE_TTL || '3600'),
};

// Simple in-memory cache
const cache = new Map();

// Helper: Make request to LM Studio
async function callLMStudio(prompt, options = {}) {
  const {
    model = CONFIG.defaultModel,
    maxTokens = 4096,
    temperature = 0.7,
    systemPrompt = null,
  } = options;

  const messages = [];

  if (systemPrompt) {
    messages.push({
      role: 'system',
      content: systemPrompt
    });
  }

  messages.push({
    role: 'user',
    content: prompt
  });

  const response = await fetch(`${CONFIG.baseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: model || undefined,
      messages: messages,
      max_tokens: maxTokens,
      temperature: temperature,
    }),
    signal: AbortSignal.timeout(CONFIG.timeout),
  });

  if (!response.ok) {
    throw new Error(`LM Studio API error: ${response.status} ${response.statusText}`);
  }

  const data = await response.json();
  return data.choices[0].message.content;
}

// Helper: Get available models from LM Studio
async function getAvailableModels() {
  try {
    const response = await fetch(`${CONFIG.baseUrl}/models`, {
      signal: AbortSignal.timeout(5000),
    });

    if (!response.ok) {
      console.error('[LM Studio MCP] Failed to fetch models:', response.statusText);
      return [];
    }

    const data = await response.json();
    return data.data.map(m => m.id);
  } catch (error) {
    console.error('[LM Studio MCP] Error fetching models:', error.message);
    return [];
  }
}

// Helper: Cache key generator
function cacheKey(tool, params) {
  return `${tool}:${JSON.stringify(params)}`;
}

// Helper: Get from cache if enabled and valid
function getCached(key) {
  if (!CONFIG.enableCache) return null;

  const cached = cache.get(key);
  if (!cached) return null;

  const now = Date.now();
  if (now - cached.timestamp > CONFIG.cacheTTL * 1000) {
    cache.delete(key);
    return null;
  }

  return cached.value;
}

// Helper: Set cache
function setCache(key, value) {
  if (!CONFIG.enableCache) return;

  cache.set(key, {
    value,
    timestamp: Date.now()
  });
}

// Tool Definitions
const TOOLS = [
  {
    name: `lm_studio${CONFIG.label ? '_' + CONFIG.label : ''}_analyze`,
    description: 'Analyze code using local LM Studio model (fast, optimized for code analysis)',
    inputSchema: {
      type: 'object',
      properties: {
        code: {
          type: 'string',
          description: 'The code to analyze'
        },
        language: {
          type: 'string',
          description: 'Programming language (e.g., python, javascript, go)'
        },
        focus: {
          type: 'string',
          description: 'Analysis focus: quality, security, performance, or all',
          enum: ['quality', 'security', 'performance', 'all'],
          default: 'all'
        }
      },
      required: ['code', 'language']
    },
    async handler(params) {
      const { code, language, focus = 'all' } = params;

      const focusInstructions = {
        quality: 'code quality, complexity, maintainability, and best practices',
        security: 'security vulnerabilities, input validation, and secure coding practices',
        performance: 'performance bottlenecks, algorithmic efficiency, and optimization opportunities',
        all: 'code quality, security, and performance'
      };

      const systemPrompt = `You are an expert code analyzer specializing in ${language}. Provide detailed, actionable feedback.`;

      const prompt = `Analyze this ${language} code for ${focusInstructions[focus]}:

\`\`\`${language}
${code}
\`\`\`

Provide:
1. Issues found (with severity: CRITICAL, HIGH, MEDIUM, LOW)
2. Specific line references where applicable
3. Recommendations for fixes
4. Overall assessment

Be concise but thorough.`;

      return await callLMStudio(prompt, {
        systemPrompt,
        maxTokens: 3000,
        temperature: 0.3, // Lower for more consistent analysis
      });
    }
  },

  {
    name: `lm_studio${CONFIG.label ? '_' + CONFIG.label : ''}_generate`,
    description: 'Generate code using local LM Studio model (high quality code generation)',
    inputSchema: {
      type: 'object',
      properties: {
        prompt: {
          type: 'string',
          description: 'What code to generate'
        },
        language: {
          type: 'string',
          description: 'Programming language'
        },
        style: {
          type: 'string',
          description: 'Code style preferences (optional)'
        },
        context: {
          type: 'string',
          description: 'Additional context (optional)'
        }
      },
      required: ['prompt', 'language']
    },
    async handler(params) {
      const { prompt: userPrompt, language, style, context } = params;

      const systemPrompt = `You are an expert ${language} developer. Generate clean, well-documented, production-ready code following best practices.`;

      let fullPrompt = `Generate ${language} code for: ${userPrompt}`;

      if (style) {
        fullPrompt += `\n\nCode style requirements: ${style}`;
      }

      if (context) {
        fullPrompt += `\n\nAdditional context: ${context}`;
      }

      fullPrompt += `\n\nRequirements:
- Include clear comments
- Follow ${language} best practices
- Handle edge cases
- Provide usage example if applicable

Output only the code with brief explanation.`;

      return await callLMStudio(fullPrompt, {
        systemPrompt,
        maxTokens: 4096,
        temperature: 0.7,
      });
    }
  },

  {
    name: `lm_studio${CONFIG.label ? '_' + CONFIG.label : ''}_refactor`,
    description: 'Get refactoring suggestions using local LM Studio model',
    inputSchema: {
      type: 'object',
      properties: {
        code: {
          type: 'string',
          description: 'Code to refactor'
        },
        language: {
          type: 'string',
          description: 'Programming language'
        },
        goals: {
          type: 'string',
          description: 'Refactoring goals (e.g., "improve performance", "reduce complexity")'
        },
        constraints: {
          type: 'string',
          description: 'Constraints to maintain (e.g., "preserve API compatibility")'
        }
      },
      required: ['code', 'language']
    },
    async handler(params) {
      const { code, language, goals, constraints } = params;

      const systemPrompt = `You are an expert at refactoring ${language} code. Suggest improvements that maintain correctness while achieving the specified goals.`;

      let prompt = `Refactor this ${language} code:\n\n\`\`\`${language}\n${code}\n\`\`\``;

      if (goals) {
        prompt += `\n\nGoals: ${goals}`;
      }

      if (constraints) {
        prompt += `\n\nConstraints: ${constraints}`;
      }

      prompt += `\n\nProvide:
1. Refactored code
2. Explanation of changes
3. Benefits achieved
4. Any trade-offs

Ensure functional equivalence unless explicitly requested otherwise.`;

      return await callLMStudio(prompt, {
        systemPrompt,
        maxTokens: 4096,
        temperature: 0.5,
      });
    }
  },

  {
    name: `lm_studio${CONFIG.label ? '_' + CONFIG.label : ''}_plan`,
    description: 'Create architecture/design plans using local LM Studio model (reasoning-focused)',
    inputSchema: {
      type: 'object',
      properties: {
        requirements: {
          type: 'string',
          description: 'Project or feature requirements'
        },
        constraints: {
          type: 'string',
          description: 'Technical constraints (budget, team size, timeline, etc.)'
        },
        output_format: {
          type: 'string',
          description: 'Desired output format (markdown, json, etc.)',
          default: 'markdown'
        }
      },
      required: ['requirements']
    },
    async handler(params) {
      const { requirements, constraints, output_format = 'markdown' } = params;

      const systemPrompt = `You are a senior software architect. Create detailed, practical plans that balance technical excellence with real-world constraints.`;

      let prompt = `Create a detailed technical plan for:\n\n${requirements}`;

      if (constraints) {
        prompt += `\n\nConstraints:\n${constraints}`;
      }

      prompt += `\n\nProvide:
1. High-level architecture
2. Component breakdown
3. Technology stack recommendations
4. Implementation phases
5. Risks and mitigation strategies
6. Success metrics

Output format: ${output_format}`;

      return await callLMStudio(prompt, {
        systemPrompt,
        maxTokens: 8000,
        temperature: 0.8, // Higher for creative planning
      });
    }
  },

  {
    name: `lm_studio${CONFIG.label ? '_' + CONFIG.label : ''}_custom`,
    description: 'Send custom prompt to local LM Studio model with full control',
    inputSchema: {
      type: 'object',
      properties: {
        prompt: {
          type: 'string',
          description: 'The prompt to send to the model'
        },
        system_prompt: {
          type: 'string',
          description: 'System prompt (optional)'
        },
        model: {
          type: 'string',
          description: 'Specific model ID to use (optional, uses default if not specified)'
        },
        max_tokens: {
          type: 'number',
          description: 'Maximum tokens in response (default: 4096)',
          default: 4096
        },
        temperature: {
          type: 'number',
          description: 'Temperature (0.0-1.0, default: 0.7)',
          default: 0.7,
          minimum: 0.0,
          maximum: 1.0
        }
      },
      required: ['prompt']
    },
    async handler(params) {
      const {
        prompt,
        system_prompt,
        model,
        max_tokens = 4096,
        temperature = 0.7
      } = params;

      return await callLMStudio(prompt, {
        systemPrompt: system_prompt,
        model,
        maxTokens: max_tokens,
        temperature,
      });
    }
  },
];

// MCP Server Implementation
async function main() {
  console.error('[LM Studio MCP] Starting server...');
  console.error(`[LM Studio MCP] Base URL: ${CONFIG.baseUrl}`);
  console.error(`[LM Studio MCP] Timeout: ${CONFIG.timeout}ms`);
  console.error(`[LM Studio MCP] Cache: ${CONFIG.enableCache ? 'enabled' : 'disabled'}`);

  // Check connection to LM Studio
  const models = await getAvailableModels();
  if (models.length > 0) {
    console.error(`[LM Studio MCP] Connected! Found ${models.length} model(s):`);
    models.forEach(m => console.error(`  - ${m}`));

    if (!CONFIG.defaultModel && models.length > 0) {
      CONFIG.defaultModel = models[0];
      console.error(`[LM Studio MCP] Using default model: ${CONFIG.defaultModel}`);
    }
  } else {
    console.error('[LM Studio MCP] WARNING: Could not connect to LM Studio or no models loaded');
    console.error('[LM Studio MCP] Server will start but tools may fail until LM Studio is ready');
  }

  const server = new Server(
    {
      name: 'lm-studio-tools',
      version: '1.0.0',
    },
    {
      capabilities: {
        tools: {},
      },
    }
  );

  // List tools handler
  server.setRequestHandler(ListToolsRequestSchema, async () => {
    return {
      tools: TOOLS.map(({ handler, ...tool }) => tool)
    };
  });

  // Call tool handler
  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;

    const tool = TOOLS.find(t => t.name === name);
    if (!tool) {
      throw new Error(`Unknown tool: ${name}`);
    }

    console.error(`[LM Studio MCP] Tool called: ${name}`);

    // Check cache
    const key = cacheKey(name, args);
    const cached = getCached(key);
    if (cached) {
      console.error(`[LM Studio MCP] Cache hit for ${name}`);
      return {
        content: [{ type: 'text', text: cached }]
      };
    }

    try {
      const result = await tool.handler(args);

      // Cache result
      setCache(key, result);

      return {
        content: [{ type: 'text', text: result }]
      };
    } catch (error) {
      console.error(`[LM Studio MCP] Error executing tool ${name}:`, error.message);
      throw error;
    }
  });

  // Start server
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error('[LM Studio MCP] Server ready!');
}

main().catch(error => {
  console.error('[LM Studio MCP] Fatal error:', error);
  process.exit(1);
});
