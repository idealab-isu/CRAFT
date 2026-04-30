$fn = 96;

envelope_x = 30;
envelope_y = 30;
depth = 10.1;

intake_d = 25;
exit_w = 21.2;
hub_d = 16;

// Wall/feature params (not specified explicitly)
wall = 1.2;
base_th = 1.2;
cover_th = 1.0;
hub_h = depth - base_th - cover_th;
hub_top_rim = 0.8;

module blower_body() {
    difference() {
        // Outer envelope
        translate([-envelope_x/2, -envelope_y/2, 0])
            cube([envelope_x, envelope_y, depth], center=false);

        // Internal cavity: volute-like (cylindrical cavity plus exit duct cut)
        translate([0, 0, base_th])
            cylinder(h=depth - base_th - cover_th, d=intake_d + 2*( (envelope_x - intake_d)/2 - wall ), center=false);

        // Intake opening through top cover
        translate([0, 0, depth - cover_th - 0.01])
            cylinder(h=cover_th + 0.02, d=intake_d, center=false);

        // Exit port cutout on +X side (through full depth, minus walls)
        translate([envelope_x/2 - wall - 0.01, -exit_w/2, base_th])
            cube([wall + 0.02, exit_w, depth - base_th - cover_th], center=false);

        // Slight interior relief to ensure flow path (squared volute pocket)
        translate([-envelope_x/2 + wall, -envelope_y/2 + wall, base_th])
            cube([envelope_x - 2*wall, envelope_y - 2*wall, depth - base_th - cover_th], center=false);

        // Keep outer corners thicker by re-adding (done by subtracting a rounded-ish pocket)
        // Use a smaller cylinder pocket to avoid over-thinning near corners
        translate([0, 0, base_th])
            cylinder(h=depth - base_th - cover_th, d=envelope_x - 2*wall - 6, center=false);
    }
}

module rotor_hub() {
    // Rotor hub centered inside, slightly recessed from top cover
    translate([0, 0, base_th])
    union() {
        cylinder(h=hub_h, d=hub_d, center=false);
        // small top rim
        translate([0, 0, hub_h - hub_top_rim])
            cylinder(h=hub_top_rim, d=hub_d + 1.2, center=false);
    }
}

module blades() {
    // Simple radial impeller blades inside cavity
    blade_count = 9;
    blade_th = 1.0;
    blade_h = hub_h - 0.8;
    r_inner = hub_d/2 + 0.6;
    r_outer = intake_d/2 - 1.0;

    translate([0, 0, base_th + 0.3])
    for (i = [0:blade_count-1]) {
        rotate([0, 0, i*360/blade_count + 10])
        translate([ (r_inner + r_outer)/2, 0, 0 ])
            cube([r_outer - r_inner, blade_th, blade_h], center=true);
    }
}

module exit_nozzle_lip() {
    // A small external lip around the exit port
    lip_t = 1.2;
    lip_out = 1.5;
    translate([envelope_x/2 - lip_t, 0, depth/2])
    difference() {
        translate([lip_out/2, 0, 0])
            cube([lip_t + lip_out, exit_w + 2*lip_out, depth], center=true);
        translate([lip_out/2 - 0.01, 0, 0])
            cube([lip_t + 0.02, exit_w, depth + 0.2], center=true);
    }
}

module blower_fan() {
    union() {
        blower_body();
        // Rotor features (solid visible through intake)
        rotor_hub();
        blades();
        exit_nozzle_lip();
    }
}

// Center model about origin in X/Y; base on Z=0. Move to be centered in Z.
translate([0, 0, -depth/2])
    blower_fan();