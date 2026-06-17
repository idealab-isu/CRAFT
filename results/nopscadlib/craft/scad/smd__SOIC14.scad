$fn = 48;

// Target overall dimensions (mm)
body_length = 8.70; //[4.35:17.4:0.05]
body_width  = 3.90; //[1.95:7.8:0.05]
body_height = 1.25; //[0.6:2.5:0.05]

// Detail parameters (kept proportional; all formula-based placement)
eps = 0.02;

// Terminations (metal ends)
term_len = body_length * 0.12;          // each end length
term_thk = body_height * 0.22;          // metal thickness on bottom
term_inset_w = body_width * 0.06;       // inset from sides

// Top polarity/mark recess (subtle)
mark_r = min(body_width, body_length) * 0.10;
mark_depth = body_height * 0.10;

// Edge softening via chamfer cuts (difference)
chamfer = min(body_height, body_width, body_length) * 0.08;

// Rounded body helper
module rounded_box(size=[1,1,1], r=0.2, center=true) {
    l = size[0]; w = size[1]; h = size[2];
    rr = min(r, l/2 - eps, w/2 - eps, h/2 - eps);
    translate(center ? [0,0,0] : [l/2, w/2, h/2])
        minkowski() {
            cube([l-2*rr, w-2*rr, h-2*rr], center=true);
            sphere(r=rr);
        }
}

// Main SMD package
module smd_package() {
    union() {
        // Ceramic body with slight rounding + chamfers + polarity recess
        color([0.85, 0.85, 0.80])
        difference() {
            rounded_box([body_length, body_width, body_height], r=min(body_height, body_width)*0.08, center=true);

            // Chamfer cuts (top edges)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(body_length/2 - chamfer/2), sy*(body_width/2 - chamfer/2), body_height/2 - chamfer/2])
                    rotate([0,0,45])
                        cube([chamfer, chamfer, chamfer*2], center=true);
            }

            // Polarity/ID mark recess on top near one corner
            translate([-(body_length/2 - mark_r*1.6), (body_width/2 - mark_r*1.6), body_height/2 - mark_depth/2])
                cylinder(h=mark_depth + eps, r=mark_r, center=true);
        }

        // Metal terminations (connected, slightly overlapping into body)
        color([0.75, 0.75, 0.78])
        for (sx = [-1, 1]) {
            translate([
                sx*(body_length/2 - term_len/2 + eps), // overlap into body by eps
                0,
                -(body_height/2 - term_thk/2)          // sit on bottom
            ])
            cube([term_len + 2*eps, body_width - 2*term_inset_w, term_thk], center=true);
        }
    }
}

smd_package();