$fn = 160;

// Heat-set insert (simplified) parameters
od = 15.0;          // outer diameter (mm)
len = 12.0;         // length (mm)
screw_d = 6.0;      // nominal screw diameter (mm)

// Internal thread approximation (clearance hole)
id_clear = 6.4;     // clearance for M6-ish screw (mm)

// Outer knurl/ribs approximation
rib_count = 24;
rib_depth = 0.6;    // radial depth of ribs (mm)
rib_width = 0.9;    // tangential width of ribs (mm)

// Lead-in chamfers
chamfer = 0.8;      // mm
bore_chamfer = 0.6; // mm

module heat_set_insert() {
    difference() {
        // Outer body with ribs
        union() {
            // Base cylinder
            cylinder(d = od - 2*rib_depth, h = len);

            // Ribs
            for (i = [0 : rib_count - 1]) {
                rotate([0,0, i * 360 / rib_count])
                    translate([(od/2 - rib_depth/2), 0, 0])
                        cube([rib_depth, rib_width, len], center = true);
            }

            // Outer chamfers (both ends)
            translate([0,0,0])
                cylinder(d1 = od - 2*rib_depth, d2 = od - 2*rib_depth - 2*chamfer, h = chamfer);
            translate([0,0,len - chamfer])
                cylinder(d1 = od - 2*rib_depth - 2*chamfer, d2 = od - 2*rib_depth, h = chamfer);
        }

        // Through bore
        translate([0,0,-0.2])
            cylinder(d = id_clear, h = len + 0.4);

        // Bore chamfers (both ends)
        translate([0,0,0])
            cylinder(d1 = id_clear + 2*bore_chamfer, d2 = id_clear, h = bore_chamfer);
        translate([0,0,len - bore_chamfer])
            cylinder(d1 = id_clear, d2 = id_clear + 2*bore_chamfer, h = bore_chamfer);
    }
}

heat_set_insert();