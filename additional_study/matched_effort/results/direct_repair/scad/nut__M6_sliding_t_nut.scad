$fn=96;

// T-slot nut parameters (mm)
screw_d = 6.0;          // screw size (M6 nominal)
clearance_d = 6.6;      // through-hole clearance for M6
across_flats = 8.0;     // hex across flats
thickness = 6.6;        // nut thickness

// Typical T-slot nut body proportions (adjust if needed)
body_len = 18.0;        // along slot
body_w   = 11.0;        // across slot
top_w    = 8.0;         // narrower top to fit slot opening
top_h    = 2.0;         // height of the narrower top section
chamfer  = 0.6;         // edge chamfer

module chamfered_box(size=[10,10,10], c=0.5){
    // Minkowski chamfer approximation using a small octahedron-like hull
    // (keeps renderable and robust)
    sx=size[0]; sy=size[1]; sz=size[2];
    c2 = min(c, sx/4, sy/4, sz/4);
    minkowski(){
        cube([sx-2*c2, sy-2*c2, sz-2*c2], center=true);
        // diamond-ish kernel
        hull(){
            translate([ c2, 0, 0]) sphere(r=0.01);
            translate([-c2, 0, 0]) sphere(r=0.01);
            translate([0,  c2, 0]) sphere(r=0.01);
            translate([0, -c2, 0]) sphere(r=0.01);
            translate([0, 0,  c2]) sphere(r=0.01);
            translate([0, 0, -c2]) sphere(r=0.01);
        }
    }
}

module tslot_nut(){
    difference(){
        union(){
            // Main body
            chamfered_box([body_len, body_w, thickness], chamfer);

            // Narrow top section (fits slot opening)
            translate([0, 0, (thickness/2 - top_h/2)])
                chamfered_box([body_len, top_w, top_h], chamfer/2);
        }

        // Through clearance hole
        cylinder(d=clearance_d, h=thickness+2, center=true);

        // Hex recess for 8mm across flats (for holding with key/driver)
        // Depth: about half thickness
        hex_depth = thickness*0.55;
        translate([0,0, thickness/2 - hex_depth/2 + 0.01])
            cylinder(h=hex_depth+0.02, r=across_flats/(2*cos(30)), $fn=6, center=true);

        // Small lead-in chamfer on hole
        translate([0,0, thickness/2 - 0.2])
            cylinder(h=0.8, d1=clearance_d+1.2, d2=clearance_d, center=false);
        translate([0,0, -thickness/2 - 0.6])
            cylinder(h=0.8, d1=clearance_d, d2=clearance_d+1.2, center=false);
    }
}

tslot_nut();