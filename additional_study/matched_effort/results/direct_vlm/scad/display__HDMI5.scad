$fn=64;

// HDMI display 5"
// Overall PCB: 121 x 76 x 2.85
pcb_size = [121, 76, 2.85];

// PCB offset (relative placement reference)
pcb_offset = [0, 0, 1.9];

// Aperture (window cutout): corners given as [[x1,y1],[x2,y2,zdepth]]
aperture_min = [-54, -30.225];
aperture_max = [ 54,  34.575];
aperture_depth = 0.5;

// Touch screen (outer active area / cover): [[x1,y1],[x2,y2,zdepth]]
ts_min = [-58.7, -34];
ts_max = [ 58.7,  36.25];
ts_depth = 1;

// Thread length (standoff/holes depth hint)
thread_length = 2;

// Clearance needed for TS ribbon: rectangle [[x1,y1],[x2,y2]]
ribbon_min = [-2.5, -39];
ribbon_max = [10.5, -33];
ribbon_clear_z = 10; // arbitrary tall cut

// Derived sizes
aperture_size = [aperture_max[0]-aperture_min[0], aperture_max[1]-aperture_min[1], aperture_depth];
ts_size       = [ts_max[0]-ts_min[0],           ts_max[1]-ts_min[1],           ts_depth];
ribbon_size   = [ribbon_max[0]-ribbon_min[0],   ribbon_max[1]-ribbon_min[1],   ribbon_clear_z];

// Simple mounting hole pattern (typical for 5" HDMI boards; adjustable)
hole_d = 3.2;
hole_positions = [
    [-57.5, -33.0],
    [ 57.5, -33.0],
    [-57.5,  33.0],
    [ 57.5,  33.0]
];

module pcb_body() {
    translate(pcb_offset)
        color([0.05,0.35,0.12])
            translate([-pcb_size[0]/2, -pcb_size[1]/2, 0])
                cube(pcb_size, center=false);
}

module touchscreen_plate() {
    // Place on top of PCB
    translate([0,0, pcb_offset[2] + pcb_size[2]])
        color([0.1,0.1,0.1, 0.85])
            translate([ts_min[0], ts_min[1], 0])
                cube(ts_size, center=false);
}

module aperture_cut() {
    // Cut down into touchscreen/pcb stack
    translate([0,0, pcb_offset[2] + pcb_size[2] + ts_depth - aperture_depth])
        translate([aperture_min[0], aperture_min[1], 0])
            cube(aperture_size, center=false);
}

module ribbon_clearance_cut() {
    // Cut a clearance slot below the PCB edge region
    translate([0,0, pcb_offset[2] - 0.1])
        translate([ribbon_min[0], ribbon_min[1], 0])
            cube(ribbon_size, center=false);
}

module mounting_holes_cut() {
    // Drill through PCB + touchscreen
    h = pcb_size[2] + ts_depth + 2;
    z0 = pcb_offset[2] - 1;
    for (p = hole_positions)
        translate([p[0], p[1], z0])
            cylinder(d=hole_d, h=h, center=false);
}

difference() {
    union() {
        pcb_body();
        touchscreen_plate();
    }
    aperture_cut();
    ribbon_clearance_cut();
    mounting_holes_cut();
}