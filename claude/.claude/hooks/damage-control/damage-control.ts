/**
 * Claude Code Unified Damage Control Hook
 * ========================================
 *
 * Single hook for Bash, Edit, and Write tools.
 * Matches: "Bash|Edit|Write" in settings.json
 *
 * Exit codes:
 *   0 = Allow (or JSON output with permissionDecision)
 *   2 = Block (stderr fed back to Claude)
 */

import { homedir } from "os";
import {
  loadConfig,
  readStdin,
  parseHookInput,
  checkFilePath,
  isGlobPattern,
  globToRegex,
  isSafeEnvFile,
  type Config,
} from "./shared";

// =============================================================================
// BASH TOOL PATTERNS
// =============================================================================

type PatternTuple = [string, string]; // [pattern, operation]

const WRITE_PATTERNS: PatternTuple[] = [
  [">\\s*{path}", "write"],
  ["\\btee\\s+(?!.*-a).*{path}", "write"],
];

const APPEND_PATTERNS: PatternTuple[] = [
  [">>\\s*{path}", "append"],
  ["\\btee\\s+-a\\s+.*{path}", "append"],
  ["\\btee\\s+.*-a.*{path}", "append"],
];

const EDIT_PATTERNS: PatternTuple[] = [
  ["\\bsed\\s+-i.*{path}", "edit"],
  ["\\bperl\\s+-[^\\s]*i.*{path}", "edit"],
  ["\\bawk\\s+-i\\s+inplace.*{path}", "edit"],
];

const MOVE_COPY_PATTERNS: PatternTuple[] = [
  ["\\bmv\\s+.*\\s+{path}", "move"],
  ["\\bcp\\s+.*\\s+{path}", "copy"],
];

const DELETE_PATTERNS: PatternTuple[] = [
  ["\\brm\\s+.*{path}", "delete"],
  ["\\bunlink\\s+.*{path}", "delete"],
  ["\\brmdir\\s+.*{path}", "delete"],
  ["\\bshred\\s+.*{path}", "delete"],
];

const PERMISSION_PATTERNS: PatternTuple[] = [
  ["\\bchmod\\s+.*{path}", "chmod"],
  ["\\bchown\\s+.*{path}", "chown"],
  ["\\bchgrp\\s+.*{path}", "chgrp"],
];

const TRUNCATE_PATTERNS: PatternTuple[] = [
  ["\\btruncate\\s+.*{path}", "truncate"],
  [":\\s*>\\s*{path}", "truncate"],
];

const READ_ONLY_BLOCKED: PatternTuple[] = [
  ...WRITE_PATTERNS,
  ...APPEND_PATTERNS,
  ...EDIT_PATTERNS,
  ...MOVE_COPY_PATTERNS,
  ...DELETE_PATTERNS,
  ...PERMISSION_PATTERNS,
  ...TRUNCATE_PATTERNS,
];

const NO_DELETE_BLOCKED: PatternTuple[] = DELETE_PATTERNS;

// =============================================================================
// BASH TOOL CHECKING
// =============================================================================

function checkPathPatterns(
  command: string,
  path: string,
  patterns: PatternTuple[],
  pathType: string
): { blocked: boolean; reason: string } {
  if (isGlobPattern(path)) {
    const globRegex = globToRegex(path);
    for (const [patternTemplate, operation] of patterns) {
      try {
        const cmdPrefix = patternTemplate.replace("{path}", "");
        if (cmdPrefix) {
          const regex = new RegExp(cmdPrefix + globRegex, "i");
          if (regex.test(command)) {
            return {
              blocked: true,
              reason: `Blocked: ${operation} operation on ${pathType} ${path}`,
            };
          }
        }
      } catch {
        continue;
      }
    }
  } else {
    const expanded = path.replace(/^~/, homedir());
    const escapedExpanded = expanded.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const escapedOriginal = path.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

    for (const [patternTemplate, operation] of patterns) {
      const patternExpanded = patternTemplate.replace("{path}", escapedExpanded);
      const patternOriginal = patternTemplate.replace("{path}", escapedOriginal);
      try {
        const regexExpanded = new RegExp(patternExpanded);
        const regexOriginal = new RegExp(patternOriginal);
        if (regexExpanded.test(command) || regexOriginal.test(command)) {
          return {
            blocked: true,
            reason: `Blocked: ${operation} operation on ${pathType} ${path}`,
          };
        }
      } catch {
        continue;
      }
    }
  }

  return { blocked: false, reason: "" };
}

function checkBashCommand(
  command: string,
  config: Config
): { blocked: boolean; ask: boolean; reason: string } {
  // 1. Check against patterns from YAML (may block or ask)
  for (const { pattern, reason, ask: shouldAsk } of config.bashToolPatterns) {
    try {
      const regex = new RegExp(pattern, "i");
      if (regex.test(command) && !isSafeEnvFile(command)) {
        if (shouldAsk) {
          return { blocked: false, ask: true, reason };
        } else {
          return { blocked: true, ask: false, reason: `Blocked: ${reason}` };
        }
      }
    } catch {
      continue;
    }
  }

  // 2. Check for ANY access to zero-access paths
  for (const zeroPath of config.zeroAccessPaths) {
    if (isGlobPattern(zeroPath)) {
      const globRegex = globToRegex(zeroPath);
      try {
        const regex = new RegExp(globRegex, "i");
        if (regex.test(command) && !isSafeEnvFile(command)) {
          return {
            blocked: true,
            ask: false,
            reason: `Blocked: zero-access pattern ${zeroPath} (no operations allowed)`,
          };
        }
      } catch {
        continue;
      }
    } else {
      const expanded = zeroPath.replace(/^~/, homedir());
      if (
        (command.includes(expanded) || command.includes(zeroPath)) &&
        !isSafeEnvFile(command)
      ) {
        return {
          blocked: true,
          ask: false,
          reason: `Blocked: zero-access path ${zeroPath} (no operations allowed)`,
        };
      }
    }
  }

  // 3. Check for modifications to read-only paths
  for (const readonlyPath of config.readOnlyPaths) {
    const result = checkPathPatterns(
      command,
      readonlyPath,
      READ_ONLY_BLOCKED,
      "read-only path"
    );
    if (result.blocked) {
      return { ...result, ask: false };
    }
  }

  // 4. Check for deletions on no-delete paths
  for (const noDeletePath of config.noDeletePaths) {
    const result = checkPathPatterns(
      command,
      noDeletePath,
      NO_DELETE_BLOCKED,
      "no-delete path"
    );
    if (result.blocked) {
      return { ...result, ask: false };
    }
  }

  return { blocked: false, ask: false, reason: "" };
}

// =============================================================================
// MAIN
// =============================================================================

async function main(): Promise<void> {
  const config = loadConfig();
  const inputText = await readStdin();

  let input;
  try {
    input = parseHookInput(inputText);
  } catch (e) {
    console.error(`Error: Invalid JSON input: ${e}`);
    process.exit(1);
  }

  const toolName = input.tool_name;

  // Handle based on tool type
  if (toolName === "Bash") {
    const command = input.tool_input?.command || "";
    if (!command) {
      process.exit(0);
    }

    const { blocked, ask, reason } = checkBashCommand(command, config);

    if (blocked) {
      console.error(`SECURITY: ${reason}`);
      console.error(
        `Command: ${command.slice(0, 100)}${command.length > 100 ? "..." : ""}`
      );
      process.exit(2);
    } else if (ask) {
      const output = {
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "ask",
          permissionDecisionReason: reason,
        },
      };
      console.log(JSON.stringify(output));
      process.exit(0);
    } else {
      process.exit(0);
    }
  } else if (toolName === "Edit" || toolName === "Write") {
    const filePath = input.tool_input?.file_path || "";
    if (!filePath) {
      process.exit(0);
    }

    const { blocked, reason } = checkFilePath(filePath, config);
    if (blocked) {
      console.error(`SECURITY: Blocked ${toolName.toLowerCase()} to ${reason}: ${filePath}`);
      process.exit(2);
    }

    process.exit(0);
  } else {
    // Unknown tool, allow
    process.exit(0);
  }
}

main().catch((e) => {
  console.error(`Hook error: ${e}`);
  process.exit(0); // Fail open
});
