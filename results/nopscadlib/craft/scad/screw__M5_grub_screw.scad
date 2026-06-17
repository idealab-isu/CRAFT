// M5 grub screw (set screw) with external thread + internal hex socket
// One connected solid; all placements derived from dimensions

// Parameters
nominal_diameter_mm = 5; //[2.5:10:0.1]
pitch_mm = 0.8; //[0.4:1.6:0.05]
length_mm = 10; //[5:20:0.5]
thread_length_mm = 10; //[5:20:0.5]
socket_af_mm = 2.5; //[1.25:5:0.05]
socket_depth_mm = 2.5; //[1.25:5:0.1]
chamfer_tip_mm = 0.3; //[0.1:1:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
socket_clearance_mm = 0.1; //[0:0.3:0.05]

// Quality
$fn = 96;

// --- Helpers ---
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// External metric thread approximation using a helical triangular ridge
// Built as: core cylinder + helical ridge (union) => solid screw body
module metric_thread_external(d_nom, pitch, len, center=true) {
    H = 0.866025403784 * pitch;     // fundamental triangle height
    h_ext = 0.61343 * pitch;        // external thread radial height (approx)
    r_maj = d_nom/2;
    r_min = max(0.01, r_maj - h_ext);

    turns = len / pitch;
    twist_deg = 360 * turns;

    // Helical ridge cross-section in XY, extruded along Z with twist
    // Triangle spans from r_min to r_maj
    module ridge_2d() {
        polygon(points=[
            [r_min, -pitch/2],
            [r_maj, 0],
            [r_min,  pitch/2]
        ]);
    }

    translate([0,0, center ? -len/2 : 0])
    union() {
        // Core (minor diameter) ensures a solid body (not a ring)
        cylinder(r=r_min, h=len, center=false, $fn=96);

        // Helical ridge adds the external thread form
        linear_extrude(height=len, twist=twist_deg,
                       slices=max(ceil(turns*40), 40), convexity=10)
            ridge_2d();
    }
}

// Hex socket cutter (across flats)
module hex_socket_cut(af, depth, clearance=0, center=true) {
    R = (af + clearance) / (2*cos(30)); // circumradius from AF
    cylinder(r=R, h=depth, center=center, $fn=6);
}

// Tip chamfer cutter (conical)
module tip_chamfer_cut(d_nom, chamfer_h) {
    r = d_nom/2;
    cylinder(r1=r, r2=0, h=chamfer_h, center=false, $fn=96);
}

// --- Main screw ---
module screw() {
    body_len = max(0.01, length_mm);
    thread_len = clamp(thread_length_mm, 0, body_len);

    z_top =  body_len/2;
    z_bot = -body_len/2;

    // Socket placement: cut from top face downward
    socket_depth = clamp(socket_depth_mm, 0, body_len);
    socket_h = socket_depth + overlap_mm;
    z_socket_center = z_top - socket_depth/2;

    // Thread placement: start at bottom, extend upward
    z_thread_center = z_bot + thread_len/2;

    // Chamfer at bottom tip
    chamfer_h = clamp(chamfer_tip_mm, 0, body_len/2);
    z_chamfer_base = z_bot;

    // Minor radius for any unthreaded remainder (keeps body solid)
    h_ext = 0.61343 * pitch_mm;
    core_r = max(0.01, nominal_diameter_mm/2 - h_ext);

    color("DimGray")
    difference() {
        union() {
            // Threaded portion
            translate([0,0,z_thread_center])
                metric_thread_external(nominal_diameter_mm, pitch_mm, thread_len, center=true);

            // Unthreaded remainder (if any), connected with overlap
            if (thread_len < body_len) {
                rem_len = body_len - thread_len;
                z_rem_center = z_top - rem_len/2;
                translate([0,0,z_rem_center])
                    cylinder(r=core_r, h=rem_len + overlap_mm, center=true, $fn=96);
            }
        }

        // Internal hex socket
        translate([0,0,z_socket_center])
            hex_socket_cut(socket_af_mm, socket_h, socket_clearance_mm, center=true);

        // Tip chamfer cut
        translate([0,0,z_chamfer_base])
            tip_chamfer_cut(nominal_diameter_mm, chamfer_h);
    }
}

screw();