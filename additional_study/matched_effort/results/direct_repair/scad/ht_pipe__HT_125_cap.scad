$fn=180;

// HT 125 cap (approximation)
// Dimensions in mm (typical for HT DN125):
// - Socket ID ~125
// - Wall thickness ~3.2
// - Socket depth ~55
// - End cap thickness ~6
// - Outer stop ring ~6 radial, ~8 axial
// - Small lead-in chamfer

module ht125_cap(
    id=125,
    wall=3.2,
    socket_depth=55,
    cap_thickness=6,
    ring_radial=6,
    ring_axial=8,
    leadin=1.2,
    fillet=1.2
){
    od = id + 2*wall;
    ring_od = od + 2*ring_radial;
    total_h = socket_depth + cap_thickness;

    difference(){
        // Outer body: socket cylinder + end cap + stop ring
        union(){
            // Socket outer
            cylinder(h=socket_depth, d=od);

            // End cap outer (closed end)
            translate([0,0,socket_depth])
                cylinder(h=cap_thickness, d=od);

            // Stop ring near opening
            translate([0,0,0])
                cylinder(h=ring_axial, d=ring_od);

            // Slight outer edge rounding at opening (simple chamfer-like)
            translate([0,0,0])
                cylinder(h=leadin, d1=ring_od, d2=ring_od-2*leadin);
        }

        // Inner cavity (socket)
        translate([0,0,cap_thickness])
            cylinder(h=socket_depth+0.2, d=id);

        // Inner lead-in chamfer at opening
        translate([0,0,cap_thickness])
            cylinder(h=leadin, d1=id+2*leadin, d2=id);

        // Small inner relief at bottom corner (pseudo-fillet)
        translate([0,0,cap_thickness-0.01])
            cylinder(h=fillet, d1=id, d2=id+2*fillet);
    }
}

ht125_cap();