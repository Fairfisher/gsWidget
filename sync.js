#!/usr/bin/env node
/**
 * sync.js — reads metadata headers from snippets/*.dart and writes assets/snippets.json
 *
 * Header format (top of each .dart file):
 *   // title: My Widget
 *   // description: What it does
 *   // category: buttons | cards | inputs | animations | navigation | lists | dialogs | charts | layouts | loaders | typography | forms | misc
 *   // tags: glass, blur, modern
 *   // author: Your Name
 *   // featured: true
 *   // prompt: The prompt used to generate this widget (optional)
 *   // model: claude-opus-4-7 (optional)
 *
 * Likes are NOT in the header — they are preserved from the existing snippets.json.
 * New snippets start at 0.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const SNIPPETS_DIR = path.join(__dirname, 'snippets');
const OUTPUT = path.join(__dirname, 'assets', 'snippets.json');

const VALID_CATEGORIES = [
  'buttons', 'cards', 'inputs', 'animations', 'navigation',
  'lists', 'dialogs', 'charts', 'layouts', 'loaders',
  'typography', 'forms', 'misc',
];

// Load existing likes so they are never reset by a sync
function loadExistingLikes() {
  if (!fs.existsSync(OUTPUT)) return {};
  try {
    const data = JSON.parse(fs.readFileSync(OUTPUT, 'utf8'));
    return Object.fromEntries((data.snippets || []).map(s => [s.slug, s.likes ?? 0]));
  } catch {
    return {};
  }
}

function parseHeader(content, filename) {
  const lines = content.split('\n');
  const meta = {};
  for (const line of lines) {
    if (!line.startsWith('//')) break;
    const match = line.match(/^\/\/\s+(\w+):\s*(.+)$/);
    if (match) meta[match[1].trim()] = match[2].trim();
  }

  const slug = path.basename(filename, '.dart');
  const id = slug + '-' + crypto.createHash('md5').update(slug).digest('hex').slice(0, 6);

  const errors = [];
  if (!meta.title) errors.push('missing title');
  if (!meta.description) errors.push('missing description');
  if (!meta.category) errors.push('missing category');
  else if (!VALID_CATEGORIES.includes(meta.category)) {
    errors.push(`unknown category "${meta.category}" — valid: ${VALID_CATEGORIES.join(', ')}`);
  }

  if (errors.length) {
    console.error(`  ✗ ${slug}: ${errors.join(', ')}`);
    return null;
  }

  return {
    id,
    slug,
    title: meta.title,
    description: meta.description,
    category: meta.category,
    tags: meta.tags ? meta.tags.split(',').map(t => t.trim()).filter(Boolean) : [],
    authorName: meta.author || 'gsWidget',
    authorAvatarUrl: null,
    featured: meta.featured === 'true',
    createdAt: meta.createdAt || new Date().toISOString().split('T')[0] + 'T00:00:00.000Z',
    prompt: meta.prompt || null,
    model: meta.model || null,
  };
}

function sync() {
  if (!fs.existsSync(SNIPPETS_DIR)) {
    console.error('snippets/ folder not found');
    process.exit(1);
  }

  const existingLikes = loadExistingLikes();

  const files = fs.readdirSync(SNIPPETS_DIR)
    .filter(f => f.endsWith('.dart'))
    .sort();

  console.log(`\nReading ${files.length} snippets...\n`);

  const snippets = [];
  for (const file of files) {
    const content = fs.readFileSync(path.join(SNIPPETS_DIR, file), 'utf8');
    const entry = parseHeader(content, file);
    if (entry) {
      entry.likes = existingLikes[entry.slug] ?? 0;
      snippets.push(entry);
      console.log(`  ✓ ${entry.slug} — ${entry.title}`);
    }
  }

  fs.mkdirSync(path.dirname(OUTPUT), { recursive: true });
  fs.writeFileSync(OUTPUT, JSON.stringify({ snippets }, null, 2) + '\n');

  console.log(`\n${snippets.length}/${files.length} snippets written to assets/snippets.json\n`);

  if (snippets.length < files.length) {
    console.warn('Fix the errors above and re-run sync.js\n');
    process.exit(1);
  }
}

sync();
