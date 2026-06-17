$fn=96;

// Linear bearing block for 6.0mm shaft
// Overall block size: 30.0mm x 25.0mm (X x Y)
// Thickness chosen as a reasonable default for a small bearing block.
shaft_d = 6.0;

block_x = 30.0;
block_y = 25.0;
block_z = 12.0;

corner_r = 2.0;

// Shaft bore clearance and clamp slit
bore_clear = 0.3;                 // diameter clearance
bore_d = shaft_d + bore_clear;

slit_w = 1.2;                     // clamp slit width
slit_x = block_x;                 // slit runs across full X

// Mounting holes (4x) - typical M3 clearance
mount_hole_d = 3.4;
mount_edge_x = 5.0;               // distance from X edges to hole centers
mount_edge_y = 5.0;               // distance from Y edges to hole centers

// Optional counterbore for socket head cap screws
counterbore_d = 6.2;
counterbore_h = 3.0;

// Clamp screw hole (across Y) to pinch slit
clamp_hole_d = 3.2;               // M3 clearance
clamp_nut_flat = 5.7;             // M3 hex nut across flats
clamp_nut_thick = 2.6;
clamp_hole_z = block_z * 0.65;    // height of clamp screw axis

module rounded_block(x,y,z,r){
    // Rounded rectangle prism via hull of corner cylinders
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2 - r), sy*(y/2 - r), 0])
                cylinder(h=z, r=r);
        }
    }
}

module hex_prism(af, h){
    // Regular hex prism with across-flats = af
    // For a regular hex, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

difference(){
    // Body
    translate([0,0,0])
        rounded_block(block_x, block_y, block_z, corner_r);

    // Shaft bore along X axis, centered in Y and Z
    translate([0, 0, block_z/2])
        rotate([0,90,0])
            cylinder(h=block_x + 2, d=bore_d, center=true);

    // Clamp slit from top down to bore (opens the bore)
    // Slit centered in Y, runs full X, starts at top surface
    translate([0, 0, block_z/2])
        translate([0, 0, block_z/2])
            cube([slit_x + 2, slit_w, block_z + 2], center=true);

    // Mounting holes (4x) through Z with counterbores on top
    for (sx=[-1,1], sy=[-1,1]){
        xh = sx*(block_x/2 - mount_edge_x);
        yh = sy*(block_y/2 - mount_edge_y);

        // Through hole
        translate([xh, yh, block_z/2])
            cylinder(h=block_z + 2, d=mount_hole_d, center=true);

        // Counterbore from top
        translate([xh, yh, block_z - counterbore_h/2])
            cylinder(h=counterbore_h + 0.2, d=counterbore_d, center=true);
    }

    // Clamp screw hole across Y (perpendicular to slit), with nut trap on one side
    translate([0, 0, clamp_hole_z])
        rotate([90,0,0])
            cylinder(h=block_y + 2, d=clamp_hole_d, center=true);

    // Nut trap on +Y side
    translate([0, block_y/2 - clamp_nut_thick/2, clamp_hole_z])
        rotate([90,0,0])
            hex_prism(clamp_nut_flat, clamp_nut_thick + 0.4);

    // Screw head clearance on -Y side (simple counterbore)
    translate([0, -block_y/2 + counterbore_h/2, clamp_hole_z])
        rotate([90,0,0])
            cylinder(h=counterbore_h + 0.4, d=counterbore_d, center=true);
}