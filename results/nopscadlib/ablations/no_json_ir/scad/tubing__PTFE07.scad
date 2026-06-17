// PTFE sleeving (hollow tube)

outer_diameter = 10; // mm
inner_diameter = 8;  // mm
length = 100;        // mm
centered = true;

eps = 0.02;          // small overlap to ensure clean boolean

$fn = 128;

module ptfe_sleeving(od, id, h, center=true) {
    // Guard against invalid dimensions
    id2 = min(id, od - 2*eps);

    difference() {
        cylinder(d=od, h=h, center=center);
        // Extend the bore slightly so it fully cuts through even with centering/precision
        cylinder(d=id2, h=h + 2*eps, center=center);
    }
}

ptfe_sleeving(outer_diameter, inner_diameter, length, centered);