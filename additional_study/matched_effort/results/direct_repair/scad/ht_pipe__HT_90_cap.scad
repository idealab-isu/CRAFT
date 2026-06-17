$fn=128;

// HT pipe: 90° cap (end cap for HT drainage pipe)
// Parametric, approximates common HT dimensions.
// Units: mm

// -------- Parameters --------
dn = 50;                 // nominal diameter (common: 32, 40, 50, 75, 110)
wall = 1.8;              // pipe wall thickness
cap_depth = 35;          // insertion depth / socket depth
cap_wall = 3.0;          // cap outer wall thickness around socket
end_thickness = 4.0;     // thickness of closed end
lip_height = 3.0;        // small outer lip at opening
lip_overhang = 1.5;      // lip radial overhang
chamfer = 1.2;           // lead-in chamfer at opening

// Derived
id = dn;                 // inner diameter of pipe
od = dn + 2*wall;        // outer diameter of pipe
socket_od = od + 2*cap_wall;
socket_id = od + 0.6;    // clearance for pipe OD (approx)
cap_total_len = cap_depth + end_thickness;

// -------- Helpers --------
module chamfered_cylinder(h, r1, r2) {
    cylinder(h=h, r1=r1, r2=r2);
}

module ht_90_cap() {
    difference() {
        union() {
            // Main outer body (socket + closed end)
            cylinder(h=cap_total_len, d=socket_od);

            // Outer lip at opening
            translate([0,0,0])
                cylinder(h=lip_height, d=socket_od + 2*lip_overhang);
        }

        // Hollow socket cavity
        translate([0,0,0])
            cylinder(h=cap_depth, d=socket_id);

        // Inner cavity behind socket (leave end_thickness)
        translate([0,0,cap_depth])
            cylinder(h=end_thickness + 0.01, d=socket_od - 2*cap_wall);

        // Lead-in chamfer at opening (inside)
        translate([0,0,0])
            chamfered_cylinder(chamfer, r1=(socket_id/2) + chamfer, r2=(socket_id/2));

        // Slight outer chamfer at opening edge (outside)
        translate([0,0,0])
            chamfered_cylinder(chamfer, r1=(socket_od/2), r2=(socket_od/2) - chamfer);
    }
}

// Render
ht_90_cap();