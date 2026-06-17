#!/usr/bin/env bash
# CRAFT-LAD — read-only Mac inventory.
# Run on the Mac:   conda activate text2cad && bash mac_audit.sh
# Then paste the ENTIRE output back.
set -u
cd /Users/mohd7/Local/CRAFT-LAD 2>/dev/null || { echo "!! repo not at /Users/mohd7/Local/CRAFT-LAD — cd there and rerun"; exit 1; }
echo "REPO: $(pwd)"; echo

echo "===== [1] KNOWLEDGE BASE  (pipeline/kb_data) ====="
KB=pipeline/kb_data
for item in chroma_db reference_images documentation.json component_index.json nopscadlib; do
  p="$KB/$item"
  if [ -e "$p" ]; then
    echo "  $item: PRESENT  ($(find "$p" -type f 2>/dev/null | wc -l | tr -d ' ') files, $(du -sh "$p" 2>/dev/null | cut -f1))"
  else
    echo "  $item: *** MISSING ***"
  fi
done
echo "  chroma sqlite: $(find "$KB/chroma_db" -name '*.sqlite3' 2>/dev/null | head -1 || echo none)"
echo

echo "===== [2] DID THE MAC CRAFT RUN ACTUALLY USE THE KB?  (the key question) ====="
python - <<'PY'
import json, os
p="results/nopscadlib/craft/results.json"
if not os.path.exists(p):
    print("  no craft results.json on Mac"); raise SystemExit
d=json.load(open(p)); rs=d.get("results",[]); ok=[r for r in rs if r.get("success")]
m=sum(1 for r in ok if r.get("kb_component_matched"))
print(f"  craft results: total={d.get('total')}  success={len(ok)}  KB matches={m}/{len(ok)}")
if m==0:
    print("  >>> 0 matches: the Mac run was ALSO no-retrieval -> REBUILD + validate the KB.")
else:
    print("  >>> KB works on Mac -> TRANSFER kb_data to the lab PC, then re-run.")
PY
echo

echo "===== [3] chromadb version  (vector store must be read by a compatible version) ====="
python -c "import chromadb; print('  chromadb', chromadb.__version__)" 2>/dev/null || echo "  chromadb NOT importable (activate the env)"
echo

echo "===== [4] GROUND-TRUTH + BASELINE STLs  (git-ignored / possibly uncommitted) ====="
echo "  GT nopscadlib stl:        $(ls ground_truth/nopscadlib/stl/*.stl 2>/dev/null | wc -l | tr -d ' ')"
echo "  craft nopscadlib stl:     $(ls results/nopscadlib/craft/stl/*.stl 2>/dev/null | wc -l | tr -d ' ')"
echo "  gpt4o nopscadlib stl:     $(ls results/nopscadlib/baselines/gpt4o/stl/*.stl 2>/dev/null | wc -l | tr -d ' ')"
echo "  gpt52 nopscadlib stl:     $(ls results/nopscadlib/baselines/gpt52/stl/*.stl 2>/dev/null | wc -l | tr -d ' ')"
for ds in abc slice100k; do
  echo "  $ds craft stl:            $(ls results/$ds/craft/stl/*.stl 2>/dev/null | wc -l | tr -d ' ')"
  echo "  $ds gpt4o/gpt52 stl:      $(ls results/$ds/baselines/gpt4o/stl/*.stl 2>/dev/null | wc -l | tr -d ' ') / $(ls results/$ds/baselines/gpt52/stl/*.stl 2>/dev/null | wc -l | tr -d ' ')"
done
echo

echo "===== [5] OTHER git-ignored artifacts ====="
echo "  component catalog:    $([ -f ground_truth/nopscadlib/nopscadlib_component_catalog.json ] && echo PRESENT || echo missing)"
echo "  FID caches:           $(find metrics -path '*_cache*' -type f 2>/dev/null | wc -l | tr -d ' ') files"
echo "  data/abc views:       $([ -d data/abc/png ] && echo PRESENT || echo missing)"
echo "  data/slice100k views: $([ -d data/slice100k/png ] && echo PRESENT || echo missing)"
echo

echo "===== [6] UNCOMMITTED / UNTRACKED on Mac  (these never reached the lab PC via clone) ====="
git status --short --untracked-files=all 2>/dev/null | grep -E "kb_data|/stl/|_cache|catalog|results/|metrics/|ground_truth/" | head -50
echo "  (total changed/untracked lines: $(git status --short --untracked-files=all 2>/dev/null | wc -l | tr -d ' '))"
echo
echo "===== DONE — paste the whole output back ====="
