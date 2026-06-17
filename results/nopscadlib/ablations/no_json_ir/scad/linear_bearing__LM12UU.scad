// Linear bearing (LM12UU-like) simplified model
// Target dimensions: 12.0mm bore, 21.0mm OD, 30.0mm length

inner_diameter = 12.0;
outer_diameter = 21.0;
length         = 30.0;

$fn = 160;

module linear_bearing(id=inner_diameter, od=outer_diameter, L=length) {
    eps = 0.02;

    // Simple external features (grooves + end chamfers) while keeping OD/ID/L exact
    groove_w = 2.0;
    groove_d = 0.6;                 // radial depth into OD
    groove_offset = 3.0;            // from each end

    chamfer_h = 0.8;                // axial chamfer height
    chamfer_inset = 0.6;            // radial inset at ends

    difference() {
        // Outer body with end chamfers (still max OD = od, total length = L)
        union() {
            // Main cylinder shortened to make room for chamfers
            translate([0, 0, chamfer_h])
                cylinder(h = L - 2*chamfer_h, d = od);

            // Bottom chamfer
            cylinder(h = chamfer_h, d1 = od, d2 = od - 2*chamfer_inset);

            // Top chamfer
            translate([0, 0, L - chamfer_h])
                cylinder(h = chamfer_h, d1 = od - 2*chamfer_inset, d2 = od);
        }

        // Through bore (ensure it fully cuts)
        translate([0, 0, -eps])
            cylinder(h = L + 2*eps, d = id);

        // Two shallow external grooves near ends
        for (z0 = [groove_offset, L - groove_offset - groove_w]) {
            translate([0, 0, z0])
                cylinder(h = groove_w, d = od - 2*groove_d);
        }
    }
}

linear_bearing();