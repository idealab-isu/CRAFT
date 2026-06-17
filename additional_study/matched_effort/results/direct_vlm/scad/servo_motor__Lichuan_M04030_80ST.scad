$fn=96;

// Lichuan -80M04030B (approximate form-factor model)
// Units: mm
// One connected solid; all placements are dimension-derived (no arbitrary offsets).

// ---------- Parameters ----------
motor_body_w = 80;
motor_body_h = 80;
motor_body_len = 90;

front_flange_w = 90;
front_flange_h = 90;
front_flange_th = 6;

rear_cap_th = 6;                 // rear endcap thickness (encoder/connector side)

shaft_d = 19;
shaft_len = 35;

pilot_d = 50;                    // front locating boss
pilot_len = 2.5;

bearing_housing_d = 62;          // front face/bearing housing ring
bearing_housing_th = 3.5;

mount_hole_spacing = 70;         // square pattern
mount_hole_d = 6.6;              // clearance for M6
mount_hole_depth = front_flange_th + 2;

corner_r = 4;

// Side features (typical servo motor details)
side_rib_th = 2.5;               // shallow ribs on sides
side_rib_w  = 14;
side_rib_len = motor_body_len * 0.75;

rear_boss_d = 44;                // rear encoder boss
rear_boss_len = 4;

connector_w = 34;                // rear terminal/connector box (more distinctive)
connector_h = 22;
connector_len = 20;

key_w = 6;
key_h = 3;
key_len = 22;

// Distinct mounting feet/ears on flange (servo-style)
ear_w = 16;                      // ear extension beyond flange on each side
ear_h = 26;                      // ear height (Y)
ear_th = front_flange_th;        // same thickness as flange
ear_hole_d = 9.0;                // clearance for M8-ish mounting
ear_hole_offset_y = 0;           // centered in ear

// Body cable channel / casting detail (bottom)
channel_w = 10;
channel_depth = 1.6;
channel_len = motor_body_len * 0.70;

// Rear connector cover lip
conn_lip = 2.0;

// Small overlap to guarantee manifold unions
ov = 0.6;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=false){
    sx=size[0]; sy=size[1]; sz=size[2];
    rr = min(r, sx/2, sy/2);
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
        minkowski(){
            cube([sx-2*rr, sy-2*rr, sz], center=false);
            cylinder(r=rr, h=0.01);
        }
}

module hole_pattern_square(spacing=70, d=6.6, h=10){
    for (x=[-spacing/2, spacing/2])
        for (y=[-spacing/2, spacing/2])
            translate([x,y,0]) cylinder(d=d, h=h, center=false);
}

// ---------- Model ----------
module servo_80mm(){
    // Coordinate system:
    // Front face of flange at z=0, shaft extends +Z
    // Motor body extends -Z

    rear_face_z = -front_flange_th - motor_body_len - rear_cap_th;

    difference(){
        union(){
            // --- Front flange (with side ears/feet) ---
            // Main flange plate
            translate([-front_flange_w/2, -front_flange_h/2, -front_flange_th])
                rounded_box([front_flange_w, front_flange_h, front_flange_th], r=corner_r, center=false);

            // Left ear (extends -X)
            translate([-front_flange_w/2 - ear_w + ov, -ear_h/2, -ear_th])
                rounded_box([ear_w + ov, ear_h, ear_th], r=3, center=false);

            // Right ear (extends +X)
            translate([front_flange_w/2 - ov, -ear_h/2, -ear_th])
                rounded_box([ear_w + ov, ear_h, ear_th], r=3, center=false);

            // --- Motor body (main) ---
            translate([-motor_body_w/2, -motor_body_h/2, -front_flange_th - motor_body_len])
                rounded_box([motor_body_w, motor_body_h, motor_body_len], r=corner_r, center=false);

            // --- Rear cap (endcap) ---
            translate([-motor_body_w/2, -motor_body_h/2, -front_flange_th - motor_body_len - rear_cap_th])
                rounded_box([motor_body_w, motor_body_h, rear_cap_th], r=corner_r, center=false);

            // --- Front pilot boss (locating) ---
            translate([0,0,0])
                cylinder(d=pilot_d, h=pilot_len, center=false);

            // --- Bearing housing ring on front face (typical servo face detail) ---
            translate([0,0,0])
                cylinder(d=bearing_housing_d, h=bearing_housing_th, center=false);

            // --- Shaft ---
            translate([0,0,pilot_len - ov])
                cylinder(d=shaft_d, h=shaft_len + ov, center=false);

            // --- Key on shaft ---
            translate([shaft_d/2 - key_h, -key_w/2, pilot_len + 2])
                cube([key_h, key_w, key_len], center=false);

            // --- Side ribs (two opposite sides) ---
            // Place ribs centered along body length, attached to side faces with slight overlap.
            rib_z0 = -front_flange_th - (motor_body_len/2) - (side_rib_len/2);
            // +Y side rib
            translate([-side_rib_w/2,
                       motor_body_h/2 - side_rib_th + ov,
                       rib_z0])
                rounded_box([side_rib_w, side_rib_th, side_rib_len], r=1.2, center=false);
            // -Y side rib
            translate([-side_rib_w/2,
                       -motor_body_h/2 - ov,
                       rib_z0])
                rounded_box([side_rib_w, side_rib_th, side_rib_len], r=1.2, center=false);

            // --- Rear encoder boss (centered) ---
            translate([0,0,rear_face_z - rear_boss_len + ov])
                cylinder(d=rear_boss_d, h=rear_boss_len + ov, center=false);

            // --- Rear connector / terminal box (top-rear, more distinctive) ---
            // Attached to rear cap, protruding further back.
            conn_x0 = -connector_w/2;
            conn_y0 = motor_body_h/2 - connector_h;
            conn_z0 = rear_face_z - connector_len + ov;

            translate([conn_x0, conn_y0, conn_z0])
                rounded_box([connector_w, connector_h, connector_len + ov], r=2.5, center=false);

            // Connector cover lip (slight step)
            translate([conn_x0 - conn_lip/2,
                       conn_y0 - conn_lip/2,
                       conn_z0 + connector_len*0.25])
                rounded_box([connector_w + conn_lip,
                             connector_h + conn_lip,
                             connector_len*0.75 + ov], r=2.5, center=false);

            // --- Small rear cable strain relief (under connector) ---
            strain_w = connector_w * 0.55;
            strain_h = connector_h * 0.55;
            strain_len = connector_len * 0.55;
            translate([-strain_w/2,
                       motor_body_h/2 - connector_h - strain_h + ov,
                       rear_face_z - strain_len + ov])
                rounded_box([strain_w, strain_h, strain_len + ov], r=1.5, center=false);

            // --- Bottom cable channel ridge (adds distinct bottom silhouette) ---
            // A shallow ridge centered on bottom face, running along body length.
            // Attached to -Y face with overlap.
            channel_z0 = -front_flange_th - (motor_body_len/2) - (channel_len/2);
            translate([-channel_w/2,
                       -motor_body_h/2 - ov,
                       channel_z0])
                rounded_box([channel_w, channel_depth + ov, channel_len], r=1.0, center=false);
        }

        // --- Mounting holes through flange (4x M6 pattern) ---
        translate([0,0,-front_flange_th-0.1])
            hole_pattern_square(spacing=mount_hole_spacing, d=mount_hole_d, h=mount_hole_depth+0.2);

        // --- Ear mounting holes (2x) ---
        // Through ears only (same thickness as flange), centered in each ear.
        ear_hole_h = ear_th + 0.4;
        translate([-(front_flange_w/2 + ear_w/2), ear_hole_offset_y, -ear_th-0.2])
            cylinder(d=ear_hole_d, h=ear_hole_h, center=false);
        translate([(front_flange_w/2 + ear_w/2), ear_hole_offset_y, -ear_th-0.2])
            cylinder(d=ear_hole_d, h=ear_hole_h, center=false);

        // --- Center relief in flange (face recess) ---
        translate([0,0,-front_flange_th-0.1])
            cylinder(d=28, h=front_flange_th+0.2, center=false);

        // --- Shallow front face recess ring (adds face detail) ---
        recess_d_outer = bearing_housing_d - 6;
        recess_d_inner = pilot_d + 6;
        recess_depth = 1.2;
        translate([0,0,-recess_depth])
            difference(){
                cylinder(d=recess_d_outer, h=recess_depth + 0.2, center=false);
                translate([0,0,-0.1]) cylinder(d=recess_d_inner, h=recess_depth + 0.4, center=false);
            }

        // --- Rear connector face recess (suggests terminal cover) ---
        // Cut a shallow pocket on the rear face of the connector box.
        pocket_w = connector_w * 0.72;
        pocket_h = connector_h * 0.55;
        pocket_d = 1.6;
        translate([-pocket_w/2,
                   (motor_body_h/2 - connector_h) + (connector_h - pocket_h)/2,
                   rear_face_z - pocket_d - 0.1])
            rounded_box([pocket_w, pocket_h, pocket_d + 0.2], r=1.5, center=false);

        // --- Bottom cable channel groove (difference) ---
        // Cut a shallow groove into the body bottom to create a distinct bottom view.
        groove_w = channel_w * 0.65;
        groove_depth = channel_depth;
        groove_len = channel_len * 0.92;
        groove_z0 = -front_flange_th - (motor_body_len/2) - (groove_len/2);
        translate([-groove_w/2,
                   -motor_body_h/2 - 0.1,
                   groove_z0])
            rounded_box([groove_w, groove_depth + 0.2, groove_len], r=0.8, center=false);
    }
}

servo_80mm();