// Standoff pillar: M3 thread, 20mm long, diameter unspecified -> use common standoff OD (6mm)
// One connected solid: cylindrical standoff body with internal M3 clearance hole (no floating parts).

$fn = 96;

// Parameters
length_mm        = 20.0;   // overall length
standoff_od_mm   = 6.0;    // typical M3 standoff outer diameter when unspecified
hole_d_mm        = 3.0;    // 3.0mm thread spec -> represent as through hole for M3 screw
chamfer_mm       = 0.6;    // small edge break for printability/fit

module standoff_pillar(L=20, od=6, hole_d=3, chamfer=0.6) {
    r_out = od/2;
    r_hole = hole_d/2;
    c = min(chamfer, r_out - 0.2);

    difference() {
        // Outer body with simple chamfers (still one connected solid after subtraction)
        union() {
            cylinder(h=L, r=r_out, center=false);

            // Top chamfer (overlaps into body)
            translate([0,0,L - c])
                cylinder(h=c, r1=r_out, r2=max(0.01, r_out - c), center=false);

            // Bottom chamfer (overlaps into body)
            cylinder(h=c, r1=max(0.01, r_out - c), r2=r_out, center=false);
        }

        // Through hole (slightly extended to guarantee clean cut)
        eps = 0.05;
        translate([0,0,-eps])
            cylinder(h=L + 2*eps, r=r_hole, center=false);
    }
}

standoff_pillar(
    L=length_mm,
    od=standoff_od_mm,
    hole_d=hole_d_mm,
    chamfer=chamfer_mm
);