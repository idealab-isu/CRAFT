// Aluminium foil tape roll with a short peeled-out sheet (ONE connected solid)

// ---------- Parameters ----------
tape_length = 500;              //[250:1000:1]  // used as max available; tail uses a fraction
tape_width = 50;                //[25:100:1]
tape_thickness = 0.08;          //[0.04:0.16:0.01]
adhesive_thickness = 0.05;      //[0.02:0.12:0.01]
liner_thickness = 0.08;         //[0.04:0.2:0.01]

core_outer_radius = 18;         //[10:36:1]     // cardboard core outer radius
core_inner_radius = 12;         //[6:24:1]
core_width = 55;                //[30:120:1]    // roll width (along axis)

overlap = 0.8;                  //[0.5:2:0.1]   // overlap to ensure watertight unions/differences

// Roll geometry controls
roll_outer_radius = 32;         //[20:60:1]     // overall roll radius (tape wound)
tail_length = 220;              //[50:600:1]    // peeled-out sheet length
tail_lift = 0.6;                //[0:5:0.1]     // slight lift above roll surface

$fn = 128;

// ---------- Derived ----------
layer_total = tape_thickness + adhesive_thickness + liner_thickness;
roll_r = max(roll_outer_radius, core_outer_radius + 2); // ensure roll bigger than core
tail_len = min(tail_length, tape_length);

// Place roll centered at origin, axis along Y.
// Tail exits tangentially to the right (+X) from the outer surface at Z=0.
tail_z = roll_r + layer_total/2 + tail_lift; // top tangent height
tail_x0 = roll_r - overlap;                  // start at tangent point with overlap into roll

// ---------- Modules ----------
module core() {
    // Cardboard core (hollow cylinder)
    difference() {
        cylinder(r=core_outer_radius, h=core_width, center=true);
        cylinder(r=core_inner_radius, h=core_width + 2*overlap, center=true);
    }
}

module tape_roll_body() {
    // Wound tape as a solid ring (no internal spiral for performance)
    difference() {
        cylinder(r=roll_r, h=tape_width, center=true);
        cylinder(r=core_outer_radius - overlap, h=tape_width + 2*overlap, center=true);
    }
}

module tail_sheet() {
    // A thin rectangular tail (foil + adhesive + liner) exiting tangentially
    translate([tail_x0 + tail_len/2, 0, tail_z])
        cube([tail_len, tape_width, layer_total], center=true);
}

module tape_roll_with_tail() {
    // Ensure ONE connected solid by overlapping tail into roll
    union() {
        // Roll (tape wound)
        tape_roll_body();

        // Core inside roll (touch/overlap slightly so it's one connected solid)
        // Overlap by expanding core slightly into tape ring
        intersection() {
            // keep core within roll width
            cylinder(r=roll_r + overlap, h=tape_width + 2*overlap, center=true);
            // core itself
            core();
        }

        // Peeled-out tail
        tail_sheet();
    }
}

// ---------- Final Output ----------
tape_roll_with_tail();