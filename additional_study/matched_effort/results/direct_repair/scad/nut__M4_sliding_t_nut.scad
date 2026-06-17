$fn = 80;

// Parameters (mm)
screw_d = 4.0;          // screw diameter
clearance = 0.4;        // clearance for screw hole
hole_d = screw_d + clearance;

across_flats = 6.0;     // hex across flats
thickness = 3.7;        // nut thickness

// T-slot nut body (generic): rectangular with slight edge chamfers
body_len = 12.0;
body_w   = 8.0;
chamfer  = 0.6;

// Helper: 2D hex polygon by across-flats
module hex2d(af){
    r = af / sqrt(3); // circumradius for flat-to-flat = sqrt(3)*r
    polygon(points=[
        [ r, 0],
        [ r/2,  r*sqrt(3)/2],
        [-r/2,  r*sqrt(3)/2],
        [-r, 0],
        [-r/2, -r*sqrt(3)/2],
        [ r/2, -r*sqrt(3)/2]
    ]);
}

// Helper: chamfered box via hull of two offset rectangles
module chamfered_box(l,w,h,c){
    c = min(c, min(l,w)/4);
    hull(){
        translate([0,0,0]) linear_extrude(height=0.01) square([l,w], center=true);
        translate([0,0,h]) linear_extrude(height=0.01) square([l-2*c,w-2*c], center=true);
    }
}

difference(){
    // Body
    chamfered_box(body_len, body_w, thickness, chamfer);

    // Through hole for screw
    translate([0,0,-0.5])
        cylinder(d=hole_d, h=thickness+1.0);

    // Hex pocket on top (for 6mm AF nut capture), shallow
    pocket_depth = min(2.2, thickness-0.6);
    translate([0,0,thickness - pocket_depth])
        linear_extrude(height=pocket_depth+0.2)
            hex2d(across_flats);
}