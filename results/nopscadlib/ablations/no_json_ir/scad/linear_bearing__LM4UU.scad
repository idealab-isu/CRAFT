$fn = 128;

// Linear bearing target dimensions
id = 4.0;     // bore diameter
od = 8.0;     // outer diameter
len = 12.0;   // overall length

// Small epsilon to ensure clean boolean operations
eps = 0.02;

// Simple sleeve-style linear bearing with small end chamfers and shallow outer grooves
module linear_bearing(id=4.0, od=8.0, len=12.0) {
    wall = (od - id)/2;
    chamfer = min(0.6, wall*0.9);          // subtle end chamfer
    groove_w = min(1.0, len/8);            // shallow outer grooves for "bearing-like" detail
    groove_d = min(0.25, wall*0.35);

    difference() {
        // Outer body with end chamfers (via hull of two slightly different diameters)
        union() {
            // Main outer cylinder
            cylinder(d=od, h=len, center=true);

            // End chamfers: remove later by subtracting cones? Instead, add a slight bevel by hulling
            // a slightly smaller diameter at the ends (keeps one connected solid).
            hull() {
                translate([0,0,-len/2 + chamfer/2])
                    cylinder(d=od - 2*chamfer, h=chamfer, center=true);
                translate([0,0,-len/2 + chamfer + eps])
                    cylinder(d=od, h=eps*2, center=true);
            }
            hull() {
                translate([0,0, len/2 - chamfer/2])
                    cylinder(d=od - 2*chamfer, h=chamfer, center=true);
                translate([0,0, len/2 - chamfer - eps])
                    cylinder(d=od, h=eps*2, center=true);
            }
        }

        // Through bore (ensure it fully cuts through)
        cylinder(d=id, h=len + 2*eps, center=true);

        // Two shallow outer grooves (purely cosmetic), cut into OD
        for (z = [-(len/2 - groove_w*1.5), (len/2 - groove_w*1.5)]) {
            translate([0,0,z])
                difference() {
                    cylinder(d=od + 2*eps, h=groove_w, center=true);
                    cylinder(d=od - 2*groove_d, h=groove_w + 2*eps, center=true);
                }
        }
    }
}

linear_bearing(id=id, od=od, len=len);