$fn=128;

// HT 32 cap (approximation)
// Typical HT 32 OD ~ 40 mm. Cap with socket and closed end.

od = 40;            // outer diameter of cap
wall = 2.2;         // wall thickness
id = od - 2*wall;   // inner diameter
socket_depth = 28;  // insertion depth
end_thickness = 3;  // closed end thickness
lip = 2.0;          // small outer lip height
lip_over = 1.2;     // lip radial overhang

module ht32_cap() {
    difference() {
        union() {
            // main outer body
            cylinder(h=socket_depth + end_thickness, d=od);

            // small outer lip at opening
            translate([0,0,socket_depth + end_thickness - lip])
                cylinder(h=lip, d=od + 2*lip_over);
        }

        // inner cavity (open at bottom, closed at top by end_thickness)
        translate([0,0,0])
            cylinder(h=socket_depth, d=id);

        // slight lead-in chamfer at opening (inside)
        translate([0,0,0])
            cylinder(h=2.0, d1=id+2.0, d2=id);
    }
}

ht32_cap();