// Symmetric elongated bracket/strap with central square through-window and longitudinal ribs
// Target bounding box: 10.9 x 43.9 x 10.6 mm (W x L x H), elongated along X

$fn = 64;

// Overall dimensions
L = 43.93;   // X
W = 10.92;   // Y
H = 10.64;   // Z

// Central block
center_L = 12.0;
center_W = W;
center_H = H;

// Arms (thinner)
arm_L_each = (L - center_L)/2;
arm_W = W;
arm_H = 6.2;

// Transition length (simple hull ramp)
transition_L = 2.0;

// Square through-window (through full height)
window_size = 5.6;

// Ribs: multiple longitudinal ribs on ONE face (top)
rib_count = 5;
rib_W = 0.9;     // rib width across Y
rib_H = 0.9;     // rib height in Z
rib_end_margin = 1.0;
rib_side_margin = 0.9;

// Small overlap to guarantee manifold unions/differences
overlap = 0.4;

// ----------------- Core solids -----------------
module central_block() {
    cube([center_L, center_W, center_H], center=true);
}

module arm(side=1) { // side = -1 left, +1 right
    // Place arm so it overlaps into central block by 'overlap'
    translate([side*(center_L/2 + arm_L_each/2 - overlap), 0, -(center_H/2 - arm_H/2)])
        cube([arm_L_each, arm_W, arm_H], center=true);
}

module transition(side=1) {
    // Hull between a thin slice at arm height and a thin slice at full height
    hull() {
        // slice at arm height, right at the central edge
        translate([side*(center_L/2 - overlap/2), 0, -(center_H/2 - arm_H/2)])
            cube([overlap, arm_W, arm_H], center=true);

        // slice at full height, a bit into the arm
        translate([side*(center_L/2 + transition_L - overlap/2), 0, 0])
            cube([overlap, center_W, center_H], center=true);
    }
}

module square_through_window() {
    cube([window_size, window_size, center_H + 2*overlap], center=true);
}

// Longitudinal ribs on TOP face, spanning most of length
module ribs_top() {
    rib_span_L = L - 2*rib_end_margin;
    y_min = -W/2 + rib_side_margin + rib_W/2;
    y_max =  W/2 - rib_side_margin - rib_W/2;

    for (i = [0 : rib_count-1]) {
        t = (rib_count <= 1) ? 0.5 : i/(rib_count-1);
        y = y_min + t*(y_max - y_min);

        // Ensure ribs are actually visible: sit on top face with slight overlap into body
        translate([0, y, H/2 + rib_H/2 - overlap])
            cube([rib_span_L, rib_W, rib_H], center=true);
    }
}

// ----------------- Final model -----------------
module model() {
    difference() {
        union() {
            // Main connected body
            union() {
                central_block();
                arm(-1);
                arm( 1);
                transition(-1);
                transition( 1);
            }
            // Ribs on one face
            ribs_top();
        }

        // Central square through-window
        square_through_window();
    }
}

model();