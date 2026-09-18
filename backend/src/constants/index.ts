export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  INTERNAL_SERVER_ERROR: 500,
};

export const AI_PROVIDERS = {
  GEMINI: "gemini",
  OPENAI: "openai",
  CLAUDE: "claude",
  DEEPSEEK: "deepseek",
};

export const DOCUMENT_TYPES = {
  PETITION: "petition",
  EMAIL: "email",
  CV: "cv",
  PDF: "pdf",
};

export const AI_MESSAGE_ROLES = {
  USER: "user",
  ASSISTANT: "assistant",
  SYSTEM: "system",
};

export const FILE_PURPOSES = {
  PROFILE: "profile",
  PDF: "pdf",
  SCAN: "scan",
  TEMP: "temp",
};
