// SMD package overall dimensions (mm)
body_length = 9.90;
body_width  = 3.90;
body_height = 1.25;

$fn = 48;

// Small helper: rounded rectangular prism via hull of corner cylinders
module rounded_box(size=[10,4,1], r=0.2, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, x/2, y/2);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(x/2-rr), sy*(y/2-rr), 0])
                    cylinder(r=rr, h=z, center=true);
        }
}

// Main SMD model: one connected solid with terminations + subtle top chamfer
module smd() {
    // Termination (metal end) proportions
    term_len = body_length * 0.12;                 // each end length
    term_h   = body_height * 0.70;                 // slightly shorter than body
    term_w   = body_width  * 0.92;                 // slightly inset from sides
    term_r   = min(0.25, term_len*0.45, term_w*0.20);

    // Body rounding/chamfer
    body_r   = min(0.35, body_width*0.12, body_length*0.06);
    chamfer  = min(0.18, body_height*0.18);        // subtle top edge chamfer
    eps      = 0.02;

    union() {
        // Ceramic body with a slight top chamfer (difference keeps it one solid)
        color([0.85, 0.85, 0.80])
        difference() {
            rounded_box([body_length, body_width, body_height], r=body_r, center=true);

            // Chamfer cut: remove a thin "ring" near the top edges
            translate([0, 0, body_height/2 - chamfer/2 + eps])
                difference() {
                    rounded_box([body_length + 2*eps, body_width + 2*eps, chamfer + 2*eps],
                                r=max(body_r - 0.05, 0.01), center=true);
                    rounded_box([body_length - 2*chamfer, body_width - 2*chamfer, chamfer + 4*eps],
                                r=max(body_r - chamfer, 0.01), center=true);
                }
        }

        // Metal terminations (connected, slightly overlapping into body)
        color([0.75, 0.75, 0.78])
        for (sx = [-1, 1]) {
            translate([sx*(body_length/2 - term_len/2 + eps), 0, -body_height/2 + term_h/2 + eps])
                rounded_box([term_len + 2*eps, term_w, term_h], r=term_r, center=true);
        }
    }
}

// Final output
smd();