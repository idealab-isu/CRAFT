// Pan head screw: 2.2mm shank dia, 4.2mm head dia, 1.7mm head height, 10mm length under head
// One connected solid; includes visible pan head, visible helical thread approximation, and Phillips recess.

shaft_diameter = 2.2; //[1.1:4.4:0.1]
length_under_head = 10; //[5:20:0.5]
head_diameter = 4.2; //[2.1:8.4:0.1]
head_height = 1.7; //[0.85:3.4:0.05]

drive_recess_enabled = 1; //[0:1:1]
drive_recess_depth_factor = 0.55; //[0.2:0.8:0.01]
drive_recess_width_factor = 0.58; //[0.3:0.8:0.01]

threads_enabled = 1; //[0:1:1]
thread_pitch = 0.6; //[0.4:1.2:0.05]
thread_height = 0.18; //[0.08:0.35:0.01]
thread_starts = 1; //[1:2:1]

overlap = 0.20; //[0.05:0.5:0.01]
$fn = 128;

// ---- Derived ----
shaft_r = shaft_diameter/2;
head_r  = head_diameter/2;

recess_depth = head_height * drive_recess_depth_factor;
recess_w = head_diameter * drive_recess_width_factor;
recess_arm_w = recess_w * 0.26;   // arm thickness
recess_arm_l = recess_w * 0.62;   // arm length

// Coordinate convention:
// Head top at z=0, underside of head at z=-head_height
// Shank runs from z=-head_height down to z=-(head_height + length_under_head)

module pan_head() {
    // Pan head: cylindrical skirt + rounded dome (rotate_extrude profile)
    skirt_h = head_height * 0.55;
    dome_h  = head_height - skirt_h;

    // Dome curvature control
    dome_r = max(0.01, min(head_r*1.2, dome_h*2.2));

    rotate_extrude(convexity=10)
        union() {
            // Skirt (straight wall)
            polygon(points=[
                [0,      -head_height],
                [head_r, -head_height],
                [head_r, -head_height + skirt_h],
                [0,      -head_height + skirt_h]
            ]);

            // Dome: hull between two circles to create a visible rounded top
            hull() {
                // circle at skirt top, near outer edge
                translate([head_r - dome_r*0.55, -head_height + skirt_h])
                    circle(r=dome_r*0.55);

                // smaller circle near the top center to round off
                translate([head_r*0.35, 0])
                    circle(r=max(0.01, dome_r*0.22));
            }
        }
}

module phillips_recess() {
    // Cut a Phillips cross into the head top (z in [-recess_depth, 0])
    // Slight taper helps visibility and avoids coplanar artifacts.
    translate([0,0,-recess_depth])
        linear_extrude(height=recess_depth + overlap, scale=0.92, convexity=10)
            union() {
                square([recess_arm_l*2, recess_arm_w], center=true);
                square([recess_arm_w, recess_arm_l*2], center=true);
            }
}

module helical_thread(z_top, z_bot) {
    // Adds a helical rib around the shank between z_top (near head) and z_bot (near tip)
    // Uses linear_extrude with twist; cross-section is a small triangle placed at radius.
    thread_len = z_top - z_bot; // positive
    slices = max(60, ceil(thread_len/0.08));
    turns  = thread_len / thread_pitch;

    for (s = [0:thread_starts-1]) {
        rotate([0,0, s*360/thread_starts])
            translate([0,0,z_bot])
                linear_extrude(height=thread_len, twist=360*turns, slices=slices, convexity=10)
                    translate([shaft_r - thread_height*0.15, 0, 0])
                        polygon(points=[
                            [0, -thread_height*0.55],
                            [thread_height, 0],
                            [0,  thread_height*0.55]
                        ]);
    }
}

module shank_with_threads() {
    // Core cylinder is slightly under nominal so added thread reaches ~shaft_diameter + 2*thread_height
    core_r = max(0.01, shaft_r - thread_height*0.55);

    // Shank core: from z=-head_height to z=-(head_height+length_under_head)
    translate([0,0,-head_height - length_under_head])
        cylinder(h=length_under_head + overlap, r=core_r, center=false);

    if (threads_enabled) {
        // Thread starts just below head to ensure connection, ends near tip leaving a small lead-in
        lead_in = min(0.8, length_under_head*0.12);
        z_top = -head_height + overlap; // slightly into head underside for guaranteed union
        z_bot = -head_height - length_under_head + lead_in;

        if (z_top > z_bot)
            helical_thread(z_top=z_top, z_bot=z_bot);
    }
}

module screw() {
    difference() {
        union() {
            pan_head();
            shank_with_threads();
        }
        if (drive_recess_enabled)
            phillips_recess();
    }
}

screw();