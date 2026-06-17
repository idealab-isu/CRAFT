$fn=96;

// Lichuan -80M01330B servo motor (80mm frame class) - feature-complete connected solid
// Units: mm
// Coordinate system: Front flange face at Z=0, motor extends in +Z, shaft extends in -Z.

ov = 0.6; // overlap for watertight unions

// ---------- Parameters (approximate, 80mm frame proportions) ----------
motor_body_w = 80;
motor_body_h = 80;
motor_body_len = 130;

front_flange_w = 90;
front_flange_h = 90;
front_flange_th = 6;

front_pilot_d = 55;      // centering boss
front_pilot_h = 2.5;

shaft_d = 19;
shaft_len = 35;

shaft_key_w = 6;
shaft_key_h = 2.8;
shaft_key_len = 22;

mount_hole_spacing = 70; // square pattern
mount_hole_d = 6.6;      // clearance for M6
mount_hole_depth = front_flange_th + 2;

rear_cap_th = 6;

// Rear housing step (typical servo rear cover detail)
rear_step_inset = 4;     // inset from body edges
rear_step_len = 18;      // length of stepped section before rear cap

// Connector/terminal box (side-mounted near rear)
connector_box_w = 40;    // X thickness (outward from side)
connector_box_h = 30;    // Y size
connector_box_len = 26;  // Z size

cable_gland_d = 12;
cable_gland_len = 12;

// Cooling fins (subtle ribs on top/bottom)
fin_count = 7;
fin_pitch = 10;
fin_th = 1.6;
fin_h = 2.2;
fin_span_x = motor_body_w - 10;

// Optional feet/lugs (connected)
foot_w = 18;
foot_h = 10;
foot_len = 40;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=false){
    minkowski(){
        cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=center);
        sphere(r=r);
    }
}

module bolt_holes_on_flange(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2, -0.1])
            cylinder(d=mount_hole_d, h=mount_hole_depth+0.2, center=false);
    }
}

module keyway(){
    // key on shaft (rectangular protrusion)
    translate([shaft_d/2 - 0.2, -shaft_key_w/2, 0])
        cube([shaft_key_h, shaft_key_w, shaft_key_len], center=false);
}

module flange_rim(){
    // subtle raised rim on flange front face
    rim_w = 2.2;
    rim_th = 1.2;
    difference(){
        translate([-front_flange_w/2, -front_flange_h/2, -rim_th + ov])
            rounded_box([front_flange_w, front_flange_h, rim_th], r=2.5, center=false);
        translate([-(front_flange_w-2*rim_w)/2, -(front_flange_h-2*rim_w)/2, -rim_th - 0.1])
            rounded_box([front_flange_w-2*rim_w, front_flange_h-2*rim_w, rim_th+0.2], r=2.0, center=false);
    }
}

module rear_step(){
    // stepped rear housing section (inset)
    step_w = motor_body_w - 2*rear_step_inset;
    step_h = motor_body_h - 2*rear_step_inset;
    translate([-step_w/2, -step_h/2, front_flange_th + motor_body_len - rear_step_len])
        rounded_box([step_w, step_h, rear_step_len + ov], r=2.5, center=false);
}

module connector_box_side(){
    // Side-mounted connector box on +X side, near rear, centered in Y
    // Ensure it intersects body by ov.
    x0 = motor_body_w/2 - ov;                 // start slightly inside body
    y0 = -connector_box_h/2;
    z0 = front_flange_th + motor_body_len - rear_step_len - connector_box_len - 8;

    translate([x0, y0, z0])
        rounded_box([connector_box_w, connector_box_h, connector_box_len], r=2, center=false);

    // Cable gland protruding outward from connector box (+X direction)
    translate([motor_body_w/2 + connector_box_w - ov, 0, z0 + connector_box_len/2])
        rotate([0,90,0])
            cylinder(d=cable_gland_d, h=cable_gland_len, center=false);
}

module body_feet(){
    // Two small lugs on bottom face (negative Y), connected to body
    lug_z = front_flange_th + 22;
    lug_h = 12;
    translate([-motor_body_w/2 + ov, -motor_body_h/2 - foot_h + ov, lug_z])
        rounded_box([foot_len, foot_h, lug_h], r=1.5, center=false);
    translate([motor_body_w/2 - foot_len - ov, -motor_body_h/2 - foot_h + ov, lug_z])
        rounded_box([foot_len, foot_h, lug_h], r=1.5, center=false);
}

module cooling_fins(){
    // Ribs on top (+Y) and bottom (-Y), connected to body with overlap
    // Placed along Z, avoiding flange and rear cap.
    z_start = front_flange_th + 10;
    z_end   = front_flange_th + motor_body_len - rear_cap_th - 10;
    usable  = max(0, z_end - z_start);
    n = min(fin_count, max(1, floor(usable/fin_pitch)));

    for (i=[0:n-1]){
        zc = z_start + (i+0.5) * (usable/n);
        // top fin
        translate([-fin_span_x/2, motor_body_h/2 - ov, zc - fin_th/2])
            cube([fin_span_x, fin_h + ov, fin_th], center=false);
        // bottom fin
        translate([-fin_span_x/2, -motor_body_h/2 - fin_h + ov, zc - fin_th/2])
            cube([fin_span_x, fin_h + ov, fin_th], center=false);
    }
}

module front_faceplate_detail(){
    // Slightly raised faceplate ring around pilot (cosmetic, connected)
    ring_od = front_pilot_d + 14;
    ring_id = front_pilot_d + 2;
    ring_th = 1.4;

    translate([0,0,-ring_th + ov])
    difference(){
        cylinder(d=ring_od, h=ring_th, center=false);
        translate([0,0,-0.1]) cylinder(d=ring_id, h=ring_th+0.2, center=false);
    }
}

module shaft_shoulder(){
    // Small shoulder at shaft base (common on servos), connected to flange/pilot
    sh_d = shaft_d + 10;
    sh_h = 3.0;
    translate([0,0,-sh_h + ov])
        cylinder(d=sh_d, h=sh_h, center=false);
}

// ---------- Model ----------
module servo_80M01330B(){
    difference(){
        union(){
            // Front flange (base)
            translate([-front_flange_w/2, -front_flange_h/2, 0])
                rounded_box([front_flange_w, front_flange_h, front_flange_th], r=2.5, center=false);

            // Flange rim detail (raised ring on front face)
            flange_rim();

            // Faceplate ring detail
            front_faceplate_detail();

            // Main body (starts at back of flange)
            translate([-motor_body_w/2, -motor_body_h/2, front_flange_th - ov])
                rounded_box([motor_body_w, motor_body_h, motor_body_len + ov], r=3, center=false);

            // Cooling fins
            cooling_fins();

            // Rear stepped housing section
            rear_step();

            // Rear cap
            translate([-motor_body_w/2, -motor_body_h/2, front_flange_th + motor_body_len - ov])
                rounded_box([motor_body_w, motor_body_h, rear_cap_th + ov], r=3, center=false);

            // Front pilot (centering boss) - protrudes forward from flange
            translate([0,0, -front_pilot_h])
                cylinder(d=front_pilot_d, h=front_pilot_h + ov, center=false);

            // Shaft shoulder
            shaft_shoulder();

            // Shaft (centered on flange)
            translate([0,0, -shaft_len])
                cylinder(d=shaft_d, h=shaft_len + ov, center=false);

            // Key on shaft
            translate([0,0, -shaft_key_len])
                keyway();

            // Connector/terminal box + cable gland (connected to body)
            connector_box_side();

            // Optional feet/lugs (connected)
            body_feet();
        }

        // Mounting holes through flange
        bolt_holes_on_flange();

        // Pilot relief in flange so pilot stands proud only
        cylinder(d=front_pilot_d-0.6, h=front_flange_th+0.2, center=false);

        // Shaft center bore hint (cosmetic)
        translate([0,0,-shaft_len-0.1])
            cylinder(d=5, h=shaft_len+0.2, center=false);
    }
}

servo_80M01330B();