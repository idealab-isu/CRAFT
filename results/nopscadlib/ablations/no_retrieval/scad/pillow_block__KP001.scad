// Pillow block bearing (UCP-style simplified)
// Target: 12.0mm shaft bore, 71.0mm x 56.0mm base
// One connected solid, all placements derived from dimensions (no arbitrary offsets).

$fn = 128;

// -------------------- Parameters --------------------
base_L = 71.0;                 // base length (X)
base_W = 56.0;                 // base width  (Y)
base_T = 8.0;                  // base thickness (Z)

shaft_d = 12.0;                // shaft diameter
bore_clearance = 0.2;          // clearance on bore diameter

// Typical UCP has 2 mounting holes (one per side)
mount_hole_d = 9.0;            // mounting through holes
mount_hole_spacing_L = 54.0;   // hole spacing along X (center-to-center)

counterbore_d = 16.0;
counterbore_depth = 3.0;

overlap = 1.0;                 // overlap for robust unions/differences

// Housing geometry (simplified pillow block)
housing_L = 50.0;              // housing length along X
housing_W = 34.0;              // housing width along Y
bore_center_h = 18.0;          // bore center height above base top

housing_wall_T = 6.0;          // used for proportions
insert_OD = 28.0;              // outer "bearing insert" seat diameter (visual)
insert_seat_depth = 3.0;       // shallow seat depth (visual)

grease_boss_d = 10.0;
grease_boss_h = 8.0;

set_screw_d = 5.0;
set_screw_z_offset = 4.0;

// Fillet (kept small; avoid heavy minkowski on whole model)
fillet_r = 2.0;

// -------------------- Derived --------------------
base_top_z = base_T/2;
bore_z = base_top_z + bore_center_h;

// Outer pillow radius (arched housing)
pillow_r = max(housing_W/2, insert_OD/2 + housing_wall_T);

// Ensure housing reaches above the arch
housing_total_above_base = max(bore_center_h + pillow_r*0.85, bore_center_h + 10);

// Base corner radius
base_corner_r = min(6, min(base_L, base_W)/8);

// -------------------- Helpers --------------------
module rounded_plate(L, W, T, r) {
    linear_extrude(height=T, center=true)
        offset(r=r)
            square([max(0.01, L-2*r), max(0.01, W-2*r)], center=true);
}

module base_solid() {
    rounded_plate(base_L, base_W, base_T, r=base_corner_r);
}

module housing_outer() {
    // Typical pillow block: pedestal + arched saddle + small top cap + grease boss
    union() {
        // Pedestal block sitting on base (overlaps into base for connectivity)
        translate([0, 0, base_top_z + housing_total_above_base/2 - overlap])
            cube([housing_L, housing_W, housing_total_above_base], center=true);

        // Arched saddle (cylinder along X) centered at bore height
        rotate([0, 90, 0])
            translate([0, 0, bore_z])
                cylinder(r=pillow_r, h=housing_L + 2*overlap, center=true);

        // Top cap pad (suggest split cap)
        cap_T = 6.0;
        cap_z = base_top_z + housing_total_above_base - cap_T/2 - overlap;
        translate([0, 0, cap_z])
            cube([housing_L*0.92, housing_W*0.92, cap_T], center=true);

        // Grease boss on top center (overlaps into cap)
        boss_z = cap_z + cap_T/2 + grease_boss_h/2 - overlap;
        translate([0, 0, boss_z])
            cylinder(r=grease_boss_d/2, h=grease_boss_h, center=true);
    }
}

module shaft_bore_cut() {
    // Through-bore along X through entire housing (visible through housing)
    rotate([0, 90, 0])
        translate([0, 0, bore_z])
            cylinder(r=(shaft_d + bore_clearance)/2, h=housing_L + 6*overlap, center=true);
}

module insert_seat_cut() {
    // Shallow seat for insert (visual) centered in housing
    rotate([0, 90, 0])
        translate([0, 0, bore_z])
            cylinder(r=insert_OD/2, h=insert_seat_depth + 2*overlap, center=true);
}

module mounting_holes_cut() {
    // 2 through-holes (one per side) typical of UCP pillow blocks
    x1 = mount_hole_spacing_L/2;
    y0 = 0;

    for (sx = [-1, 1])
        translate([sx*x1, y0, 0])
            cylinder(r=mount_hole_d/2, h=base_T + 6*overlap, center=true);
}

module mounting_counterbores_cut() {
    // Counterbore from top face of base downward
    x1 = mount_hole_spacing_L/2;
    y0 = 0;
    zc = base_top_z - counterbore_depth/2;

    for (sx = [-1, 1])
        translate([sx*x1, y0, zc])
            cylinder(r=counterbore_d/2, h=counterbore_depth + 6*overlap, center=true);
}

module set_screw_cuts() {
    // Two set-screw holes from front/back (along Y) into bore region
    // Positioned at +/- housing_L/4 along X, at bore height + offset.
    for (sx = [-1, 1]) {
        rotate([90, 0, 0])  // cylinder axis along Y
            translate([sx*(housing_L/4), 0, bore_z + set_screw_z_offset])
                cylinder(r=set_screw_d/2, h=housing_W + 6*overlap, center=true);
    }
}

module base_softened() {
    // Fillet only the base for performance; keep as one connected solid via overlap with housing
    minkowski() {
        base_solid();
        sphere(r=fillet_r);
    }
}

// -------------------- Final Model --------------------
difference() {
    union() {
        base_softened();
        housing_outer();
    }

    // Cuts
    shaft_bore_cut();
    insert_seat_cut();
    mounting_holes_cut();
    mounting_counterbores_cut();
    set_screw_cuts();
}