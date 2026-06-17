// D-sub style connector (single connected solid)
// Fix: true D-shaped mating shell (flat + semicircle), proper flange with ears,
// visible mating recess, and 2-row staggered pin array.
// All placements are formula-based (no arbitrary offsets)

$fn = 96;

// ---------------- Parameters ----------------
shell_W = 30; //[15:60:1]   // overall D width (flat-to-round extreme)
shell_H = 12; //[6:24:1]    // overall D height
shell_D = 10; //[5:20:1]    // shell depth (front-to-back)
shell_wall_t = 1.5; //[0.8:3:0.1]

body_D = 18; //[9:36:1]

flange_W = 40; //[20:80:1]
flange_H = 16; //[8:32:1]
flange_t = 2.5; //[1.2:5:0.1]

hole_d = 3.2; //[2:6:0.1]
hole_spacing = 33; //[16:66:1]

overlap = 1; //[0.5:2:0.1]

pin_count = 9; //[3:25:1]
pin_d = 1; //[0.6:2:0.1]
pin_len = 6; //[3:12:0.5]
pin_pitch = 2.77; //[2:5:0.01]

strain_relief_r = 6; //[3:12:0.5]
strain_relief_len = 10; //[5:25:1]

key_w = 4; //[2:8:0.5]
key_h = 2; //[1:5:0.5]
key_d = 3; //[1:8:0.5]

// ---------------- Derived ----------------
shell_r = shell_H/2;
flat_w  = shell_W - shell_H;                 // flat portion width (excluding semicircle diameter)
inner_r = max(0.01, shell_r - shell_wall_t);
inner_flat_w = max(0.01, flat_w - 2*shell_wall_t);
inner_H = max(0.01, shell_H - 2*shell_wall_t);

mating_recess_d = max(1.2, shell_D*0.35);
mating_recess_inset = shell_wall_t;

// ---------------- 2D D-shape (in XY), extruded along Z ----------------
// D shape: flat on -X side, semicircle on +X side.
module d2d_outer() {
    union() {
        // rectangle spans from x = -flat_w/2 to +flat_w/2, y = [-H/2, +H/2]
        translate([-flat_w/2, -shell_H/2])
            square([flat_w, shell_H], center=false);
        // semicircle center at x = +flat_w/2
        translate([flat_w/2, 0])
            circle(r=shell_r);
    }
}

module d2d_inner() {
    union() {
        translate([-inner_flat_w/2, -inner_H/2])
            square([inner_flat_w, inner_H], center=false);
        translate([inner_flat_w/2, 0])
            circle(r=inner_r);
    }
}

module d_shell_outer() {
    linear_extrude(height=shell_D, center=true)
        d2d_outer();
}

module d_shell_inner_through() {
    linear_extrude(height=shell_D + 2*overlap, center=true)
        d2d_inner();
}

module d_shell_inner_mating_recess() {
    // recess from front face (z = -shell_D/2) into shell
    recess_h = mating_recess_d + overlap;
    zc = -shell_D/2 + recess_h/2 - overlap/2;
    translate([0, 0, zc])
        linear_extrude(height=recess_h, center=true)
            offset(delta=-mating_recess_inset)
                d2d_inner();
}

module d_shaped_shell() {
    difference() {
        d_shell_outer();
        d_shell_inner_through();
        d_shell_inner_mating_recess();
    }
}

// ---------------- Flange with mounting ears + holes ----------------
module mounting_flange_solid() {
    // flange sits just behind the front face, connected to shell with overlap
    zc = -(shell_D/2 + flange_t/2 - overlap);

    difference() {
        translate([0, 0, zc])
            cube([flange_W, flange_H, flange_t], center=true);

        for (sx = [-1, 1]) {
            translate([sx*hole_spacing/2, 0, zc])
                cylinder(r=hole_d/2, h=flange_t + 2*overlap, center=true);
        }
    }
}

// ---------------- Rear body + strain relief ----------------
module connector_body() {
    body_w = shell_W - 2*shell_wall_t;
    body_h = shell_H - 2*shell_wall_t;

    body_zc = shell_D/2 + body_D/2 - overlap;
    sr_zc   = shell_D/2 + body_D - overlap + strain_relief_len/2 - overlap;

    union() {
        translate([0, 0, body_zc])
            cube([body_w, body_h, body_D], center=true);

        translate([0, 0, sr_zc])
            cylinder(r=strain_relief_r, h=strain_relief_len, center=true);
    }
}

// ---------------- Pins (2-row staggered) ----------------
module pin_at(x, y) {
    // pins protrude out the front (negative Z) and overlap into flange/shell
    zc = -(shell_D/2 + pin_len/2 - overlap);
    translate([x, y, zc])
        cylinder(r=pin_d/2, h=pin_len, center=true);
}

module pin_array() {
    n_top = ceil(pin_count/2);
    n_bot = floor(pin_count/2);

    // keep within inner opening
    row_sep = min(2.84, inner_H * 0.45);
    y_top =  row_sep/2;
    y_bot = -row_sep/2;

    // stagger bottom row by half pitch
    x0_top = -(n_top-1)*pin_pitch/2;
    x0_bot = -(n_bot-1)*pin_pitch/2 + pin_pitch/2;

    union() {
        for (i = [0:n_top-1])
            pin_at(x0_top + i*pin_pitch, y_top);

        for (i = [0:n_bot-1])
            pin_at(x0_bot + i*pin_pitch, y_bot);
    }
}

// ---------------- Keying feature (small block on face) ----------------
module keying_feature_block() {
    // place inside opening near flat side (-X) and near top (+Y), connected with overlap
    x = -flat_w/2 + key_w/2 - overlap;
    y =  inner_H/2 - key_h/2;
    z = -shell_D/2 + key_d/2 - overlap;

    translate([x, y, z])
        cube([key_w, key_h, key_d], center=true);
}

// ---------------- Final Model (single connected solid) ----------------
module complete_model_union() {
    union() {
        d_shaped_shell();
        mounting_flange_solid();
        connector_body();
        pin_array();
        keying_feature_block();
    }
}

complete_model_union();