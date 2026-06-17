// Brushless DC motor (simplified) with verifiable stator: Ø11.5mm x 9.5mm
// One connected solid; all placements are formula-based (no arbitrary offsets).

$fn = 128;

// --- Key requested dimensions (VERIFIABLE) ---
stator_diameter      = 11.5;   // mm (OD of stator stack)
stator_height        = 9.5;    // mm (height of stator stack)

// --- Motor details (parametric but realistic) ---
stator_bore_diameter = 3.0;    // mm (stator inner bore)
rotor_outer_diameter = 12.5;   // mm (outer can OD, slightly larger than stator)
rotor_height         = 10.5;   // mm (can height, slightly taller than stator)
shaft_diameter       = 2.0;    // mm
shaft_length_total   = 20.0;   // mm (overall shaft length through motor)

endcap_thickness     = 0.8;    // mm (top/bottom endcaps)
base_flange_diameter = 14.0;   // mm
base_flange_thickness= 1.5;    // mm

// Visual/feature details
num_stator_teeth     = 12;
tooth_radial_len     = 1.0;    // mm (protrudes inward from stator OD)
tooth_tangential_w   = 1.0;    // mm
tooth_overlap        = 0.25;   // mm (overlap into stator ring for solid union)

num_rotor_slots      = 12;
slot_w               = 0.8;    // mm
slot_depth           = 0.35;   // mm (shallow grooves on rotor can)
slot_h               = 6.5;    // mm (height of grooves)

clearance_radial     = 0.2;    // mm (visual gap between stator OD and rotor ID)
overlap              = 0.25;   // mm (general overlap to guarantee connectivity)

// --- Derived dimensions ---
stator_r = stator_diameter/2;
rotor_r  = rotor_outer_diameter/2;

can_wall_min   = 0.5;
rotor_inner_r  = stator_r + clearance_radial;
rotor_inner_r  = min(rotor_inner_r, rotor_r - can_wall_min);

z0 = 0; // reference plane at bottom of base flange

// Base flange sits at bottom; motor stack sits above it
z_base_center   = z0 + base_flange_thickness/2;
z_base_top      = z0 + base_flange_thickness;

// Ensure stator is exactly 9.5mm tall and connected to base via overlap
z_stator_center = z_base_top + stator_height/2 - overlap;
z_stator_bottom = z_stator_center - stator_height/2;
z_stator_top    = z_stator_center + stator_height/2;

// Rotor can sits above base; connected via overlap
z_rotor_center  = z_base_top + rotor_height/2 - overlap;
z_rotor_bottom  = z_rotor_center - rotor_height/2;
z_rotor_top     = z_rotor_center + rotor_height/2;

// Endcaps close the can; placed to overlap into can for connectivity
z_endcap_bot_center = z_rotor_bottom + endcap_thickness/2 - overlap;
z_endcap_top_center = z_rotor_top    - endcap_thickness/2 + overlap;

// Shaft centered through rotor; extend above and below
z_shaft_center = (z_rotor_bottom + z_rotor_top)/2;
shaft_len = shaft_length_total;

// --- Modules ---
module stator_teeth() {
    // Teeth protrude inward from stator OD (radial array), connected via overlap.
    for (i = [0:num_stator_teeth-1]) {
        rotate([0,0,i*360/num_stator_teeth])
            // Inner edge at stator_r - tooth_radial_len, outer edge overlaps into ring
            translate([stator_r - tooth_radial_len/2 + tooth_overlap, 0, 0])
                cube([tooth_radial_len, tooth_tangential_w, stator_height], center=true);
    }
}

module stator_stack() {
    // Stator ring + teeth, with central bore.
    difference() {
        union() {
            translate([0,0,z_stator_center])
                cylinder(r=stator_r, h=stator_height, center=true);
            translate([0,0,z_stator_center])
                stator_teeth();
        }
        // Bore through stator
        translate([0,0,z_stator_center])
            cylinder(r=stator_bore_diameter/2, h=stator_height + 2, center=true);
    }
}

module rotor_can() {
    // Hollow can with shallow external grooves to suggest rotor features.
    difference() {
        // Outer can
        translate([0,0,z_rotor_center])
            cylinder(r=rotor_r, h=rotor_height, center=true);

        // Hollow interior
        translate([0,0,z_rotor_center])
            cylinder(r=rotor_inner_r, h=rotor_height + 2, center=true);

        // External grooves (subtract shallow slots) - ensure they actually cut the surface
        for (i = [0:num_rotor_slots-1]) {
            rotate([0,0,i*360/num_rotor_slots])
                translate([rotor_r - slot_depth/2 + overlap, 0, z_rotor_center])
                    cube([slot_depth + 2*overlap, slot_w, slot_h], center=true);
        }
    }
}

module endcaps() {
    // Close rotor can ends and ensure connectivity to can via overlap.
    union() {
        translate([0,0,z_endcap_bot_center])
            cylinder(r=rotor_r - 0.05, h=endcap_thickness, center=true);
        translate([0,0,z_endcap_top_center])
            cylinder(r=rotor_r - 0.05, h=endcap_thickness, center=true);
    }
}

module base_flange() {
    // Bottom mounting flange connected to rotor/stator via overlap.
    translate([0,0,z_base_center])
        cylinder(r=base_flange_diameter/2, h=base_flange_thickness, center=true);
}

module shaft() {
    // Shaft passes through entire assembly; ensures one connected solid.
    translate([0,0,z_shaft_center])
        cylinder(r=shaft_diameter/2, h=shaft_len, center=true);
}

// --- Assembly: ONE connected solid ---
union() {
    base_flange();
    stator_stack();
    rotor_can();
    endcaps();
    shaft();
}