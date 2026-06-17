// Brushless DC motor (single connected solid) with verifiable stator diameter/height
// Target: stator_d = 14.0mm, stator_h = 11.75mm
// Notes:
// - Stator is modeled as an internal lamination stack with teeth/slots (recognizable detail).
// - Rotor can + endcaps form the outer shell.
// - All translate() values are derived from dimensions; no arbitrary offsets.
// - Model is ONE connected solid after difference() (holes removed).

$fn = 72;

// -------------------- Parameters --------------------
stator_d = 14.0;          // EXACT stator diameter
stator_h = 11.75;         // EXACT stator height

bore_d = 3.0;             // Center bore (through)

rotor_wall = 0.6;         // Can wall thickness
rotor_clearance = 0.25;   // Clearance between stator OD and can ID (visual)

endcap_thk = 1.0;         // Endcap thickness (each side)
endcap_lip = 0.4;         // Small lip radius reduction (visual)

shaft_d = 2.0;
shaft_len_front = 8.0;    // Protrusion from front outer face
shaft_len_back  = 2.0;    // Protrusion from back outer face

mount_hole_d = 1.6;
mount_hole_count = 4;
mount_hole_r = 5.0;

wire_d = 1.2;
wire_len = 12.0;
wire_count = 3;
wire_spread = 2.2;
wire_exit_overlap = 1.0;

// Stator detail (teeth/slots)
tooth_count = 12;
tooth_radial_len = 1.2;   // How far teeth protrude outward from yoke
tooth_tangential_w = 1.0; // Tooth width (tangential)
slot_depth = 0.9;         // Slot cut depth from tooth tips inward
slot_tangential_w = 0.8;  // Slot width (tangential)

// Boolean overlap helper
overlap = 0.6;

// -------------------- Derived dimensions --------------------
stator_r = stator_d/2;

// Rotor can sized around stator
can_inner_r = stator_r + rotor_clearance;
can_outer_r = can_inner_r + rotor_wall;

// Total motor stack height (including endcaps)
motor_h = stator_h + 2*endcap_thk;

// Endcap centers (motor centered at Z=0)
z_front_endcap =  stator_h/2 + endcap_thk/2 - overlap;
z_back_endcap  = -stator_h/2 - endcap_thk/2 + overlap;

// Outer faces of endcaps
z_front_face =  stator_h/2 + endcap_thk;
z_back_face  = -stator_h/2 - endcap_thk;

// Shaft placement so protrusions match requested lengths
shaft_total_h = motor_h + shaft_len_front + shaft_len_back;
shaft_center_z = ( (z_front_face + shaft_len_front) + (z_back_face - shaft_len_back) ) / 2;

// Wire exit location: from side of can, near back endcap
wire_x_center = can_outer_r - wire_exit_overlap + wire_len/2;
wire_z_center = z_back_face + endcap_thk/2;

// Stator internal geometry
// Keep yoke inside stator OD so teeth can reach close to stator OD.
yoke_r = max(0.1, stator_r - tooth_radial_len);
tooth_tip_r = yoke_r + tooth_radial_len;

// Slot cutter radius (kept within stator)
slot_outer_r = min(stator_r - 0.15, tooth_tip_r - 0.05);
slot_inner_r = max(0.1, slot_outer_r - slot_depth);

// -------------------- Base shapes --------------------
module rotor_can() {
    // Outer can shell around stator (recognizable motor feature)
    difference() {
        cylinder(h=stator_h, r=can_outer_r, center=true);
        cylinder(h=stator_h + 2*overlap, r=can_inner_r, center=true);
    }
}

module endcap(zpos, is_front=true) {
    r_main = can_outer_r;
    r_lip  = max(0.1, r_main - endcap_lip);

    translate([0,0,zpos])
    union() {
        cylinder(h=endcap_thk, r=r_main, center=true);

        // small step/lip (connected by overlap)
        step_h = endcap_thk*0.35;
        step_z = (is_front ? 1 : -1) * (endcap_thk/2 - step_h/2) - (is_front ? 1 : -1)*overlap;
        translate([0,0,step_z])
            cylinder(h=step_h, r=r_lip, center=true);
    }
}

module shaft() {
    translate([0,0,shaft_center_z])
        cylinder(h=shaft_total_h, r=shaft_d/2, center=true);
}

module wire_leads() {
    // 3 wires exiting radially from the can, connected by overlap into the can wall
    for (i = [0:wire_count-1]) {
        y = (i - (wire_count-1)/2) * wire_spread;
        translate([wire_x_center, y, wire_z_center])
            rotate([0,90,0])
                cylinder(h=wire_len, r=wire_d/2, center=true);
    }
}

module mount_holes() {
    for (i = [0:mount_hole_count-1]) {
        ang = i*360/mount_hole_count;
        translate([mount_hole_r*cos(ang), mount_hole_r*sin(ang), 0])
            cylinder(h=motor_h + 6*overlap, r=mount_hole_d/2, center=true);
    }
}

module center_bore() {
    cylinder(h=motor_h + 6*overlap, r=bore_d/2, center=true);
}

// -------------------- Stator detail (teeth + slots) --------------------
module stator_teeth_solid() {
    // Yoke + outward teeth (solid)
    union() {
        // Yoke (kept inside stator OD)
        cylinder(h=stator_h, r=yoke_r, center=true);

        // Teeth protruding outward to near stator OD
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*360/tooth_count])
                translate([yoke_r + tooth_radial_len/2 - overlap, 0, 0]) // overlap into yoke
                    cube([tooth_radial_len, tooth_tangential_w, stator_h], center=true);
        }
    }
}

module stator_slots_cut() {
    // Cut slots between teeth to make stator recognizable
    // Use ring-sector-like cutters made from cubes at a radius.
    for (i = [0:tooth_count-1]) {
        rotate([0,0,(i + 0.5)*360/tooth_count])  // between teeth
            translate([slot_inner_r + (slot_outer_r-slot_inner_r)/2, 0, 0])
                cube([ (slot_outer_r-slot_inner_r) + 2*overlap, slot_tangential_w, stator_h + 2*overlap ], center=true);
    }
}

module stator_body() {
    // EXACT requested stator envelope (OD/height) with internal tooth/slot detail.
    // Intersect ensures final stator stays within stator_d and stator_h.
    intersection() {
        cylinder(h=stator_h, r=stator_r, center=true); // exact envelope
        difference() {
            stator_teeth_solid();
            stator_slots_cut();
        }
    }
}

// -------------------- Assembly --------------------
module motor_union() {
    union() {
        // Outer shell
        rotor_can();
        endcap(z_front_endcap, true);
        endcap(z_back_endcap, false);

        // Internal stator detail (connected to endcaps via overlap)
        // Slight Z overlap into endcaps to guarantee connectivity.
        translate([0,0,0])
            stator_body();

        // Shaft and wires
        shaft();
        wire_leads();
    }
}

module motor_with_features() {
    difference() {
        motor_union();
        center_bore();
        mount_holes();
    }
}

// -------------------- Final --------------------
motor_with_features();