// Heatshrink sleeving (hollow tube)

// Parameters
inner_diameter = 5;   // ID
outer_diameter = 7;   // OD
length         = 50;  // tube length
centered       = true;

// Quality
$fn = 96;

// Small overlap to ensure robust boolean and visible bore
eps = 0.02;

module heatshrink_sleeving(id, od, len, center=true) {
    // Guard against invalid dimensions
    wall_ok = (od > id) && (id > 0) && (len > 0);

    if (wall_ok) {
        difference() {
            cylinder(h=len, r=od/2, center=center);
            // Extend inner cutter slightly so the bore is guaranteed open
            cylinder(h=len + 2*eps, r=id/2, center=center);
        }
    }
}

// Main
heatshrink_sleeving(inner_diameter, outer_diameter, length, centered);