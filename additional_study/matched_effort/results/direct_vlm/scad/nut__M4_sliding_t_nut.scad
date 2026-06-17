$fn = 64;

// Parameters (mm)
screw_d = 4.0;          // screw diameter
nut_af  = 6.0;          // across flats
thick   = 3.7;          // thickness

// Practical clearances
hole_d  = screw_d + 0.4;   // clearance for M4-ish screw
chamfer = 0.35;            // edge chamfer height
corner_r = 0.35;           // slight rounding via minkowski (kept small)

// T-slot nut proportions (generic)
body_len = 12.0;
body_w   = 8.0;

// Anti-rotation nibs (small wings)
nib_w = 1.2;
nib_h = 0.8;
nib_len = 6.0;

module hex_prism(af, h){
    // Regular hex with given across-flats (af)
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height=h, center=true)
        polygon(points=[ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module chamfered_block(l,w,h,c){
    // Simple chamfer by subtracting 4 wedges on top and bottom edges
    difference(){
        cube([l,w,h], center=true);

        // Top chamfers
        translate([0,0, h/2 - c/2]){
            // along X edges
            for (sy=[-1,1])
                translate([0, sy*(w/2 - c/2), 0])
                    rotate([0,90,0])
                        linear_extrude(height=l+0.2, center=true)
                            polygon(points=[[0,0],[c,0],[0,c]]);
            // along Y edges
            for (sx=[-1,1])
                translate([sx*(l/2 - c/2), 0, 0])
                    rotate([90,0,0])
                        linear_extrude(height=w+0.2, center=true)
                            polygon(points=[[0,0],[c,0],[0,c]]);
        }

        // Bottom chamfers
        translate([0,0,-h/2 + c/2]){
            for (sy=[-1,1])
                translate([0, sy*(w/2 - c/2), 0])
                    rotate([0,90,0])
                        linear_extrude(height=l+0.2, center=true)
                            polygon(points=[[0,0],[c,0],[0,c]]);
            for (sx=[-1,1])
                translate([sx*(l/2 - c/2), 0, 0])
                    rotate([90,0,0])
                        linear_extrude(height=w+0.2, center=true)
                            polygon(points=[[0,0],[c,0],[0,c]]);
        }
    }
}

module tslot_nut(){
    difference(){
        // Main body with slight rounding
        minkowski(){
            chamfered_block(body_len, body_w, thick - 2*corner_r, chamfer);
            sphere(r=corner_r);
        }

        // Through hole
        cylinder(d=hole_d, h=thick+2, center=true);

        // Hex pocket (for 6mm AF nut capture), shallow from one side
        // Pocket depth ~ 2.4mm (leaves material at bottom)
        pocket_depth = min(2.4, thick-0.8);
        translate([0,0, thick/2 - pocket_depth/2])
            hex_prism(nut_af + 0.2, pocket_depth + 0.2);
    }

    // Anti-rotation nibs (small wings on sides)
    for (sy=[-1,1]){
        translate([0, sy*(body_w/2 + nib_w/2 - 0.05), 0])
            chamfered_block(nib_len, nib_w, nib_h, 0.2);
    }
}

tslot_nut();