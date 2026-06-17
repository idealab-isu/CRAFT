// Simple hollow cylindrical sleeve (tube/spacer) with concentric through-bore
// Bounding box: 6.3 x 6.3 x 25.7 mm (approx from OD and L)

OD = 6.35;      // outer diameter (mm)
ID = 3.175;     // inner diameter (mm)
L  = 25.65;     // length/height (mm)

overlap = 0.2;  // ensures clean through-cut

$fn = 96;

module sleeve(od, id, h) {
    difference() {
        cylinder(h=h, r=od/2, center=true);
        cylinder(h=h + 2*overlap, r=id/2, center=true);
    }
}

sleeve(OD, ID, L);