// uxcell M5x0.8 Right Hand Thread - Self-Lubricating Joint Rod End (simplified but correct silhouette)
// One connected solid; no floating parts; all translate() values derived from dimensions.

$fn = 96;

// -------------------- Parameters --------------------
thread_diameter_mm = 5.0; //[2.5:10.0:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
shank_length_mm = 20.0; //[10.0:40.0:0.5]
thread_length_mm = 16.0; //[8.0:32.0:0.5]
shank_unthreaded_length_mm = 4.0; //[2.0:10.0:0.5]
shank_major_diameter_mm = 5.0; //[2.5:10.0:0.1]
shank_minor_diameter_mm = 4.2; //[2.1:8.4:0.1]

eye_outer_diameter_mm = 16.0; //[8.0:32.0:0.5]
eye_width_mm = 8.0; //[4.0:16.0:0.5]

ball_outer_diameter_mm = 10.0; //[5.0:20.0:0.5]
ball_bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
ball_center_offset_from_shank_axis_mm = 0.0; //[-2.0:2.0:0.1]

housing_wall_thickness_mm = 2.5; //[1.25:5.0:0.1]
rim_thickness_mm = 1.5; //[0.75:3.0:0.1]
chamfer_mm = 0.5; //[0.25:2.0:0.05]
fillet_radius_mm = 1.0; //[0.5:3.0:0.1]
clearance_mm = 0.2; //[0.05:0.6:0.05]
self_lubricating_liner_thickness_mm = 0.5; //[0.2:1.5:0.05]

wrench_flats_enabled = 1; //[0:1:1]
wrench_flat_across_flats_mm = 8.0; //[4.0:16.0:0.5]
wrench_flat_length_mm = 4.0; //[2.0:10.0:0.5]

overlap_mm = 1.0; //[0.5:2.0:0.1]

// -------------------- Derived / safety --------------------
thread_length_mm = min(thread_length_mm, shank_length_mm);
shank_unthreaded_length_mm = min(shank_unthreaded_length_mm, shank_length_mm - thread_length_mm);
eye_outer_diameter_mm = max(eye_outer_diameter_mm, ball_outer_diameter_mm + 2*(housing_wall_thickness_mm + rim_thickness_mm));
eye_width_mm = max(eye_width_mm, ball_outer_diameter_mm*0.65);

function clamp(x,a,b) = min(max(x,a),b);

// -------------------- Helpers --------------------
module external_thread(d_major, d_minor, pitch, len, crest_w=0.35, depth_scale=1.0) {
    // Robust, bounded helical ridge (prevents stray "axis/edge" artifacts)
    turns = len / pitch;
    depth = max(0.01, (d_major - d_minor)/2 * depth_scale);
    ridge_w = max(0.10, crest_w) * pitch;

    union() {
        cylinder(d=d_minor, h=len, center=false);

        // Helical ridge: rectangle at radius d_minor/2, extruded with twist
        linear_extrude(height=len, twist=turns*360,
                      slices=max(ceil(turns*30), 80),
                      center=false, convexity=10)
            translate([d_minor/2, -ridge_w/2, 0])
                square([depth, ridge_w], center=false);
    }
}

module hex_prism(af, h, center=true) {
    r = af / (2*cos(30));
    linear_extrude(height=h, center=center)
        polygon([ for (i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

// -------------------- Head (eye + ball) --------------------
module rod_end_head() {
    eye_r  = eye_outer_diameter_mm/2;
    ball_r = ball_outer_diameter_mm/2;
    bore_r = ball_bore_diameter_mm/2;

    // Cavity for ball/liner clearance (must be smaller than ball so ball remains visible)
    cavity_r_raw = ball_r + clearance_mm + self_lubricating_liner_thickness_mm;
    cavity_r = clamp(cavity_r_raw, ball_r*0.70, ball_r*0.92);

    // Ensure housing has wall thickness
    cavity_r = min(cavity_r, eye_r - max(0.8, housing_wall_thickness_mm));

    // Neck boss to shank (on -Z side)
    neck_h  = max(fillet_radius_mm*2, eye_width_mm*0.45);
    neck_r1 = max(shank_major_diameter_mm/2 + 1.2, eye_r*0.55);
    neck_r2 = shank_major_diameter_mm/2 + 0.6;

    // Eye outer + neck, then subtract cavity + bore + side windows
    union() {
        difference() {
            union() {
                // Main eye disc
                cylinder(r=eye_r, h=eye_width_mm, center=true);

                // Face rims (connected)
                for (s=[-1,1])
                    translate([0,0, s*(eye_width_mm/2 - rim_thickness_mm/2)])
                        cylinder(r=eye_r, h=rim_thickness_mm, center=true);

                // Neck boss (overlaps into eye)
                translate([0,0, -(eye_width_mm/2 + neck_h/2 - overlap_mm)])
                    cylinder(r1=neck_r1, r2=neck_r2, h=neck_h, center=true);
            }

            // Spherical cavity (liner space)
            translate([0, ball_center_offset_from_shank_axis_mm, 0])
                sphere(r=cavity_r);

            // Through-bore (X axis)
            translate([0, ball_center_offset_from_shank_axis_mm, 0])
                rotate([0,90,0])
                    cylinder(r=bore_r, h=eye_outer_diameter_mm + 6*overlap_mm, center=true);

            // Side windows (race opening look)
            win_w = eye_outer_diameter_mm*1.25;
            win_h = eye_width_mm - 2*rim_thickness_mm;
            win_t = max(0.8, housing_wall_thickness_mm*0.95);
            for (sy=[-1,1])
                translate([0, sy*(eye_r - win_t/2), 0])
                    cube([win_w, win_t, win_h], center=true);
        }

        // Ball insert (fused to housing so model is ONE connected solid)
        difference() {
            translate([0, ball_center_offset_from_shank_axis_mm, 0])
                sphere(r=ball_r);

            translate([0, ball_center_offset_from_shank_axis_mm, 0])
                rotate([0,90,0])
                    cylinder(r=bore_r, h=eye_outer_diameter_mm + 6*overlap_mm, center=true);
        }
    }
}

// -------------------- Shank (thread + flats) --------------------
module shank_with_thread() {
    // Head spans Z = [-eye_width/2, +eye_width/2]
    // Neck extends below -eye_width/2 by neck_h, so shank should start below that and overlap.
    neck_h  = max(fillet_radius_mm*2, eye_width_mm*0.45);
    z_head_bottom = -eye_width_mm/2;
    z_neck_bottom = z_head_bottom - neck_h + overlap_mm; // overlap into neck
    z0 = z_neck_bottom; // shank top plane

    L_un = shank_unthreaded_length_mm;
    L_th = thread_length_mm;
    L_total = shank_length_mm;

    L_rest = max(0, L_total - (L_un + L_th));
    L_un2 = L_un + L_rest;

    wf_len = min(wrench_flat_length_mm, max(0, L_un2));
    wf_zc  = z0 - wf_len/2;

    union() {
        // Unthreaded cylinder
        translate([0,0, z0 - L_un2/2])
            cylinder(d=shank_major_diameter_mm, h=L_un2, center=true);

        // Threaded portion (placed directly below unthreaded, with overlap)
        translate([0,0, z0 - L_un2 - overlap_mm])
            external_thread(
                d_major=thread_diameter_mm,
                d_minor=shank_minor_diameter_mm,
                pitch=thread_pitch_mm,
                len=L_th + overlap_mm
            );

        // Tip chamfer at very end
        z_tip_end = z0 - L_un2 - L_th;
        translate([0,0, z_tip_end - chamfer_mm/2])
            cylinder(d1=shank_minor_diameter_mm,
                     d2=max(0.2, shank_minor_diameter_mm - 2*chamfer_mm),
                     h=chamfer_mm, center=true);

        // Wrench flats (hex) blended into shank region
        if (wrench_flats_enabled && wf_len > 0.01) {
            intersection() {
                translate([0,0, wf_zc])
                    hex_prism(wrench_flat_across_flats_mm, wf_len, center=true);

                translate([0,0, wf_zc])
                    cylinder(d=max(wrench_flat_across_flats_mm*1.25, shank_major_diameter_mm*1.25),
                             h=wf_len + 2*overlap_mm, center=true);
            }
        }
    }
}

// -------------------- Assembly --------------------
module assembly() {
    union() {
        rod_end_head();
        shank_with_thread();
    }
}

assembly();