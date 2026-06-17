$fn = 128;

// Pan head screw dimensions (mm)
shaft_d = 4.2;      // shank major diameter
length  = 10;       // under-head length

head_d  = 8.2;      // head diameter
head_h  = 3.05;     // head height

// Drive recess (Phillips-like cross) and simple cosmetic threads
recess_depth = head_h * 0.55;
recess_w     = head_d * 0.22;
recess_len   = head_d * 0.62;

thread_pitch = 1.2;
thread_depth = 0.28;
thread_len   = length;

eps = 0.02;

module pan_head(d, h) {
    base_h = h * 0.55;
    dome_h = h - base_h;

    // spherical cap radius for given cap height dome_h and base radius d/2
    r = (pow(d/2, 2) + pow(dome_h, 2)) / (2 * dome_h);

    union() {
        cylinder(d = d, h = base_h);

        translate([0, 0, base_h])
            intersection() {
                translate([0, 0, r - dome_h]) sphere(r = r);
                cylinder(d = d, h = dome_h + eps);
            }
    }
}

module phillips_recess(depth, w, len) {
    // Cross made from two rounded slots (hull of cylinders), subtracted from head
    union() {
        hull() {
            translate([ len/2, 0, 0]) cylinder(d = w, h = depth + eps);
            translate([-len/2, 0, 0]) cylinder(d = w, h = depth + eps);
        }
        rotate([0, 0, 90])
            hull() {
                translate([ len/2, 0, 0]) cylinder(d = w, h = depth + eps);
                translate([-len/2, 0, 0]) cylinder(d = w, h = depth + eps);
            }
    }
}

module cosmetic_threads(d, len, pitch, depth) {
    // Simple helical ridge (not a standard thread form), fused to shank
    turns = len / pitch;
    linear_extrude(height = len, twist = -360 * turns, slices = max(24, ceil(turns * 24)))
        translate([d/2 - depth/2, 0, 0])
            circle(d = depth);
}

difference() {
    union() {
        // Shank (under-head length)
        cylinder(d = shaft_d, h = length);

        // Cosmetic threads fused to shank (slight overlap to ensure connectivity)
        translate([0, 0, -eps])
            cosmetic_threads(shaft_d, thread_len + eps, thread_pitch, thread_depth);

        // Pan head sits on top of shank; overlap by eps to ensure one connected solid
        translate([0, 0, length - eps])
            pan_head(head_d, head_h);
    }

    // Drive recess cut into top of head
    translate([0, 0, length + head_h - recess_depth])
        phillips_recess(recess_depth + eps, recess_w, recess_len);
}