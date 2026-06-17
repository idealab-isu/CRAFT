$fn=96;

// Lichuan -80M02430B (approximate parametric model)
// Units: mm
// One connected solid with recognizable servo features:
// - Front flange + faceplate recess + pilot + shaft
// - 4 mounting holes (through + shallow counterbore)
// - Rear cap + rear boss
// - Side connector + cable gland
// All translate() values derived from dimensions; small overlaps ensure connectivity.

ov = 0.6;   // overlap for unions
eps = 0.01;

// ---------- Parameters ----------
motor_body_w = 80;
motor_body_h = 80;
motor_body_l = 90;

front_flange_w = 80;
front_flange_h = 80;
front_flange_t = 6;

corner_r = 4;

// Front face details
pilot_d = 55;          // front pilot (register) diameter
pilot_h = 2.5;

face_recess_d = 72;    // shallow circular recess on faceplate
face_recess_h = 1.2;

bolt_ring_d = 66;      // decorative bolt ring (raised)
bolt_ring_w = 3.0;
bolt_ring_h = 0.8;

shaft_d = 19;
shaft_l = 35;
shaft_flat_depth = 2.0;
shaft_flat_len = 22;

// Mounting holes (typical 80mm frame)
mount_hole_d = 6.6;       // clearance for M6
mount_hole_spacing = 63;  // square pattern center-to-center
mount_hole_csk_d = 11.5;  // shallow counterbore approximation
mount_hole_csk_h = 2.0;

// Rear features
rear_cap_t = 6;
rear_cap_d = 78;
rear_boss_d = 40;
rear_boss_h = 2.5;

// Connector block (approx)
conn_w = 28;
conn_h = 22;
conn_l = 18;
conn_inset = 6;           // how far connector sits in from side face
conn_from_bottom = 10;    // distance from bottom edge to connector bottom
conn_from_rear = 10;      // distance from rear face to connector rear

// Cable gland (approx)
gland_d = 12;
gland_l = 10;

// Coordinate convention:
// Front face at z=0, motor extends +z, shaft extends -z
front_face_z = 0;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=true){
    sx=size[0]; sy=size[1]; sz=size[2];
    minkowski(){
        cube([max(0.01,sx-2*r), max(0.01,sy-2*r), max(0.01,sz-2*r)], center=center);
        sphere(r=r);
    }
}

module mount_holes(z0, total_h){
    // Through holes + shallow counterbore on front face
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2, z0 - 1])
            cylinder(d=mount_hole_d, h=total_h + 2);
        translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2, z0])
            cylinder(d=mount_hole_csk_d, h=mount_hole_csk_h);
    }
}

module d_shaft(d=19, l=35, flat_depth=2.0, flat_len=22){
    difference(){
        cylinder(d=d, h=l);
        translate([d/2 - flat_depth, -d, 0])
            cube([d, 2*d, min(flat_len,l)], center=false);
    }
}

module servo_80mm_solid(){
    body_z0 = front_face_z + front_flange_t;
    body_z1 = body_z0 + motor_body_l;

    // Connector placement derived from body dimensions (on +X side)
    conn_center_x = (motor_body_w/2 - conn_inset - conn_w/2);
    conn_center_y = (-motor_body_h/2 + conn_from_bottom + conn_h/2);
    conn_center_z = (body_z1 - conn_from_rear - conn_l/2);

    // Gland placement: protrude out of +X face of connector, overlap into connector
    gland_center_x = conn_center_x + conn_w/2 + gland_l/2 - ov;
    gland_center_y = conn_center_y;
    gland_center_z = conn_center_z;

    union(){
        // --- Front flange plate ---
        translate([-front_flange_w/2, -front_flange_h/2, front_face_z])
            cube([front_flange_w, front_flange_h, front_flange_t], center=false);

        // --- Main body (overlap into flange) ---
        translate([-motor_body_w/2, -motor_body_h/2, body_z0 - ov])
            rounded_box([motor_body_w, motor_body_h, motor_body_l + ov], r=corner_r, center=false);

        // --- Front pilot boss (overlap into flange/body) ---
        translate([0,0,front_face_z + front_flange_t - ov])
            cylinder(d=pilot_d, h=pilot_h + ov);

        // --- Faceplate details (raised ring) ---
        // Raised ring sits on the flange front face and overlaps slightly into it.
        translate([0,0,front_face_z - ov])
            difference(){
                cylinder(d=bolt_ring_d + 2*bolt_ring_w, h=bolt_ring_h + ov);
                translate([0,0,-eps])
                    cylinder(d=bolt_ring_d, h=bolt_ring_h + ov + 2*eps);
            }

        // --- Rear cap (overlap into body) ---
        translate([0,0,body_z1 - ov])
            cylinder(d=rear_cap_d, h=rear_cap_t + ov);

        // --- Rear boss (overlap into rear cap) ---
        translate([0,0,body_z1 + rear_cap_t - ov])
            cylinder(d=rear_boss_d, h=rear_boss_h + ov);

        // --- Side connector block (overlap into body side) ---
        translate([conn_center_x, conn_center_y, conn_center_z])
            rounded_box([conn_w + ov, conn_h, conn_l], r=2, center=true);

        // --- Cable gland (overlap into connector) ---
        translate([gland_center_x, gland_center_y, gland_center_z])
            rotate([0,90,0])
                cylinder(d=gland_d, h=gland_l + ov, center=true);

        // --- Shaft (overlap into pilot/flange) ---
        translate([0,0,front_face_z - shaft_l])
            d_shaft(d=shaft_d, l=shaft_l + ov, flat_depth=shaft_flat_depth, flat_len=shaft_flat_len);
    }
}

module servo_80mm(){
    body_z0 = front_face_z + front_flange_t;
    body_z1 = body_z0 + motor_body_l;
    total_h_for_holes = front_flange_t + pilot_h + 2; // enough to pass flange + pilot

    difference(){
        // Base solid
        servo_80mm_solid();

        // Mounting holes
        mount_holes(front_face_z, total_h_for_holes);

        // Faceplate recess (subtractive) on front face
        translate([0,0,front_face_z - eps])
            cylinder(d=face_recess_d, h=face_recess_h + eps);
    }
}

servo_80mm();