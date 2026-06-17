# CRAFT — Camera-Ready Compliance Pass (changelog)

Conference: IEEE LAD 2026 (Long paper, up to 6 pages excl. references).
This pass only makes the paper **compliant with the camera-ready instructions**.
The 6-page trim and the integration of the new ablation/editability content are
**separate, later steps** (listed at the bottom).

Every item below was checked by compiling the actual paper with the real
`IEEEtran.cls` and inspecting the output PDF (fonts, page size, page numbers,
bookmarks, links, and the copyright notice).

---

## A. Already compliant — no change needed

| Requirement | Status | Evidence |
|---|---|---|
| IEEE two-column conference format | OK | `\documentclass[conference]{IEEEtran}` |
| US Letter, 8.5″ × 11″ | OK | compiled PDF page size = 612 × 792 pt (letter) |
| No page numbers | OK | IEEEtran conference omits them by default; confirmed none on any page. **Do NOT add `\pagestyle{empty}`** — it also deletes the copyright notice. |
| All fonts embedded | OK | every font in the compiled PDF reports `emb=yes` (incl. figure fonts). PDF eXpress will re-verify. |

## B. Changes applied (3)

**1. Copyright clearance notice — REQUIRED, was missing.**
Category = "all other papers" (authors are at Iowa State / NYU — not US-government,
Crown, or EU employees), so the IEEE notice applies.
Add immediately after `\begin{document}`:

```latex
\IEEEoverridecommandlockouts
\IEEEpubid{\makebox[\columnwidth]{979-8-3195-1246-8-0/26/\$31.00~\copyright2026~IEEE\hfill}\hspace{\columnsep}\makebox[\columnwidth]{ }}
```

Notes: the `$` in `$31.00` is escaped as `\$` (the raw instruction text would
break LaTeX otherwise). Verified to render at the bottom of page 1 as
`979-8-3195-1246-8-0/26/$31.00 ©2026 IEEE`.

**2. Remove PDF bookmarks and links — REQUIRED.**
The current `hyperref` setup creates blue clickable links and PDF bookmarks
(measured: 24 link annotations + a bookmarks/outline tree). Change:

```latex
% was: \usepackage{hyperref}
\usepackage[draft]{hyperref}
```

and delete the now-redundant block:

```latex
% delete this whole block:
\hypersetup{
    colorlinks, linkcolor={blue}, citecolor={blue}, urlcolor={blue},
    breaklinks=true, plainpages=true
}
```

`draft` mode turns hyperref into a no-op: **0 links, 0 bookmarks**, while every
cross-reference (`\figref`, `\tabref`, `\secref`, citations) still prints its
number normally — verified (no `??` anywhere). (Lighter alternative if you ever
want internal navigation back: `\usepackage[hidelinks]{hyperref}` + `bookmarks=false`,
but that leaves invisible clickable links, so `draft` is the strictly-compliant choice.)

**3. Page numbers — NO change.** Already absent. Explicitly do **not** add
`\pagestyle{empty}`, because it suppresses the copyright notice from change #1.

## C. Deferred (after compliance is confirmed)

1. **6-page limit (excl. references).** With the appendices and the staged
   camera-ready additions, the draft is currently well over 6 pages. Trim +
   integrate next.
2. **Integrate the camera-ready additions** into the body: refreshed geometry
   table replaces Table II; ablation and editability become Results subsections;
   FID note + typo fixes inline.
3. **PDF eXpress** (https://ieee-pdf-express.org, conference id **71857X**):
   check/convert the PDF, then click **Approve** — without Approve, the
   publication chair never receives the file.
4. **IEEE Copyright Form** — separate emailed link; complete it.
5. **Figure fonts** — PDF eXpress re-checks embedding; our local build embedded
   all of them, so this should pass.

## Verification environment note
The local sandbox did not have `IEEEtran.bst`, so the reference list rendered
empty in the test build only — this does not affect your Overleaf project, which
has the style file. Format, page size, page numbers, bookmarks, links, fonts,
and the copyright notice were all verified on the compiled PDF.
