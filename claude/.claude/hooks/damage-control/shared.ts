/**
 * Shared utilities for Claude Code Damage Control hooks
 * ======================================================
 */

import { existsSync, readFileSync } from "fs";
import { dirname, join, basename } from "path";
import { homedir } from "os";
import { parse as parseYaml } from "yaml";

// =============================================================================
// TYPES
// =============================================================================

export interface Pattern {
  pattern: string;
  reason: string;
  ask?: boolean;
}

export interface Config {
  bashToolPatterns: Pattern[];
  zeroAccessPaths: string[];
  readOnlyPaths: string[];
  noDeletePaths: string[];
}

export interface HookInput {
  tool_name: string;
  tool_input: {
    command?: string;
    file_path?: string;
    [key: string]: unknown;
  };
}

// =============================================================================
// SAFE ENV PATTERNS - Excluded from zero-access checks
// =============================================================================

const SAFE_ENV_PATTERNS = [
  /\.env\.example/,
  /\.env\.sample/,
  /\.env\.template/,
];

export function isSafeEnvFile(pathOrCommand: string): boolean {
  return SAFE_ENV_PATTERNS.some(pattern => pattern.test(pathOrCommand));
}

// =============================================================================
// GLOB PATTERN UTILITIES
// =============================================================================

export function isGlobPattern(pattern: string): boolean {
  return pattern.includes('*') || pattern.includes('?') || pattern.includes('[');
}

export function globToRegex(globPattern: string): string {
  // Convert glob pattern to regex for matching in commands
  let result = "";
  for (const char of globPattern) {
    if (char === '*') {
      result += '[^\\s/]*';  // Match any chars except whitespace and path sep
    } else if (char === '?') {
      result += '[^\\s/]';   // Match single char except whitespace and path sep
    } else if ('.+^${}()|[]\\'.includes(char)) {
      result += '\\' + char;
    } else {
      result += char;
    }
  }
  return result;
}

export function matchGlob(str: string, pattern: string): boolean {
  // Convert glob pattern to regex (case-insensitive for security)
  const regexPattern = pattern.toLowerCase()
    .replace(/[.+^${}()|[\]\\]/g, '\\$&')  // Escape special regex chars
    .replace(/\*/g, '.*')                   // * matches anything
    .replace(/\?/g, '.');                   // ? matches single char

  try {
    const regex = new RegExp(`^${regexPattern}$`, 'i');
    return regex.test(str.toLowerCase());
  } catch {
    return false;
  }
}

export function matchPath(filePath: string, pattern: string): boolean {
  const expandedPattern = pattern.replace(/^~/, homedir());
  const normalized = filePath.replace(/^~/, homedir());

  if (isGlobPattern(pattern)) {
    // Glob pattern matching (case-insensitive for security)
    const fileBasename = basename(normalized);
    if (matchGlob(fileBasename, expandedPattern) || matchGlob(fileBasename, pattern)) {
      return true;
    }
    // Also try full path match
    if (matchGlob(normalized, expandedPattern)) {
      return true;
    }
    return false;
  } else {
    // Prefix matching (original behavior for directories)
    if (normalized.startsWith(expandedPattern) || normalized === expandedPattern.replace(/\/$/, "")) {
      return true;
    }
    return false;
  }
}

// =============================================================================
// CONFIGURATION
// =============================================================================

export function getConfigPath(): string {
  // 1. Check project hooks directory (installed location)
  const projectDir = process.env.CLAUDE_PROJECT_DIR;
  if (projectDir) {
    const projectConfig = join(projectDir, ".claude", "hooks", "damage-control", "patterns.yaml");
    if (existsSync(projectConfig)) {
      return projectConfig;
    }
  }

  // 2. Check script's own directory (installed location)
  const scriptDir = dirname(Bun.main);
  const localConfig = join(scriptDir, "patterns.yaml");
  if (existsSync(localConfig)) {
    return localConfig;
  }

  // 3. Check skill root directory (development location)
  const skillRoot = join(scriptDir, "..", "..", "patterns.yaml");
  if (existsSync(skillRoot)) {
    return skillRoot;
  }

  return localConfig; // Default, even if it doesn't exist
}

export function loadConfig(): Config {
  const configPath = getConfigPath();

  if (!existsSync(configPath)) {
    console.error(`Warning: Config not found at ${configPath}`);
    return { bashToolPatterns: [], zeroAccessPaths: [], readOnlyPaths: [], noDeletePaths: [] };
  }

  const content = readFileSync(configPath, "utf-8");
  const config = parseYaml(content) as Partial<Config>;

  return {
    bashToolPatterns: config.bashToolPatterns || [],
    zeroAccessPaths: config.zeroAccessPaths || [],
    readOnlyPaths: config.readOnlyPaths || [],
    noDeletePaths: config.noDeletePaths || [],
  };
}

// =============================================================================
// STDIN PARSING
// =============================================================================

export async function readStdin(): Promise<string> {
  let inputText = "";
  for await (const chunk of Bun.stdin.stream()) {
    inputText += new TextDecoder().decode(chunk);
  }
  return inputText;
}

export function parseHookInput(inputText: string): HookInput {
  return JSON.parse(inputText);
}

// =============================================================================
// PATH CHECKING (for Edit/Write tools)
// =============================================================================

export function checkFilePath(
  filePath: string,
  config: Config
): { blocked: boolean; reason: string } {
  // Check zero-access paths first (skip safe env files)
  for (const zeroPath of config.zeroAccessPaths) {
    if (matchPath(filePath, zeroPath) && !isSafeEnvFile(filePath)) {
      return { blocked: true, reason: `zero-access path ${zeroPath} (no operations allowed)` };
    }
  }

  // Check read-only paths
  for (const readonlyPath of config.readOnlyPaths) {
    if (matchPath(filePath, readonlyPath)) {
      return { blocked: true, reason: `read-only path ${readonlyPath}` };
    }
  }

  return { blocked: false, reason: "" };
}
