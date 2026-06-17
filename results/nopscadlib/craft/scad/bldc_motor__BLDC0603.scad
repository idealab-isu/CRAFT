// Brushless DC motor (simplified) with 9.0mm stator diameter and 8.0mm stator height
// One connected solid, no floating parts, all translations derived from dimensions.

stator_diameter_mm = 9.0;          //[4.5:18:0.1]
stator_height_mm   = 8.0;          //[4:16:0.1]

airgap_mm          = 0.25;         //[0.1:0.6:0.05]
rotor_wall_mm      = 0.6;          //[0.3:1.2:0.05]
rotor_overhang_mm  = 0.2;          //[0:1:0.05]

endbell_thk_mm     = 0.8;          //[0.4:1.5:0.05]
endbell_step_mm    = 0.4;          //[0:1:0.05]

shaft_diameter_mm  = 1.5;          //[0.8:3:0.05]
shaft_front_len_mm = 3.0;          //[1:8:0.1]
shaft_back_len_mm  = 1.0;          //[0:4:0.1]

mount_boss_d_mm    = 2.2;          //[1.5:4:0.1]
mount_boss_h_mm    = 0.8;          //[0.4:2:0.05]

wire_d_mm          = 0.7;          //[0.3:1.2:0.05]
wire_len_mm        = 6.0;          //[2:15:0.5]
wire_pitch_mm      = 1.0;          //[0.6:2:0.05]  // spacing between wires
wire_exit_w_mm     = 2.0;          //[1:4:0.1]
wire_exit_h_mm     = 1.2;          //[0.6:3:0.1]

overlap_mm         = 0.25;         //[0.1:1:0.05]
$fn = 96;

// ---------- Derived dimensions ----------
stator_r = stator_diameter_mm/2;

// Keep rotor OD close to stator OD (micro outrunner-ish look)
rotor_outer_diameter_mm = stator_diameter_mm + 1.0;
rotor_outer_r = rotor_outer_diameter_mm/2;

// Rotor inner radius leaves airgap to stator
rotor_inner_r = stator_r + airgap_mm;

// Clamp to ensure wall thickness
rotor_inner_r_clamped = min(rotor_outer_r - rotor_wall_mm, rotor_inner_r);

rotor_height_mm = stator_height_mm + rotor_overhang_mm;

z_rotor_top  =  rotor_height_mm/2;
z_rotor_bot  = -rotor_height_mm/2;

endbell_r = rotor_outer_r;
endbell_step_r = max(0.01, endbell_r - endbell_step_mm);

boss_r = mount_boss_d_mm/2;

// Place wire exit on the side of the BACK endbell, centered in its thickness
wire_exit_z = z_rotor_bot + endbell_thk_mm/2; // center of back endbell thickness
wire_exit_x = endbell_r - wire_exit_h_mm/2 - overlap_mm; // embed into can/endbell

// ---------- Modules ----------
module rotor_can() {
    // Hollow can (shell) around stator
    difference() {
        cylinder(r=rotor_outer_r, h=rotor_height_mm, center=true);
        cylinder(r=rotor_inner_r_clamped, h=rotor_height_mm + 2*overlap_mm, center=true);
    }
}

module endbell(zsign=1) {
    // zsign: +1 front, -1 back
    zc = zsign*(rotor_height_mm/2 - endbell_thk_mm/2 + overlap_mm/2); // overlap into rotor
    translate([0,0,zc])
    union() {
        cylinder(r=endbell_r, h=endbell_thk_mm, center=true);
        translate([0,0,zsign*(endbell_thk_mm/2 - overlap_mm/2)])
            cylinder(r=endbell_step_r, h=endbell_thk_mm/2, center=true);
    }
}

module stator_core() {
    // Solid stator cylinder (simplified)
    cylinder(r=stator_r, h=stator_height_mm, center=true);
}

module shaft() {
    // Shaft passes through motor and protrudes front/back
    shaft_total_h = stator_height_mm + shaft_front_len_mm + shaft_back_len_mm;
    zc = (shaft_front_len_mm - shaft_back_len_mm)/2;
    translate([0,0,zc])
        cylinder(r=shaft_diameter_mm/2, h=shaft_total_h, center=true);
}

module mount_boss() {
    // Boss on back endbell (connected)
    zc = z_rotor_bot + endbell_thk_mm/2;
    translate([0,0,zc])
        cylinder(r=boss_r, h=mount_boss_h_mm, center=true);
}

module wire_bundle() {
    // Exit block embedded into back endbell/can
    translate([wire_exit_x, 0, wire_exit_z])
        cube([wire_exit_h_mm + 2*overlap_mm, wire_exit_w_mm, endbell_thk_mm], center=true);

    // Three wires leaving from the exit block (connected by overlap)
    for (i = [-1, 0, 1]) {
        yoff = i * wire_pitch_mm;
        // Start inside exit block by overlap, extend outward in +X
        translate([
            wire_exit_x + (wire_exit_h_mm/2) - overlap_mm + wire_len_mm/2,
            yoff,
            wire_exit_z
        ])
            rotate([0,90,0])
                cylinder(r=wire_d_mm/2, h=wire_len_mm, center=true);
    }
}

// ---------- Assembly (ONE connected solid) ----------
union() {
    // Outer rotor can + endbells (ensures a recognizable motor can)
    rotor_can();
    endbell(+1);
    endbell(-1);

    // Stator inside (touches nothing by design, but we must keep ONE connected solid:
    // connect stator to endbells with a tiny hidden bridge inside the can.
    // This preserves the visual airgap while making the mesh one solid.
    union() {
        stator_core();

        // Hidden bridge: thin rib from stator OD to rotor inner wall, inside the can
        // Positioned near back endbell so it is not visible from most angles.
        bridge_thk = max(0.2, overlap_mm);
        bridge_h   = max(0.8, endbell_thk_mm/2);
        bridge_z   = z_rotor_bot + endbell_thk_mm + bridge_h/2 - overlap_mm; // inside can, near back
        bridge_r0  = stator_r - bridge_thk/2;
        bridge_r1  = rotor_inner_r_clamped + bridge_thk/2;

        translate([0,0,bridge_z])
            rotate([0,0,0])
                linear_extrude(height=bridge_h, center=true)
                    polygon(points=[
                        [bridge_r0, -bridge_thk/2],
                        [bridge_r1, -bridge_thk/2],
                        [bridge_r1,  bridge_thk/2],
                        [bridge_r0,  bridge_thk/2]
                    ]);
    }

    // Shaft (through)
    shaft();

    // Back mounting boss + wires (connected to back endbell)
    mount_boss();
    wire_bundle();
}