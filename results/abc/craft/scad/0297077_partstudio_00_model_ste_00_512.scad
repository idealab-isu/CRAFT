// Flanged cylindrical hub/bushing with central hex through-bore
// Features: wide flange, stepped OD (minor near flange), small collar near far end,
// and 4 diamond-shaped recesses on the flange face.
// Model is one connected solid. Dimensions kept within 0.1 x 0.1 x 0.1 mm bbox.

$fn = 160;

// ---------- Parameters (mm) ----------
bbox = 0.1;

flange_d = 0.1;
flange_t = 0.02;

body_d_major = 0.06;     // main OD
body_d_minor = 0.05;     // reduced OD section near flange
body_len_total = 0.1;    // total length including flange (matches bbox Z)

step_len = 0.03;         // length of reduced OD section (from flange side)

collar_d = 0.065;        // small collar near far end
collar_len = 0.01;
collar_offset_from_end = 0.005;

hex_af = 0.03;           // across flats

diamond_count = 4;
diamond_radial_pos = 0.032;
diamond_w = 0.012;
diamond_h = 0.006;
diamond_depth = 0.006;

eps = 0.0005;

// ---------- Derived ----------
body_h = body_len_total - flange_t;

z_min = -body_len_total/2;
z_max =  body_len_total/2;

z_flange_center = z_min + flange_t/2;
z_body_center   = z_min + flange_t + body_h/2;

z_step_center   = z_min + flange_t + step_len/2;

z_collar_center = z_max - collar_offset_from_end - collar_len/2;

// ---------- Helpers ----------
module hex_prism_through(af, h) {
    // Regular hex with given across-flats (af): circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, center=true, $fn=6);
}

module diamond_prism(w, h, depth) {
    linear_extrude(height=depth, center=true)
        polygon(points=[
            [ w/2, 0],
            [ 0,   h/2],
            [-w/2, 0],
            [ 0,  -h/2]
        ]);
}

// ---------- Main solid ----------
module outer_solid() {
    union() {
        // Flange
        translate([0,0,z_flange_center])
            cylinder(h=flange_t, r=flange_d/2, center=true);

        // Body (major OD)
        translate([0,0,z_body_center])
            cylinder(h=body_h, r=body_d_major/2, center=true);

        // Collar near far end
        translate([0,0,z_collar_center])
            cylinder(h=collar_len, r=collar_d/2, center=true);
    }
}

module reduced_od_cut() {
    // Remove the ring between minor and major in the step region,
    // leaving the minor OD there.
    translate([0,0,z_step_center])
        difference() {
            cylinder(h=step_len + 2*eps, r=body_d_major/2 + eps, center=true);
            cylinder(h=step_len + 4*eps, r=body_d_minor/2, center=true);
        }
}

module diamond_recesses_cut() {
    // Recesses on the flange outer face (at z_min)
    z_recess_center = z_min + diamond_depth/2 + eps;

    for (i = [0:diamond_count-1]) {
        rotate([0,0,i*360/diamond_count])
            translate([diamond_radial_pos, 0, z_recess_center])
                diamond_prism(diamond_w, diamond_h, diamond_depth + 2*eps);
    }
}

module hex_bore_cut() {
    hex_prism_through(hex_af, body_len_total + 6*eps);
}

// ---------- Final ----------
difference() {
    difference() {
        outer_solid();
        reduced_od_cut();
    }
    hex_bore_cut();
    diamond_recesses_cut();
}