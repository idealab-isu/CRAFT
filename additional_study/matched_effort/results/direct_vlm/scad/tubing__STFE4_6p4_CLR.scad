$fn = 128;

// PTFE heatshrink sleeving (simple hollow tube model)
// Units: mm

// Parameters
length = 50;          // overall length
id_before = 4.0;      // inner diameter (assumed constant)
od_before = 6.0;      // outer diameter before shrink
shrink_ratio = 2.0;   // e.g., 2:1
shrink_factor = 0.85; // optional additional shrink (0..1), 1 = ideal ratio only

// Derived (approximate) post-shrink OD (kept >= ID)
od_after = max(id_before + 0.2, (od_before / shrink_ratio) * shrink_factor);

// Choose which state to render: "before" or "after"
state = "before"; // ["before","after"]

module sleeving(L=50, ID=4, OD=6) {
    difference() {
        cylinder(h=L, d=OD, center=false);
        translate([0,0,-0.1]) cylinder(h=L+0.2, d=ID, center=false);
    }
}

if (state == "before")
    sleeving(length, id_before, od_before);
else
    sleeving(length, id_before, od_after);