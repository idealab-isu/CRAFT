// Linear bearing block for 6.0mm shaft
// Block size: 30.0mm (X) x 25.0mm (Y) x 20.0mm (Z)
// One connected solid, with a visible through-bore for the shaft.

block_length = 30; //[15:60:1]   // X
block_width  = 25; //[13:50:1]   // Y
block_height = 20; //[10:40:1]   // Z

shaft_diameter  = 6;    //[3:12:0.1]
shaft_clearance = 0.15; //[0:0.5:0.01]

mount_hole_count = 4; //[2:4:1]
mount_hole_diameter = 3.2; //[2:6:0.1]
mount_hole_spacing_x = 20; //[10:40:1]
mount_hole_spacing_y = 15; //[8:30:1]
counterbore_diameter = 6; //[4:12:0.1]
counterbore_depth = 2; //[1:6:0.1]

edge_margin = 3; //[1:8:0.5]
overlap = 1; //[0.5:2:0.1]

$fn = 96;

// Bearing housing geometry (adds a visible cylindrical "seat" on top)
housing_outer_d = 14;   // outer diameter of bearing housing
housing_h       = 10;   // height of housing above top face
housing_overlap = 1;    // overlap into main block for watertight union

// Clamp slit (opens from top down to the bore)
slit_w = 1.2;                  // slit thickness along Y
slit_depth_extra = 1.0;        // ensures it reaches the bore

// Set screw (optional) - disabled by default
set_screw_enabled = 0; //[0:1:1]
set_screw_thread_diameter = 3; //[2:6:0.1]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module mount_holes_and_counterbores() {
    sx = clamp(mount_hole_spacing_x, 0, block_length - 2*edge_margin);
    sy = clamp(mount_hole_spacing_y, 0, block_width  - 2*edge_margin);

    for (x = [-1, 1])
        for (y = [-1, 1]) {
            translate([x*sx/2, y*sy/2, 0])
                cylinder(h=block_height + 2*overlap, r=mount_hole_diameter/2, center=true);

            translate([x*sx/2, y*sy/2, block_height/2 - counterbore_depth/2 + overlap/2])
                cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
        }
}

module shaft_bore() {
    // Through bore along X axis for 6mm shaft (clearly visible in left/right views)
    rotate([0, 90, 0])
        cylinder(h=block_length + 2*overlap, r=(shaft_diameter + shaft_clearance)/2, center=true);
}

module clamp_slit() {
    // Slit starts at top face and reaches slightly below bore centerline (Z=0)
    slit_h = block_height/2 + (shaft_diameter + shaft_clearance)/2 + slit_depth_extra;

    translate([0, 0, block_height/2 - slit_h/2 + overlap/2])
        cube([housing_outer_d + 2*overlap, slit_w, slit_h + overlap], center=true);
}

module bearing_housing() {
    // Cylindrical housing centered on top face, connected with overlap
    translate([0, 0, block_height/2 + housing_h/2 - housing_overlap])
        cylinder(h=housing_h, r=housing_outer_d/2, center=true);
}

module set_screw_hole() {
    // Side set screw into the bore (optional), from +Y toward -Y
    if (set_screw_enabled == 1) {
        translate([0, block_width/2 + overlap, 0])
            rotate([90, 0, 0])
                cylinder(h=block_width + 2*overlap, r=set_screw_thread_diameter/2, center=false);
    }
}

module bearing_block() {
    difference() {
        union() {
            // Main block (exact 30 x 25 x 20)
            cube([block_length, block_width, block_height], center=true);

            // Bearing housing (connected, makes "bearing block" geometry obvious)
            bearing_housing();
        }

        // Shaft bore
        shaft_bore();

        // Mount holes + counterbores
        if (mount_hole_count == 4)
            mount_holes_and_counterbores();

        // Clamp slit
        clamp_slit();

        // Optional set screw
        set_screw_hole();
    }
}

bearing_block();