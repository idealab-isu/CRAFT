// Pan head screw (single connected solid)
// Requested: 3.5mm shank dia, 6.7mm head dia, 2.2mm head height, 10mm length under head

shaft_diameter_mm = 3.5;          //[1.75:7:0.05]
length_under_head_mm = 10;        //[5:20:0.1]
head_diameter_mm = 6.7;           //[3.35:13.4:0.05]
head_height_mm = 2.2;             //[1.1:4.4:0.05]

// Thread appearance (approximate, for visual screw profile)
thread_pitch_mm = 0.7;            //[0.4:1.2:0.05]
thread_depth_mm = 0.25;           //[0.1:0.5:0.01]
thread_start_clear_mm = 0.6;      //[0:2:0.05]   // unthreaded near head
thread_end_clear_mm = 0.4;        //[0:2:0.05]   // unthreaded at tip

// Drive recess (simple Phillips-like cross, optional)
recess_enable = 1;                //[0:1:1]
recess_depth_mm = 1.0;            //[0.2:1.8:0.05]
recess_width_mm = 1.2;            //[0.6:2.0:0.05]
recess_length_mm = 4.2;           //[2.0:6.0:0.1]

eps = 0.02;
$fn = 96;

module helical_thread(major_d, pitch, depth, len) {
    turns = len / pitch;
    tooth_w = pitch * 0.55;
    tooth_h = depth;
    r_major = major_d/2;
    r_path = r_major - tooth_h/2;

    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*24), 24), convexity=10)
        translate([r_path, 0, 0])
            square([tooth_h, tooth_w], center=true);
}

module pan_head_profile(r_head, h_head, r_shank) {
    // 2D profile for rotate_extrude: z from 0..h_head, x is radius
    // Pan head: mostly cylindrical with a gentle crown (not a button/dome).
    // Ensures exact head diameter and height.
    skirt_h = h_head * 0.70;
    crown_h = h_head - skirt_h;

    // Crown is a shallow arc from (r_head, skirt_h) to (r_head*0.55, h_head)
    // using a quadratic Bezier approximation with a control point.
    r_top = max(r_head * 0.55, r_shank * 0.9);
    ctrl_r = r_head * 0.98;
    ctrl_z = skirt_h + crown_h * 0.35;

    function bez2(p0, p1, p2, t) =
        [ (1-t)*(1-t)*p0[0] + 2*(1-t)*t*p1[0] + t*t*p2[0],
          (1-t)*(1-t)*p0[1] + 2*(1-t)*t*p1[1] + t*t*p2[1] ];

    pts_crown = [
        for (i=[0:12])
            let(t=i/12)
            bez2([r_head, skirt_h], [ctrl_r, ctrl_z], [r_top, h_head], t)
    ];

    // Close polygon to axis for rotate_extrude
    polygon(points=concat(
        [[0,0], [r_shank*1.02, 0]],          // slight under-head land to ensure connection
        [[r_head, 0], [r_head, skirt_h]],    // cylindrical skirt
        pts_crown,                           // crown
        [[0, h_head]]                        // back to axis
    ));
}

module pan_head_screw() {
    shank_r = shaft_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // z=0 at underside of head; head extends to +head_height_mm; shank extends to -length_under_head_mm
    difference() {
        union() {
            // Shank core (minor diameter so thread ridge forms major diameter)
            minor_d = max(shaft_diameter_mm - 2*thread_depth_mm, shaft_diameter_mm*0.85);
            translate([0,0,-length_under_head_mm/2])
                cylinder(h=length_under_head_mm, r=minor_d/2, center=true);

            // Thread ridge (only on threaded portion), connected by overlap
            thread_len = max(length_under_head_mm - thread_start_clear_mm - thread_end_clear_mm, 0);
            if (thread_len > 0) {
                translate([0,0,-(thread_start_clear_mm + thread_len/2) + eps])
                    helical_thread(major_d=shaft_diameter_mm, pitch=thread_pitch_mm, depth=thread_depth_mm, len=thread_len + 2*eps);
            }

            // Tip chamfer (connected)
            tip_h = 0.8;
            translate([0,0,-length_under_head_mm + tip_h/2 - eps])
                cylinder(h=tip_h + 2*eps, r1=shank_r*0.85, r2=shank_r, center=true);

            // Under-head fillet/transition (connected, small overlap into both)
            fillet_h = 0.35;
            translate([0,0,fillet_h/2 - eps])
                cylinder(h=fillet_h + 2*eps, r1=head_r*0.92, r2=shank_r*1.02, center=true);

            // Pan head (more typical profile than a dome), exact dia/height, connected at z=0
            rotate_extrude(convexity=10)
                pan_head_profile(head_r, head_height_mm, shank_r);
        }

        // Drive recess (subtractive), centered on head top
        if (recess_enable) {
            recess_depth = min(recess_depth_mm, head_height_mm - 0.2);
            z_top = head_height_mm;
            z_center = z_top - recess_depth/2;

            translate([0,0,z_center])
                union() {
                    cube([recess_length_mm, recess_width_mm, recess_depth + 2*eps], center=true);
                    cube([recess_width_mm, recess_length_mm, recess_depth + 2*eps], center=true);
                }
        }
    }
}

pan_head_screw();