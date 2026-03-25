// Long slender spine with repeated perpendicular crossbars ("T" intersections)
// Bounding box target: ~149.2 x 27.2 x 2.6 mm

// Parameters
L = 149.15;                 //[74.575:298.3:0.01]
W = 27.23;                  //[13.615:54.46:0.01]
T = 2.62;                   //[1.31:5.24:0.01]

spine_W = 6.0;              //[3.0:12.0:0.1]      // width of the long spine (Y)
tab_W_along_spine = 2.0;    //[1.0:4.0:0.1]       // thickness of each crossbar along X

tab_count = 12;             //[4:24:1]
end_margin = 6.0;           //[3.0:12.0:0.1]
tab_pitch = 11.1954545455;  //[5.5977:22.3909:0.0001]

overlap = 0.8;              //[0.5:2.0:0.1]       // overlap for robust unions/differences

mount_hole_d = 3.6;         //[2.0:6.0:0.1]
mount_hole_x_inset = 10.0;  //[5.0:20.0:0.1]

decor_cutout_d = 4.0;       //[2.0:8.0:0.1]
decor_cutout_count = 5;     //[1:12:1]

$fn = 64;

// --- Core geometry (connected solid) ---
module spine_bar() {
    cube([L, spine_W, T], center=true);
}

module crossbar_tab(xpos) {
    // Full-width crossbar centered on spine, forming a "T" intersection
    translate([xpos, 0, 0])
        cube([tab_W_along_spine, W, T], center=true);
}

module crossbar_tabs_array() {
    union() {
        for (i = [0:tab_count-1]) {
            // Place tabs evenly along length, within end margins
            xpos = -L/2 + end_margin + i*tab_pitch;
            crossbar_tab(xpos);
        }
    }
}

module rail_solid() {
    // One connected solid: spine + tabs overlap in volume
    union() {
        spine_bar();
        crossbar_tabs_array();
    }
}

// --- Holes / cutouts (subtractive) ---
module mounting_holes() {
    for (sx = [-1, 1]) {
        translate([sx*(L/2 - mount_hole_x_inset), 0, 0])
            cylinder(h=T + 2*overlap, r=mount_hole_d/2, center=true);
    }
}

module decorative_cutouts() {
    // Centered between tabs (odd multiples of half-pitch), clamped to stay inside length
    for (i = [0:decor_cutout_count-1]) {
        xpos = -L/2 + end_margin + (2*i + 1)*tab_pitch;
        if (xpos > -L/2 + end_margin && xpos < L/2 - end_margin)
            translate([xpos, 0, 0])
                cylinder(h=T + 2*overlap, r=decor_cutout_d/2, center=true);
    }
}

// Final model
difference() {
    rail_solid();
    mounting_holes();
    decorative_cutouts();
}