$fn=64;

eps = 0.01;

// Bounding box target: 0.1 x 0.0 x 0.1 mm (use very thin Y to approximate 0.0)
L = 0.1;          // overall length along X
H = 0.1;          // overall height along Z
T = 0.001;        // thickness along Y (approx 0.0)
rod_d = 0.02;     // strap/rod thickness (in XZ plane)
boss_d = 0.03;    // end boss diameter (in XZ plane)
boss_len = T;     // boss length along Y (same as thickness)
hex_af = 0.016;   // hex across flats
hex_depth = T*0.8;

module capsule_x(len, d, t){
    // 2D capsule in XZ, extruded along Y
    linear_extrude(height=t, center=true, convexity=10)
        hull(){
            translate([-len/2, 0]) circle(d=d);
            translate([ len/2, 0]) circle(d=d);
        }
}

module u_strap_2d(){
    // U-shape in XZ: outer capsule minus inner capsule, open at top
    difference(){
        union(){
            // outer U
            difference(){
                translate([0, -H/2]) capsule_x(L, rod_d, 0.001); // placeholder thickness ignored in 2D
                translate([0, -H/2]) capsule_x(L-rod_d*1.2, rod_d*0.6, 0.001);
            }
            // remove top to make it a U (open at +Z)
            // (done by subtracting a big rectangle above midline)
        }
        translate([0, 0.02]) square([L*2, H*2], center=true);
    }
}

module u_strap(){
    // Build U in XZ and extrude along Y
    linear_extrude(height=T, center=true, convexity=10)
        difference(){
            // Outer capsule
            translate([0, -H/2]) hull(){
                translate([-L/2, 0]) circle(d=rod_d);
                translate([ L/2, 0]) circle(d=rod_d);
            }
            // Inner capsule to create constant thickness
            translate([0, -H/2]) hull(){
                translate([-(L/2-rod_d*0.6), 0]) circle(d=rod_d*0.6);
                translate([ (L/2-rod_d*0.6), 0]) circle(d=rod_d*0.6);
            }
            // Open the top
            translate([0, H*0.25]) square([L*2, H*2], center=true);
        }
}

module boss_with_hex(xpos){
    translate([xpos, 0, 0])
    difference(){
        cylinder(h=boss_len, d=boss_d, center=true);
        // recessed hex socket along Y axis
        translate([0, 0, boss_len/2 - hex_depth/2 + eps])
            cylinder(h=hex_depth+2*eps, d=hex_af / cos(30), center=true, $fn=6);
    }
}

module part(){
    union(){
        u_strap();
        boss_with_hex(-L/2);
        boss_with_hex( L/2);
    }
}

part();