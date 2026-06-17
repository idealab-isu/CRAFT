$fn=128;

// Lichuan -80M03530B (approximate envelope model)
// Units: mm
// Goal: recognizable 80mm-frame servo with cylindrical body, front flange, pilot, shaft, mounting holes,
// and rear encoder/connector features. ONE connected solid (no floating parts).

// ---------- Parameters ----------
frame = 80;                 // square frame size
body_len = 90;              // motor body length (excluding flange and rear features)
corner_r = 2.5;             // edge rounding

// Cylindrical motor body (inside square envelope)
motor_d = 76;               // typical for 80mm frame
motor_len = body_len;

// Front flange + pilot + shaft
flange_t = 6;
flange_size = frame;

pilot_d = 38;
pilot_t = 2.5;

shaft_d = 19;
shaft_l = 35;

key_w = 6;
key_h = 3;
key_l = 22;
key_z_offset = 6;           // from shaft base (toward flange)

// Mounting holes (front flange)
mount_hole_spacing = 63;    // square pattern
mount_hole_d = 6.6;         // clearance for M6
mount_hole_depth = flange_t + 2;

// Front face details (bolt circle + recess)
face_recess_d = 56;
face_recess_t = 1.2;        // shallow recess
bolt_circle_d = 72;         // typical 80mm servo front bolt circle
bolt_hole_d = 4.6;          // clearance for M4
bolt_hole_depth = flange_t + 1.5;

// Rear cap + encoder boss + connector
rear_cap_t = 4;

encoder_d = 44;
encoder_t = 10;             // protrusion beyond rear cap

connector_w = 26;
connector_h = 18;
connector_l = 16;

gland_d = 12;
gland_l = 10;

// Small overlap to guarantee connectivity in unions
ov = 0.6;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1, center=false){
    sx=size[0]; sy=size[1]; sz=size[2];
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([max(0.01,sx-2*r), max(0.01,sy-2*r), max(0.01,sz-2*r)], center=false);
        sphere(r=r);
    }
}

module servo_80mm(){
    // Coordinate system:
    // X: width, Y: height, Z: length (shaft points -Z, rear features +Z)
    // Front flange occupies Z in [-flange_t, 0], motor body from Z in [0, body_len]

    // Derived Z landmarks
    z_front_flange0 = -flange_t;
    z_front_face    = 0;
    z_body0         = 0;
    z_body1         = body_len;
    z_rear_cap0     = body_len - ov;
    z_rear_cap1     = body_len + rear_cap_t;

    // Connector placement (rear face, offset to a corner)
    conn_margin = 8;
    conn_x =  frame/2 - connector_w/2 - conn_margin;
    conn_y =  frame/2 - connector_h/2 - conn_margin; // top-right on rear view

    difference(){
        union(){
            // --- Main square body (80mm frame) ---
            translate([-frame/2, -frame/2, z_body0])
                rounded_box([frame, frame, body_len], r=corner_r, center=false);

            // --- Cylindrical motor body (adds correct form factor) ---
            // Centered and overlapping into square body.
            translate([0,0, z_body0 + body_len/2])
                cylinder(d=motor_d, h=motor_len + ov, center=true);

            // --- Front flange (square) ---
            translate([-flange_size/2, -flange_size/2, z_front_flange0])
                rounded_box([flange_size, flange_size, flange_t + ov], r=corner_r, center=false);

            // --- Front pilot/boss ---
            // Starts at flange front face (more realistic than floating in front)
            translate([0,0, z_front_flange0 - pilot_t + ov])
                cylinder(d=pilot_d, h=pilot_t + ov, center=false);

            // --- Shaft (extends forward from pilot) ---
            translate([0,0, z_front_flange0 - pilot_t - shaft_l + ov])
                cylinder(d=shaft_d, h=shaft_l, center=false);

            // --- Key on shaft (connected to shaft) ---
            // Key intersects shaft surface; Z positioned from shaft base (near flange).
            z_shaft_base = z_front_flange0 - pilot_t; // where shaft meets pilot
            translate([shaft_d/2 - key_h, -key_w/2, z_shaft_base - shaft_l + key_z_offset])
                cube([key_h + ov, key_w, key_l], center=false);

            // --- Rear cap (flush with body end) ---
            translate([-frame/2, -frame/2, z_rear_cap0])
                rounded_box([frame, frame, rear_cap_t + ov], r=corner_r, center=false);

            // --- Rear encoder boss (cylindrical feature) ---
            translate([0,0, z_rear_cap1 - ov])
                cylinder(d=encoder_d, h=encoder_t + ov, center=false);

            // --- Rear connector block (on rear cap, offset) ---
            // Connected by overlapping into rear cap.
            translate([conn_x - connector_w/2, conn_y - connector_h/2, z_rear_cap1 - ov])
                rounded_box([connector_w, connector_h, connector_l + ov], r=1.5, center=false);

            // --- Cable gland cylinder on connector (protrudes outward) ---
            // Axis along +Y, starting from connector top face; overlaps into connector.
            translate([conn_x, conn_y + connector_h/2 - ov, z_rear_cap1 + connector_l/2])
                rotate([90,0,0])
                    cylinder(d=gland_d, h=gland_l + ov, center=false);
        }

        // --- Mounting holes through front flange (4x) ---
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2, z_front_flange0-0.2])
                cylinder(d=mount_hole_d, h=mount_hole_depth+0.4, center=false);
        }

        // --- Front face recess (gives recognizable faceplate detail) ---
        // Cut shallow recess into the front face (Z in [-face_recess_t, 0])
        translate([0,0, z_front_face - face_recess_t - 0.01])
            cylinder(d=face_recess_d, h=face_recess_t + 0.02, center=false);

        // --- Front bolt circle holes (4x on bolt circle) ---
        for (a=[45,135,225,315]){
            rotate([0,0,a])
                translate([bolt_circle_d/2, 0, z_front_flange0-0.2])
                    cylinder(d=bolt_hole_d, h=bolt_hole_depth+0.4, center=false);
        }

        // --- Optional front corner reliefs (small chamfers) ---
        // Keep subtle and within flange thickness.
        cham = 10;
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(flange_size/2 - cham/2), sy*(flange_size/2 - cham/2), z_front_flange0-0.2])
                rotate([0,0,45])
                    cube([cham, cham, flange_t+0.4], center=false);
        }
    }
}

// ---------- Render ----------
servo_80mm();