$fn = 128;

// Target: BLDC motor with 28.0mm stator diameter and 27.0mm height
stator_diameter = 28.0;          // mm (verified feature)
stator_height   = 27.0;          // mm (verified feature)

// Motor detailing (kept realistic but simple)
rotor_outer_diameter   = 30.0;   // mm (bell OD)
rotor_can_height       = 22.0;   // mm (bell height around stator)
rotor_wall_thickness   = 1.0;    // mm

shaft_diameter         = 3.0;    // mm
shaft_extension_top    = 8.0;    // mm above bell
shaft_extension_bottom = 6.0;    // mm below base

base_face_thickness    = 2.0;    // mm
base_face_diameter     = 32.0;   // mm

endcap_ring_radial_thickness = 1.0; // mm
endcap_ring_height           = 1.5; // mm

wire_exit_diameter     = 2.0;    // mm
wire_exit_length       = 8.0;    // mm

// Vent/slot parameters on rotor bell
num_slots   = 10;
slot_w      = 3.0;   // tangential width
slot_h      = 8.0;   // vertical height
slot_depth  = rotor_wall_thickness + 0.8; // cut through wall with margin

// Mount holes on base
mount_hole_d = 3.0;
mount_hole_r = 12.0; // radius from center to hole centers
num_mount_holes = 4;

// Overlap to ensure connectivity / avoid coincident faces (REQUIRED 1-2mm)
overlap = 1.2;

// Derived
stator_r = stator_diameter/2;
rotor_r  = rotor_outer_diameter/2;
base_r   = base_face_diameter/2;

// Z layout (center stator at z=0)
z_stator_center = 0;
z_stator_top    = z_stator_center + stator_height/2;
z_stator_bot    = z_stator_center - stator_height/2;

z_base_center   = z_stator_bot - base_face_thickness/2 + overlap; // overlaps into stator
z_base_top      = z_base_center + base_face_thickness/2;

z_rotor_center  = z_stator_top - rotor_can_height/2 + overlap;    // overlaps into stator top
z_rotor_top     = z_rotor_center + rotor_can_height/2;
z_rotor_bot     = z_rotor_center - rotor_can_height/2;

shaft_total_h = shaft_extension_bottom + base_face_thickness + stator_height + shaft_extension_top;
z_shaft_center = z_stator_center + (shaft_extension_top - (base_face_thickness + shaft_extension_bottom))/2;

// Helper: rounded-ish slot cutter (box)
module slot_cutter(w, d, h) {
    cube([d, w, h], center=true);
}

module rotor_bell() {
    // Bell with internal cavity and ventilation slots
    difference() {
        // Outer bell
        translate([0,0,z_rotor_center])
            cylinder(r=rotor_r, h=rotor_can_height, center=true);

        // Inner cavity (leave top cap thickness)
        translate([0,0,z_rotor_center - rotor_wall_thickness/2])
            cylinder(r=rotor_r - rotor_wall_thickness,
                     h=rotor_can_height - rotor_wall_thickness,
                     center=true);

        // Ventilation slots around side
        for (i = [0:num_slots-1]) {
            rotate([0,0,i*360/num_slots])
                translate([rotor_r - slot_depth/2, 0, z_rotor_center])
                    slot_cutter(slot_w, slot_depth, slot_h);
        }
    }
}

module stator_body() {
    // Stator core with simple tooth bumps to show separation from rotor
    union() {
        // Main stator cylinder (exact target dimensions)
        translate([0,0,z_stator_center])
            cylinder(r=stator_r, h=stator_height, center=true);

        // Teeth bumps (ensure they protrude radially so side views show detail)
        tooth_len = 2.2;
        tooth_w   = 2.0;
        tooth_h   = stator_height*0.60;
        num_teeth = 12;

        for (i = [0:num_teeth-1]) {
            rotate([0,0,i*360/num_teeth])
                translate([stator_r + tooth_len/2 - overlap, 0, z_stator_center])
                    cube([tooth_len, tooth_w, tooth_h], center=true);
        }
    }
}

module base_face() {
    // Base plate with mounting holes and a small raised boss
    difference() {
        union() {
            translate([0,0,z_base_center])
                cylinder(r=base_r, h=base_face_thickness, center=true);

            // Small boss around shaft (connects to base and stator)
            boss_r = 6.0;
            boss_h = 1.2;
            translate([0,0,z_base_top + boss_h/2 - overlap])
                cylinder(r=boss_r, h=boss_h, center=true);
        }

        // Mount holes
        for (i = [0:num_mount_holes-1]) {
            rotate([0,0,i*360/num_mount_holes])
                translate([mount_hole_r, 0, z_base_center])
                    cylinder(r=mount_hole_d/2, h=base_face_thickness + 2, center=true);
        }
    }
}

module endcap_rings() {
    // Rings at stator ends to add detail
    for (side = [-1, 1]) {
        z_ring_center = z_stator_center + side*(stator_height/2 - endcap_ring_height/2 + overlap);
        difference() {
            translate([0,0,z_ring_center])
                cylinder(r=stator_r + endcap_ring_radial_thickness,
                         h=endcap_ring_height, center=true);
            translate([0,0,z_ring_center])
                cylinder(r=stator_r - overlap,
                         h=endcap_ring_height + 2*overlap, center=true);
        }
    }
}

module shaft() {
    translate([0,0,z_shaft_center])
        cylinder(r=shaft_diameter/2, h=shaft_total_h, center=true);
}

module wire_exit() {
    // Stub exiting from base area, connected to stator/base
    z_wire = z_base_top + wire_exit_diameter/2; // overlaps into stator
    rotate([0,90,0])
        translate([stator_r + wire_exit_length/2 - overlap, 0, z_wire])
            cylinder(r=wire_exit_diameter/2, h=wire_exit_length, center=true);
}

// External silhouette features so orthographic side views are not a flat circle
module side_ribs() {
    // Small ribs on the rotor bell OD (like cooling fins / grip ribs)
    rib_count = 12;
    rib_len   = 1.4;                 // radial protrusion
    rib_w     = 2.2;                 // tangential width
    rib_h     = rotor_can_height*0.75;
    z_rib     = z_rotor_center;      // centered on bell

    for (i = [0:rib_count-1]) {
        rotate([0,0,i*360/rib_count])
            translate([rotor_r + rib_len/2 - overlap, 0, z_rib])
                cube([rib_len, rib_w, rib_h], center=true);
    }
}

module mounting_ears() {
    // Two small ears on the base flange so front/back/left/right show non-circular silhouette
    ear_len = 6.0;   // radial extension beyond base_r
    ear_w   = 8.0;   // tangential width
    ear_h   = base_face_thickness;

    // Place ears at +/-X
    for (sx = [-1, 1]) {
        translate([sx*(base_r + ear_len/2 - overlap), 0, z_base_center])
            cube([ear_len, ear_w, ear_h], center=true);
    }
}

// FIX: add the missing/previously floating small rectangular tab/plate and ensure it is ATTACHED
module top_flange_tab_connected() {
    // A small plate near the top flange, on the left side (-X), overlapping into rotor bell
    tab_len = 8.0;   // radial length (X direction)
    tab_w   = 6.0;   // tangential width (Y direction)
    tab_h   = 2.0;   // thickness (Z direction)

    // Place it near the rotor bottom edge (top flange region), and overlap into the bell by 'overlap'
    // Ensure physical intersection with rotor outer wall:
    // inner face of tab at x = -(rotor_r - overlap)
    // center x = -(rotor_r - overlap + tab_len/2)
    x_tab = -(rotor_r - overlap + tab_len/2);

    // Put it close to the rotor bottom (where flange detail is visible), but still within bell height
    // Centered slightly above rotor bottom so it doesn't miss the bell due to slot cutouts.
    z_tab = z_rotor_bot + tab_h/2 + overlap;

    translate([x_tab, 0, z_tab])
        cube([tab_len, tab_w, tab_h], center=true);
}

module BLDC_motor_connected() {
    // ONE connected solid: union of all positive solids, with internal subtractions only where needed
    union() {
        base_face();
        mounting_ears();
        stator_body();
        endcap_rings();
        rotor_bell();
        side_ribs();
        top_flange_tab_connected(); // <-- connectivity fix: attached tab/plate
        shaft();
        wire_exit();
    }
}

BLDC_motor_connected();