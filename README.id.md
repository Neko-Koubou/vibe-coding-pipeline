# ⚡ Vibe Coding Pipeline — Panduan Lengkap Bahasa Indonesia (Edisi 2026)

Framework **Artifact-Driven Vibe Coding** dengan *slash command* (`/vibe-*`) dan **Agent Skills (`SKILL.md` / `$vibe-*`)** yang mendukung instalasi **Global (semua project)** maupun **Single Project**, deteksi OS otomatis (**Windows, macOS, Linux/WSL**), serta **Multi-Select Agent Picker**.

---

## 📖 Daftar Isi
1. [Cara Install (Global vs Single Project)](#-1-cara-install-global-vs-single-project)
2. [Cara Pakai Jika Sudah Punya File `prd.md` Sendiri](#-2-cara-pakai-jika-sudah-punya-file-prdmd-sendiri)
3. [Cara Pakai dari Nol (Dari Ide Mentah Sampai Testing)](#-3-cara-pakai-dari-nol-dari-ide-mentah-sampai-testing)
4. [Cara Pakai di Project yang Sudah Jalan (Existing Codebase)](#-4-cara-pakai-di-project-yang-sudah-jalan-existing-codebase)
5. [Daftar Lengkap Slash Command & Contoh Pemakaian](#-5-daftar-lengkap-slash-command--contoh-pemakaian)
6. [Tabel Direktori Terbaru Masing-Masing Agent (2026)](#-6-tabel-direktori-terbaru-masing-masing-agent-2026)

---

## 🚀 1. Cara Install (Global vs Single Project)

Jalankan installer interaktif sesuai OS yang kamu gunakan:

### macOS / Linux / WSL / Git Bash
```bash
chmod +x install.sh
./install.sh
```

### Windows PowerShell / Universal Python 3
```powershell
python3 install.py
# atau melalui PowerShell:
.\install.ps1
```

Saat installer berjalan:
1. **Langkah 1/2 (Pilih Scope)**: Pilih **`[1] 🌍 GLOBAL`** agar cukup install satu kali saja dan command `/vibe-*` bisa langsung dipakai di **semua project** di komputermu.
2. **Langkah 2/2 (Multi-Select Agent)**: Ketik angka agent yang ingin di-install (misalnya `1,2,3,4` untuk memilih Claude Code, Antigravity, OpenCode, dan Codex sekaligus), lalu tekan **ENTER**.

--- 

## 📄 2. Cara Pakai Jika Sudah Punya File `prd.md` Sendiri

Kalau kamu sudah punya file `prd.md` (misalnya hasil tulis sendiri, dari tim Product, atau hasil diskusi sebelumnya), ada **2 cara praktis** untuk memasukkannya ke dalam pipeline:

### Cara 1: Import & Standarisasi Otomatis lewat `/vibe-prd` (Paling Disarankan)
Sering kali file `prd.md` manual belum memiliki kode penomoran *User Story* (`US-01`, `US-02`), kriteria *Given/When/Then*, atau *edge cases* yang nantinya dibutuhkan oleh `/vibe-sa` (System Analyst) dan `/vibe-test` (QA).

1. Taruh file `prd.md` kamu di dalam folder project.
2. Buka AI Agent kamu di folder project tersebut, lalu jalankan:
   ```text
   /vibe-init
   ```
   *(Untuk mendeteksi tech stack project dan membuat `docs/vibe/00-project-context.md`)*
3. Bersihkan chat (`/clear`), lalu panggil `/vibe-prd` dengan menyebutkan nama file `prd.md` kamu:
   ```text
   /vibe-prd prd.md
   ```
   *(Atau `/vibe-prd @prd.md` jika di Claude Code / Cursor / Antigravity)*.
4. AI Product Manager akan **membaca seluruh isi `prd.md` kamu**, mempertahankan semua fitur aslinya, melengkapi bagian yang kurang (seperti nomor `US-01`, diagram alur Mermaid, dan kriteria penerimaan), lalu menyimpannya ke `docs/vibe/01-prd.md`.
5. Setelah itu, kamu tinggal lanjut ke tahap berikutnya:
   - `/clear` $\rightarrow$ `/vibe-design` (jika butuh desain UI/UX & spesifikasi komponen frontend)
   - `/clear` $\rightarrow$ `/vibe-sa` (untuk membuat ERD Database, Sequence Diagram, & API Contract)
   - `/clear` $\rightarrow$ `/vibe-tasks` (memecah menjadi task kecil)
   - `/clear` $\rightarrow$ `/vibe-code` (mulai ngoding bertahap)

### Cara 2: Langsung Lompati `/vibe-prd` (Fast-Track)
Kalau file `prd.md` kamu sudah sangat lengkap dan kamu tidak ingin menjalankan `/vibe-prd` lagi:
1. Salin atau pindahkan `prd.md` kamu ke `docs/vibe/01-prd.md`:
   ```bash
   mkdir -p docs/vibe
   cp prd.md docs/vibe/01-prd.md
   ```
   *(Catatan: Bahkan jika kamu lupa menyalinnya ke `docs/vibe/01-prd.md`, prompt `/vibe-design` dan `/vibe-sa` di versi terbaru ini sudah dilengkapi fitur Auto-Fallback yang otomatis mencari `prd.md` di root project jika `01-prd.md` belum ada!)*
2. Jalankan `/vibe-init`.
3. Langsung jalankan **`/vibe-design`** atau **`/vibe-sa`**!

---

## 🛠️ 3. Cara Pakai dari Nol (Dari Ide Mentah Sampai Testing)

Berikut adalah urutan kerja (*best practice*) dari awal sampai aplikasi selesai dites:

1. **Tahap 0 — Inisialisasi Context (`/vibe-init`)**
   ```text
   /vibe-init Aplikasi Full-Stack menggunakan Laravel 12, Nuxt 3, Tailwind CSS, dan PostgreSQL
   ```
   *Output: `docs/vibe/00-project-context.md`*

2. **Tahap 1 — Product Requirement (`/vibe-prd`)**
   Ketik `/clear`, lalu:
   ```text
   /vibe-prd Buat sistem manajemen operasional kebun dengan fitur input panen harian, approval asisten kebun, dan dashboard rekapitulasi
   ```
   *Output: `docs/vibe/01-prd.md`*

3. **Tahap 2 — UI/UX & Frontend Design Spec (`/vibe-design`)**
   Ketik `/clear`, lalu:
   ```text
   /vibe-design Desain bersih, mendukung dark mode, tabel responsif untuk mobile dan desktop
   ```
   *Output: `docs/vibe/02-design-spec.md` (berisi Design Tokens, ASCII Wireframe, & 5 State UI: Loading, Empty, Ideal, Partial, Error)*

4. **Tahap 3 — System Analysis & Architecture (`/vibe-sa`)**
   Ketik `/clear`, lalu:
   ```text
   /vibe-sa
   ```
   *Output: `docs/vibe/03-system-analysis.md` (berisi Mermaid ERD Database, Indeks Tabel, Sequence Diagram, & Kontrak JSON API lengkap)*

5. **Tahap 4 — Breakdown Task Teknis (`/vibe-tasks`)**
   Ketik `/clear`, lalu:
   ```text
   /vibe-tasks
   ```
   *Output: `docs/vibe/04-tasks.md` (Daftar task atomik berurutan dari Phase 1 s/d Phase 6)*

6. **Tahap 5 — Eksekusi Coding Bertahap (`/vibe-code`)**
   Ketik `/clear`, lalu:
   ```text
   /vibe-code
   ```
   AI Senior Developer akan otomatis mencari task pertama yang belum selesai (`- [ ]`), mengimplementasikan kodenya, menjalankan *linter/typecheck*, mencentang `[x]` di `04-tasks.md`, dan mencatat log di `05-implementation-log.md`. Lakukan `git commit`, `/clear`, lalu ulangi `/vibe-code` untuk task berikutnya.

7. **Tahap 6 — Code Review & Security Audit (`/vibe-review`)**
   Ketik `/clear`, lalu:
   ```text
   /vibe-review --fix
   ```
   *Output: `docs/vibe/06-code-review.md` (Mengecek kesesuaian kode dengan PRD/SA, celah keamanan OWASP Top 10, N+1 query, dan langsung memperbaikinya jika memakai `--fix`)*

8. **Tahap 7 — Automated Testing & QA (`/vibe-test`)**
   Ketik `/clear`, lalu:
   ```text
   /vibe-test
   ```
   *Output: Menulis & menjalankan Unit/Integration/E2E test serta membuat laporan `docs/vibe/07-qa-report.md`*

9. **Tahap 8 — Cek Progress Kapan Saja (`/vibe-status`)**
   ```text
   /vibe-status
   ```

---

## 🔧 4. Cara Pakai di Project yang Sudah Jalan (Existing Codebase)

Jika kamu ingin menambahkan fitur baru pada project yang sudah ada:
1. Buka terminal/IDE di root repo project tersebut, lalu jalankan **`/vibe-init`**. Agent akan otomatis membaca struktur folder, *framework*, dan konfigurasi database yang sudah ada.
2. Jalankan **`/vibe-prd <fitur baru atau file prd.md>`**.
3. Saat kamu menjalankan **`/vibe-sa`**, System Analyst akan membaca model/migrasi yang sudah ada di repo sehingga tabel dan endpoint baru menyatu rapi tanpa merusak kode lama.

---

## 📋 5. Daftar Lengkap Slash Command & Contoh Pemakaian

| Command / Skill | Fungsi Utama | Contoh Pemanggilan |
| :--- | :--- | :--- |
| `/vibe-init` | Scan repo & buat `00-project-context.md` | `/vibe-init Go ConnectRPC, PostGIS, Flutter` |
| `/vibe-prd` | Buat PRD dari ide atau dari file `prd.md` | `/vibe-prd prd.md` atau `/vibe-prd Buat fitur chat E2EE` |
| `/vibe-design` | Buat spek UI/UX, wireframe & 5 state UI | `/vibe-design Tema minimalis modern` |
| `/vibe-sa` | Buat arsitektur, ERD DB & kontrak API | `/vibe-sa Gunakan Redis untuk caching session` |
| `/vibe-tasks` | Pecah arsitektur jadi daftar task atomik | `/vibe-tasks` |
| `/vibe-code` | Kerjakan 1 task & jalankan verifikasi | `/vibe-code` atau `/vibe-code TASK-002` |
| `/vibe-review` | Audit kode, arsitektur & keamanan | `/vibe-review` atau `/vibe-review --fix` |
| `/vibe-test` | Buat & jalankan automated test + laporan QA | `/vibe-test` atau `/vibe-test US-01` |
| `/vibe-status` | Tampilkan progress bar & status pipeline | `/vibe-status` |

---

## 🗂️ 6. Tabel Direktori Terbaru Masing-Masing Agent (2026)

| AI Coding Agent | Global Slash Command / Workflow | Global Agent Skills (`SKILL.md`) | Global Rules / Memory | Project-Level Path |
| :--- | :--- | :--- | :--- | :--- |
| **Claude Code** | `~/.claude/commands/` | `~/.claude/skills/vibe-*/SKILL.md` | `~/.claude/CLAUDE.md` | `.claude/{commands,skills}/` + `CLAUDE.md` |
| **Antigravity (IDE Ikon Putih)** | `~/.gemini/antigravity/global_workflows/` | `~/.gemini/antigravity/skills/vibe-*/SKILL.md` | `~/.gemini/GEMINI.md` | `.agent/{workflows,skills,rules}/` |
| **OpenCode** | `~/.config/opencode/command/` & `commands/` | `~/.config/opencode/skills/vibe-*/SKILL.md` | `~/.config/opencode/AGENTS.md` | `.opencode/{command,skills}/` + `AGENTS.md` |
| **Codex + ChatGPT App** | `~/.codex/prompts/` | `~/.codex/skills/vibe-*/SKILL.md` & `~/.agents/skills/` | `~/.codex/AGENTS.md` | `.codex/skills/`, `.agents/skills/` + `AGENTS.md` |
| **Cursor** | `~/.cursor/commands/` | `~/.cursor/skills/vibe-*/SKILL.md` | `~/.cursor/rules/*.mdc` | `.cursor/{commands,skills,rules}/` |
| **Windsurf** | `~/.codeium/windsurf/global_workflows/` | — | `~/.codeium/windsurf/memories/global_rules.md` | `.windsurf/{workflows,rules}/` |
| **Roo Code / Cline** | `~/.roo/commands/` | — | `~/.roo/rules/vibe-pipeline.md` | `.roo/{commands,rules}/` & `.clinerules/workflows/` |
