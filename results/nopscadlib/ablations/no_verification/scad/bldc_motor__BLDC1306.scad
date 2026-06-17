$fn = 128;

// -------------------- Target dimensions (stator) --------------------
stator_diameter = 17.75;   // mm
stator_height   = 14.5;    // mm

// -------------------- Motor outer geometry (small outrunner style) ---
rotor_outer_diameter = 19.75; // mm (outer can OD)
rotor_height         = 16.0;  // mm (can height)
rotor_wall           = 0.6;   // mm (can wall)
clearance_radial     = 0.25;  // mm (airgap/clearance)

// -------------------- Shaft --------------------
shaft_diameter = 3.0;   // mm
shaft_length   = 30.0;  // mm

// -------------------- End features / mounting -----------------------
endcap_thickness = 1.0;   // mm (front/back lips)
base_thickness   = 1.6;   // mm (rear mounting face thickness)
base_diameter    = rotor_outer_diameter; // mm

mount_hole_d        = 2.0;   // mm
mount_bolt_circle_d = 12.0;  // mm
num_mount_holes     = 4;

hub_diameter   = 8.0;   // mm
hub_thickness  = 1.6;   // mm

// -------------------- Visual cues: stator teeth + rotor vents --------
num_teeth   = 12;
tooth_depth = 1.2;  // mm (radial)
tooth_width = 1.6;  // mm (tangential)

num_vents   = 8;
vent_w      = 2.0;  // mm (tangential)
vent_h      = 6.0;  // mm (axial)
vent_inset  = 0.25; // mm (keep vents inside outer surface)

// -------------------- Connectivity / robustness ----------------------
overlap = 0.6; // mm (intentional overlap to guarantee one connected solid)

// -------------------- Derived --------------------
stator_r = stator_diameter/2;
rotor_r  = rotor_outer_diameter/2;

// Z layout: stator centered at Z=0 with exact height 14.5mm
z_stator_c = 0;
z_rotor_c  = 0;

// Rear base overlaps into rotor can
z_base_c = -rotor_height/2 - base_thickness/2 + overlap;

// Front hub overlaps into rotor can
z_hub_c  =  rotor_height/2 + hub_thickness/2 - overlap;

// -------------------- Modules --------------------
module stator_with_teeth() {
    union() {
        cylinder(r=stator_r, h=stator_height, center=true);

        // Teeth protrude outward; overlap into stator for connectivity
        for (i = [0:num_teeth-1]) {
            rotate([0,0,i*360/num_teeth])
                translate([stator_r + tooth_depth/2 - overlap, 0, 0])
                    cube([tooth_depth, tooth_width, stator_height], center=true);
        }
    }
}

module rotor_can_shell() {
    // Hollow can: outer cylinder minus inner cavity (single subtraction)
    // Inner radius chosen to leave rotor_wall thickness and clear stator + clearance.
    inner_r = max(stator_r + clearance_radial, rotor_r - rotor_wall);

    difference() {
        cylinder(r=rotor_r, h=rotor_height, center=true);

        // Inner cavity (slightly taller to avoid coplanar faces)
        cylinder(r=inner_r, h=rotor_height + 2*overlap, center=true);

        // Simple vent slots (visual cue), cut through the wall region
        // Positioned near outer radius but inset to keep a rim.
        for (i = [0:num_vents-1]) {
            rotate([0,0,i*360/num_vents])
                translate([rotor_r - vent_inset - vent_w/2, 0, 0])
                    cube([vent_w, vent_w, vent_h], center=true);
        }
    }
}

module rear_base_with_mounts() {
    difference() {
        translate([0,0,z_base_c])
            cylinder(r=base_diameter/2, h=base_thickness, center=true);

        for (i = [0:num_mount_holes-1]) {
            rotate([0,0,i*360/num_mount_holes])
                translate([mount_bolt_circle_d/2, 0, z_base_c])
                    cylinder(r=mount_hole_d/2, h=base_thickness + 2*overlap, center=true);
        }
    }
}

module front_hub() {
    translate([0,0,z_hub_c])
        cylinder(r=hub_diameter/2, h=hub_thickness, center=true);
}

module endcap_lips() {
    // Thin lips at both ends of the can (visual cue), overlapping into can
    union() {
        translate([0,0, rotor_height/2 - endcap_thickness/2])
            cylinder(r=rotor_r, h=endcap_thickness, center=true);
        translate([0,0,-rotor_height/2 + endcap_thickness/2])
            cylinder(r=rotor_r, h=endcap_thickness, center=true);
    }
}

module shaft() {
    cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
}

// -------------------- Assembly: ONE connected solid ------------------
union() {
    // Stator (exact requested size)
    translate([0,0,z_stator_c]) stator_with_teeth();

    // Rotor can (hollow shell)
    translate([0,0,z_rotor_c]) rotor_can_shell();

    // End lips (connect to can)
    translate([0,0,z_rotor_c]) endcap_lips();

    // Rear mounting face (overlaps into can)
    rear_base_with_mounts();

    // Front hub (overlaps into can)
    front_hub();

    // Shaft passes through and connects everything
    shaft();
}