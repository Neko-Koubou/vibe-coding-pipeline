#!/usr/bin/env node
"use strict";
/**
 * Vibe Coding Pipeline — npm / npx installer.
 * Same behavior as install.py: Global vs Project scope, multi-select agents,
 * slash commands + Agent Skills (SKILL.md) + rules. No dependencies.
 *
 *   npx Neko-Koubou/vibe-coding-pipeline                      interactive install
 *   npx Neko-Koubou/vibe-coding-pipeline --global --agents all
 *   npx Neko-Koubou/vibe-coding-pipeline uninstall
 */

const fs = require("fs");
const os = require("os");
const path = require("path");
const readline = require("readline");

const PKG_DIR = path.resolve(__dirname, "..");
const PROMPTS_DIR = path.join(PKG_DIR, "prompts");
const SKILLS_DIR = path.join(PKG_DIR, "skills");
const RULES_DIR = path.join(PKG_DIR, "rules");
const VERSION = require(path.join(PKG_DIR, "package.json")).version;

// The rules block is wrapped in these markers so a re-install can replace it in place.
const VIBE_BLOCK_START = "<!-- vibe-pipeline:start -->";
const VIBE_BLOCK_END = "<!-- vibe-pipeline:end -->";
// Installs from before the markers existed: the block runs from this header through rule 4.
const LEGACY_BLOCK_START = "# Vibe Coding Pipeline — Multi-Agent Engineering Protocol";
const LEGACY_BLOCK_LAST_LINE = "4. **Atomic Coding**";
// Rule files that belong to the pipeline alone and can simply be overwritten.
const DEDICATED_RULE_FILES = new Set(["vibe-pipeline.md", "vibe-pipeline.mdc"]);

const DEFAULT_AGENTS = new Set(["claude", "antigravity", "codex"]);
const AGENT_ALIASES = { "claude-code": "claude", ag: "antigravity", chatgpt: "codex", roo: "roocode", cline: "roocode" };

const HELP = `Vibe Coding Pipeline installer v${VERSION}

Usage:
  npx Neko-Koubou/vibe-coding-pipeline [install] [options]   Install /vibe-* commands, skills & rules
  npx Neko-Koubou/vibe-coding-pipeline uninstall             Remove the global /vibe-* commands & skills

Options:
  -g, --global              Install for the current OS user (all projects)
  -p, --project [dir]       Install into one project (default: current directory)
  -t, --target <dir>        Project directory for --project
  -a, --agents <list>       Comma-separated: claude,antigravity,opencode,codex,cursor,windsurf,roocode,all
  -y, --yes                 Skip prompts: Global scope + claude,antigravity,codex unless set
  -v, --version             Print the version
  -h, --help                Show this help

Without --global/--project or --agents, the installer asks interactively.
Also published on npm: npx vibe-coding-pipeline@latest
After "npm i -g Neko-Koubou/vibe-coding-pipeline", the same CLI is available as "vibe-pipeline".`;

class UsageError extends Error {}

function detectEnv() {
  const home = os.homedir();
  if (process.platform === "win32") {
    return {
      osType: "windows",
      osLabel: `Windows (${os.release()} ${os.arch()})`,
      home,
      appdata: process.env.APPDATA || path.join(home, "AppData", "Roaming"),
      xdg: path.join(home, ".config"),
    };
  }
  const xdg = process.env.XDG_CONFIG_HOME || path.join(home, ".config");
  if (process.platform === "darwin") {
    return { osType: "macos", osLabel: `macOS (${os.arch()})`, home, appdata: path.join(home, "Library", "Application Support"), xdg };
  }
  let wsl = false;
  try {
    wsl = fs.readFileSync("/proc/version", "utf8").toLowerCase().includes("microsoft");
  } catch {
    // not Linux, or /proc is unavailable
  }
  return { osType: "linux", osLabel: `Linux (${wsl ? "WSL2 " : ""}${os.arch()})`, home, appdata: xdg, xdg };
}

// Keep in sync with get_agent_specs() in install.py.
function agentSpecs(env, target) {
  const { home: h, xdg, appdata } = env;
  const j = path.join;
  const agentsRule = j(RULES_DIR, "AGENTS.md");
  const claudeRule = j(RULES_DIR, "CLAUDE.md");
  const cursorRule = j(RULES_DIR, "vibe-pipeline.mdc");
  const opencodeGlobalCmd = [j(xdg, "opencode", "command"), j(xdg, "opencode", "commands")];
  if (env.osType === "windows") opencodeGlobalCmd.push(j(appdata, "opencode", "command"), j(appdata, "opencode", "commands"));

  return [
    {
      key: "claude",
      name: "Claude Code (CLI & IDE)",
      global: { cmd: [j(h, ".claude", "commands")], skills: [j(h, ".claude", "skills")], rules: [[claudeRule, j(h, ".claude", "CLAUDE.md")]] },
      project: { cmd: [j(target, ".claude", "commands")], skills: [j(target, ".claude", "skills")], rules: [[claudeRule, j(target, "CLAUDE.md")]] },
    },
    {
      key: "antigravity",
      name: "Google Antigravity (IDE & CLI)",
      global: {
        cmd: [j(h, ".gemini", "config", "global_workflows"), j(h, ".gemini", "config", "workflows")],
        skills: [j(h, ".gemini", "config", "skills")],
        rules: [
          [agentsRule, j(h, ".gemini", "GEMINI.md")],
          [agentsRule, j(h, ".gemini", "config", "GEMINI.md")],
        ],
      },
      project: {
        cmd: [j(target, ".agents", "workflows"), j(target, ".agent", "workflows")],
        skills: [j(target, ".agents", "skills"), j(target, ".agent", "skills")],
        rules: [
          [agentsRule, j(target, ".agents", "rules", "vibe-pipeline.md")],
          [agentsRule, j(target, ".agent", "rules", "vibe-pipeline.md")],
          [agentsRule, j(target, "AGENTS.md")],
        ],
      },
    },
    {
      key: "opencode",
      name: "OpenCode (CLI / Desktop)",
      global: { cmd: opencodeGlobalCmd, skills: [j(xdg, "opencode", "skills")], rules: [[agentsRule, j(xdg, "opencode", "AGENTS.md")]] },
      project: {
        cmd: [j(target, ".opencode", "command"), j(target, ".opencode", "commands")],
        skills: [j(target, ".opencode", "skills")],
        rules: [[agentsRule, j(target, "AGENTS.md")]],
      },
    },
    {
      key: "codex",
      name: "Codex CLI + ChatGPT App",
      global: { cmd: [j(h, ".codex", "prompts")], skills: [j(h, ".codex", "skills")], rules: [[agentsRule, j(h, ".codex", "AGENTS.md")]] },
      project: { cmd: [j(target, ".codex", "prompts")], skills: [j(target, ".codex", "skills")], rules: [[agentsRule, j(target, "AGENTS.md")]] },
    },
    {
      key: "cursor",
      name: "Cursor (AI IDE)",
      global: { cmd: [j(h, ".cursor", "commands")], skills: [j(h, ".cursor", "skills")], rules: [[cursorRule, j(h, ".cursor", "rules", "vibe-pipeline.mdc")]] },
      project: {
        cmd: [j(target, ".cursor", "commands")],
        skills: [j(target, ".cursor", "skills")],
        rules: [[cursorRule, j(target, ".cursor", "rules", "vibe-pipeline.mdc")]],
      },
    },
    {
      key: "windsurf",
      name: "Windsurf (Agentic IDE)",
      global: {
        cmd: [j(h, ".codeium", "windsurf", "global_workflows"), j(h, ".windsurf", "workflows")],
        skills: [],
        rules: [[agentsRule, j(h, ".codeium", "windsurf", "memories", "global_rules.md")]],
      },
      project: { cmd: [j(target, ".windsurf", "workflows")], skills: [], rules: [[agentsRule, j(target, ".windsurf", "rules", "vibe-pipeline.md")]] },
    },
    {
      key: "roocode",
      name: "Roo Code / Cline",
      global: { cmd: [j(h, ".roo", "commands")], skills: [], rules: [[agentsRule, j(h, ".roo", "rules", "vibe-pipeline.md")]] },
      project: {
        cmd: [j(target, ".roo", "commands"), j(target, ".clinerules", "workflows")],
        skills: [],
        rules: [[agentsRule, j(target, ".roo", "rules", "vibe-pipeline.md")]],
      },
    },
  ];
}

function listFiles(dir) {
  return fs
    .readdirSync(dir, { withFileTypes: true })
    .filter((entry) => entry.isFile())
    .map((entry) => entry.name)
    .sort();
}

function copyPrompts(destDir) {
  fs.mkdirSync(destDir, { recursive: true });
  for (const name of listFiles(PROMPTS_DIR)) {
    if (name.endsWith(".md")) fs.copyFileSync(path.join(PROMPTS_DIR, name), path.join(destDir, name));
  }
}

function copySkills(destRoot) {
  fs.mkdirSync(destRoot, { recursive: true });
  for (const entry of fs.readdirSync(SKILLS_DIR, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const src = path.join(SKILLS_DIR, entry.name);
    const dest = path.join(destRoot, entry.name);
    fs.mkdirSync(dest, { recursive: true });
    for (const name of listFiles(src)) fs.copyFileSync(path.join(src, name), path.join(dest, name));
  }
}

/** Swap a previously installed Vibe block for `block`; null if no complete block is found. */
function replaceRuleBlock(existing, block) {
  const lines = existing.match(/[^\n]*\n|[^\n]+$/g) || [];
  for (const [first, last] of [
    [VIBE_BLOCK_START, VIBE_BLOCK_END],
    [LEGACY_BLOCK_START, LEGACY_BLOCK_LAST_LINE],
  ]) {
    const start = lines.findIndex((line) => line.startsWith(first));
    if (start === -1) continue;
    const end = lines.findIndex((line, i) => i > start && line.startsWith(last));
    if (end === -1) continue;
    const trailing = lines[end].endsWith("\n") ? "\n" : "";
    return lines.slice(0, start).join("") + block.replace(/\n+$/, "") + trailing + lines.slice(end + 1).join("");
  }
  return null;
}

/** Install the rules block, updating an older installed copy instead of skipping it. */
function installRule(src, dest) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  if (DEDICATED_RULE_FILES.has(path.basename(dest)) || !fs.existsSync(dest)) {
    fs.copyFileSync(src, dest);
    return;
  }
  const block = fs.readFileSync(src, "utf8");
  const raw = fs.readFileSync(dest);
  const existing = raw.toString("utf8");
  if (!Buffer.from(existing, "utf8").equals(raw)) {
    console.log(`⚠️  ${dest} is not valid UTF-8; add the rules from ${src} manually`);
    return;
  }
  let updated = replaceRuleBlock(existing, block);
  if (updated === null) {
    if (existing.includes("Vibe Coding Pipeline")) {
      console.log(`⚠️  ${dest} has a modified Vibe Coding Pipeline block; update it manually from ${src}`);
      return;
    }
    updated = (existing.trim() ? existing.replace(/\n+$/, "") + "\n\n" : "") + block;
  }
  fs.writeFileSync(dest, updated, "utf8");
}

/** Turn "claude,codex" / "1 4" / "all" into one boolean per agent spec. */
function parseAgentList(list, specs) {
  const tokens = list.toLowerCase().split(/[\s,]+/).filter(Boolean);
  if (tokens.includes("all")) return specs.map(() => true);
  const selected = specs.map(() => false);
  const unknown = [];
  for (const token of tokens) {
    const key = AGENT_ALIASES[token] || token;
    let idx = specs.findIndex((sp) => sp.key === key);
    if (idx === -1 && /^\d+$/.test(token) && Number(token) >= 1 && Number(token) <= specs.length) idx = Number(token) - 1;
    if (idx === -1) unknown.push(token);
    else selected[idx] = true;
  }
  if (unknown.length) console.log(`⚠️  Agent tidak dikenal, dilewati: ${unknown.join(", ")}`);
  if (!selected.some(Boolean)) {
    throw new UsageError(`No known agent in "${list}". Use: ${specs.map((sp) => sp.key).join(", ")}, all`);
  }
  return selected;
}

function expandHome(p) {
  return p === "~" || p.startsWith("~/") || p.startsWith("~\\") ? path.join(os.homedir(), p.slice(1)) : p;
}

function createPrompter() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  rl.on("SIGINT", () => {
    console.log("\nDibatalkan.");
    process.exit(130);
  });
  const ask = (question) =>
    new Promise((resolve, reject) => {
      const onClose = () => reject(new UsageError("Input closed; installation cancelled."));
      rl.once("close", onClose);
      rl.question(question, (answer) => {
        rl.removeListener("close", onClose);
        resolve(answer.trim());
      });
    });
  return { ask, close: () => rl.close() };
}

async function promptScope(ask, env, target) {
  console.log("\nLANGKAH 1/2 — Pilih Mode Instalasi (Installation Scope):");
  console.log(`  [1] 🌍 GLOBAL (Recommended) — Install 1x di ${env.osLabel}, aktif di SEMUA project!`);
  console.log("  [2] 📁 SINGLE PROJECT       — Install hanya di 1 folder project spesifik");
  const choice = (await ask("\n👉 Pilih mode [1 = Global, 2 = Project] (default: 1): ")).toLowerCase();
  if (["", "1", "g", "global"].includes(choice)) return { scope: "global", target };
  const custom = await ask(`📂 Path folder project (ENTER untuk ${target}): `);
  return { scope: "project", target: custom ? path.resolve(expandHome(custom)) : target };
}

async function promptAgents(ask, specs, scope) {
  let selected = specs.map((sp) => DEFAULT_AGENTS.has(sp.key));
  for (;;) {
    console.log("\n" + "-".repeat(72));
    console.log(`LANGKAH 2/2 — Pilih AI Agent (Multi-Select | Scope: ${scope.toUpperCase()}):`);
    specs.forEach((sp, i) => {
      console.log(`  ${selected[i] ? "[x]" : "[ ]"} ${i + 1}) ${sp.name.padEnd(28)} -> ${sp[scope].cmd[0]}`);
    });
    console.log("\n  • Ketik angka untuk toggle (contoh: 1,2,4) | 'a' = Semua | 'n' = Reset");
    console.log("  • Tekan ENTER jika selesai memilih untuk mulai install");
    const answer = (await ask("👉 Pilihan Anda: ")).toLowerCase();
    if (["", "y", "d", "install"].includes(answer)) {
      if (selected.some(Boolean)) return selected;
      console.log("⚠️  Pilih minimal 1 agent!");
    } else if (answer === "a" || answer === "all") {
      selected = specs.map(() => true);
    } else if (answer === "n" || answer === "none") {
      selected = specs.map(() => false);
    } else {
      for (const token of answer.split(/[\s,]+/)) {
        const n = Number(token);
        if (Number.isInteger(n) && n >= 1 && n <= specs.length) selected[n - 1] = !selected[n - 1];
      }
    }
  }
}

async function install(opts, env) {
  console.log("=".repeat(72));
  console.log(`   ⚡ VIBE CODING PIPELINE — NPX INSTALLER v${VERSION}`);
  console.log("=".repeat(72));
  console.log(`   🖥️  Detected OS   : ${env.osLabel}`);
  console.log(`   🏠 Home Directory: ${env.home}`);
  console.log("-".repeat(72));

  let scope = opts.scope || (opts.yes ? "global" : "");
  let target = path.resolve(expandHome(opts.target));
  const needsPrompt = !scope || (!opts.agents && !opts.yes);
  if (needsPrompt && !process.stdin.isTTY) {
    throw new UsageError("No terminal for interactive prompts: pass --global or --project with --agents (or --yes for the defaults).");
  }

  const prompter = needsPrompt ? createPrompter() : null;
  let specs;
  let selected;
  try {
    if (!scope) ({ scope, target } = await promptScope(prompter.ask, env, target));
    specs = agentSpecs(env, target);
    if (opts.agents) selected = parseAgentList(opts.agents, specs);
    else if (opts.yes) selected = specs.map((sp) => DEFAULT_AGENTS.has(sp.key));
    else selected = await promptAgents(prompter.ask, specs, scope);
  } finally {
    if (prompter) prompter.close();
  }

  console.log("\n" + "=".repeat(72));
  if (scope === "project") fs.mkdirSync(path.join(target, "docs", "vibe"), { recursive: true });
  specs.forEach((sp, i) => {
    if (!selected[i]) return;
    const paths = sp[scope];
    paths.cmd.forEach(copyPrompts);
    paths.skills.forEach(copySkills);
    for (const [src, dest] of paths.rules) installRule(src, dest);
    console.log(`✅ ${sp.name} (${scope.toUpperCase()}) -> ${paths.cmd[0]}`);
  });
  console.log("=".repeat(72));
  console.log("🎉 Instalasi selesai! Gunakan /vibe-init, /vibe-prd, /vibe-design, /vibe-sa, /vibe-tasks, /vibe-code, /vibe-review, /vibe-test, /vibe-status");
}

// Keep in sync with uninstall.py.
function uninstall(env) {
  const { home: h, xdg, appdata } = env;
  const j = path.join;
  // [directory, suffix]: every entry named vibe-*<suffix> in that directory is removed.
  const patterns = [
    [j(h, ".claude", "commands"), ".md"],
    [j(h, ".claude", "skills"), ""],
    [j(h, ".gemini", "config", "global_workflows"), ".md"],
    [j(h, ".gemini", "config", "workflows"), ".md"],
    [j(h, ".gemini", "config", "skills"), ""],
    // Antigravity legacy (incorrect) paths from older installers
    [j(h, ".gemini", "antigravity", "global_workflows"), ".md"],
    [j(h, ".gemini", "antigravity", "skills"), ""],
    [j(h, ".agent", "workflows"), ".md"],
    [j(h, ".agents", "skills"), ""],
    [j(xdg, "opencode", "command"), ".md"],
    [j(xdg, "opencode", "commands"), ".md"],
    [j(xdg, "opencode", "skills"), ""],
    [j(appdata, "opencode", "command"), ".md"],
    [j(appdata, "opencode", "commands"), ".md"],
    [j(appdata, "opencode", "skills"), ""],
    [j(h, ".codex", "prompts"), ".md"],
    [j(h, ".codex", "skills"), ""],
    [j(h, ".cursor", "commands"), ".md"],
    [j(h, ".cursor", "skills"), ""],
    [j(h, ".codeium", "windsurf", "global_workflows"), ".md"],
    [j(h, ".windsurf", "workflows"), ".md"],
    [j(h, ".roo", "commands"), ".md"],
  ];
  const singleFiles = [j(h, ".agent", "rules", "vibe-pipeline.md"), j(h, ".cursor", "rules", "vibe-pipeline.mdc")];

  console.log("🗑️  Menghapus global commands & skills /vibe-*...");
  let removed = 0;
  for (const [dir, suffix] of patterns) {
    let names;
    try {
      names = fs.readdirSync(dir);
    } catch {
      continue;
    }
    for (const name of names) {
      if (name.startsWith("vibe-") && name.endsWith(suffix)) {
        fs.rmSync(j(dir, name), { recursive: true, force: true });
        removed += 1;
      }
    }
  }
  for (const file of singleFiles) {
    if (fs.existsSync(file)) {
      fs.rmSync(file, { force: true });
      removed += 1;
    }
  }
  console.log(`✅ Semua global command & skill /vibe-* berhasil dihapus (${removed} item).`);
}

function parseArgs(argv) {
  const opts = { command: "install", scope: "", target: process.cwd(), agents: "", yes: false };
  const args = [];
  for (const arg of argv) {
    const eq = arg.startsWith("--") ? arg.indexOf("=") : -1;
    if (eq === -1) args.push(arg);
    else args.push(arg.slice(0, eq), arg.slice(eq + 1));
  }
  if (args.length && !args[0].startsWith("-")) opts.command = args.shift();
  const value = (flag) => {
    if (!args.length || args[0].startsWith("-")) throw new UsageError(`${flag} needs a value`);
    return args.shift();
  };
  while (args.length) {
    const arg = args.shift();
    switch (arg) {
      case "-g":
      case "--global":
        opts.scope = "global";
        break;
      case "-p":
      case "--project":
        opts.scope = "project";
        if (args.length && !args[0].startsWith("-")) opts.target = args.shift();
        break;
      case "-t":
      case "--target":
        opts.target = value(arg);
        break;
      case "-a":
      case "--agent":
      case "--agents":
        opts.agents = value(arg);
        break;
      case "-y":
      case "--yes":
        opts.yes = true;
        break;
      case "-h":
      case "--help":
        opts.command = "help";
        break;
      case "-v":
      case "--version":
        opts.command = "version";
        break;
      default:
        throw new UsageError(`Unknown option: ${arg}`);
    }
  }
  return opts;
}

async function main() {
  try {
    const opts = parseArgs(process.argv.slice(2));
    if (opts.command === "help") console.log(HELP);
    else if (opts.command === "version") console.log(VERSION);
    else if (opts.command === "install") await install(opts, detectEnv());
    else if (opts.command === "uninstall") uninstall(detectEnv());
    else throw new UsageError(`Unknown command: ${opts.command}`);
  } catch (err) {
    if (err instanceof UsageError) {
      console.error(`❌ ${err.message}\nRun with --help for usage.`);
    } else {
      console.error(`❌ ${err.message}`);
    }
    process.exitCode = 1;
  }
}

main();
