export interface AIResponse {
  content: string;
  processingTime: number;
  tokensUsed?: number;
}

export interface AIStreamChunk {
  content: string;
  processingTime: number;
  done: boolean;
}

export interface AIProvider {
  generate(systemPrompt: string, userPrompt: string): Promise<AIResponse>;
  generateStream?(systemPrompt: string, userPrompt: string): AsyncGenerator<AIStreamChunk>;
}
