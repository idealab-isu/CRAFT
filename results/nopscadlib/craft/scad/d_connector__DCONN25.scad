$fn = 96;

// Parameters
housing_W = 30; //[15:60:1]   // overall width (X) of D-shell
housing_H = 12; //[6:24:1]    // overall height (Y) of D-shell
housing_D = 15; //[8:30:1]    // depth (Z) of shell body

flange_W = 40; //[20:80:1]    // flange width (X)
flange_H = 16; //[8:32:1]     // flange height (Y)
flange_t = 2.5; //[1.25:5:0.25]

hole_d = 3.2; //[1.6:6.4:0.1]
hole_spacing = 33; //[16.5:66:0.5]

overlap = 1; //[0.2:2:0.1]

// Pin parameters (D-sub style staggered layout)
pin_cols = 5;
pin_pitch_x = 2.77;
pin_pitch_y = 2.84;
pin_d = 1.0;
pin_len = 4.0;

// Jackscrew boss parameters (simple cylinders around mounting holes)
boss_d = 7.0;
boss_len = 3.0;

// Face recess (socket/pin field pocket) to look like a D-sub front
face_recess_depth = 1.6;
face_recess_clear = 1.2; // clearance around pin field

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// D-shell 2D profile (flat on left, rounded on right)
module d_profile_2d(w, h) {
    r = h/2;
    rect_w = clamp(w - r, 0.01, w);
    union() {
        translate([-w/2 + rect_w/2, 0]) square([rect_w, h], center=true);
        translate([w/2 - r, 0]) circle(r=r);
    }
}

// Main shell body (extruded D profile)
module d_shell_body() {
    linear_extrude(height=housing_D, center=true)
        d_profile_2d(housing_W, housing_H);
}

// Flange plate attached to BACK of shell with overlap (guaranteed contact)
module flange_plate() {
    // Shell back face at z = -housing_D/2
    // Flange spans: [z0, z0+flange_t], with z0 = -housing_D/2 - flange_t + overlap
    zc = (-housing_D/2) - flange_t/2 + overlap;
    translate([0, 0, zc])
        cube([flange_W, flange_H, flange_t], center=true);
}

// Mount holes through flange (and slightly beyond for clean subtraction)
module mount_holes() {
    zc = (-housing_D/2) - flange_t/2 + overlap;
    for (sx = [-1, 1])
        translate([sx*hole_spacing/2, 0, zc])
            cylinder(h=flange_t + 6*overlap, r=hole_d/2, center=true);
}

// Jackscrew bosses: attach to BACK of flange with overlap (guaranteed contact)
module jackscrew_bosses() {
    // Flange back face at z = (-housing_D/2) - flange_t + overlap
    // Boss spans: [z0, z0+boss_len], with z0 = flange_back - overlap
    flange_back = (-housing_D/2) - flange_t + overlap;
    zc = (flange_back - overlap) - boss_len/2; // ensures boss front overlaps into flange
    for (sx = [-1, 1])
        translate([sx*hole_spacing/2, 0, zc])
            cylinder(h=boss_len, r=boss_d/2, center=true);
}

// D-sub style staggered pin array protruding from FRONT face (connected with overlap)
module pin_array_staggered() {
    // Shell front face at z = +housing_D/2
    // Pins span: [z0, z0+pin_len], with z0 = shell_front - overlap
    shell_front = housing_D/2;
    zc = (shell_front - overlap) + pin_len/2;

    y_top =  pin_pitch_y/2;
    y_bot = -pin_pitch_y/2;

    x0 = -(pin_cols-1)*pin_pitch_x/2;

    // Row 0 (top): 5 pins
    for (c = [0:pin_cols-1])
        translate([x0 + c*pin_pitch_x, y_top, zc])
            cylinder(h=pin_len, r=pin_d/2, center=true);

    // Row 1 (bottom): 4 pins (typical DE-9), centered and staggered
    for (c = [0:pin_cols-2])
        translate([x0 + (c+0.5)*pin_pitch_x, y_bot, zc])
            cylinder(h=pin_len, r=pin_d/2, center=true);
}

// Front face recess pocket (typical D-sub face detail)
module face_recess() {
    pin_field_w = (pin_cols-1)*pin_pitch_x + pin_d + 2*face_recess_clear;
    pin_field_h = pin_pitch_y + pin_d + 2*face_recess_clear;

    pocket_w = clamp(pin_field_w, 0.01, housing_W - 0.8);
    pocket_h = clamp(pin_field_h, 0.01, housing_H - 0.8);

    // Cut from the front face inward; ensure it intersects the shell robustly
    shell_front = housing_D/2;
    zc = (shell_front - face_recess_depth/2) - overlap;

    translate([0, 0, zc])
        linear_extrude(height=face_recess_depth + 6*overlap, center=true)
            d_profile_2d(pocket_w, pocket_h);
}

// Final connected solid (recognizable simplified D-sub / "D connector")
module d_connector() {
    difference() {
        union() {
            d_shell_body();        // D-shaped shell/profile
            flange_plate();        // mounting flange
            jackscrew_bosses();    // side mounting bosses
            pin_array_staggered(); // pin array on face
        }
        mount_holes(); // screw holes through flange/boss area
        face_recess(); // D-shaped front pocket
    }
}

color("Silver") d_connector();