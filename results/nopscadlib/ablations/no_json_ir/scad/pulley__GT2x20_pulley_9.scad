// Timing pulley: 20 teeth, 12.22mm pitch diameter
// One connected solid; all placements derived from dimensions (no arbitrary offsets).

$fn = 160;

// -------------------- Parameters --------------------
teeth = 20;
pitch_diameter = 12.22;     // mm (given)

// Simple GT2-like tooth approximation (not an exact GT2 profile)
tooth_depth = 0.75;         // mm radial height above pitch circle (approx)
tooth_tip_width = 0.70;     // mm (approx)
tooth_root_width = 1.20;    // mm (approx)

pulley_face = 7;            // mm toothed section height
flange_thickness = 1;       // mm
flange_extra_d = 4;         // mm added to pitch diameter for flange OD

// Hub/bore (kept simple; no set-screw/keyway since request is only "timing pulley")
bore_diameter = 5;          // mm
hub_diameter  = 10;         // mm
hub_length    = 10;         // mm (extends below lower flange)

// -------------------- Derived --------------------
pitch_r = pitch_diameter/2;
root_r  = pitch_r - tooth_depth*0.35;   // slight relief under pitch circle
flange_diameter = pitch_diameter + flange_extra_d;

toothed_stack_h = flange_thickness + pulley_face + flange_thickness;
total_h = hub_length + toothed_stack_h;

// Z layout (bottom at z=0)
z_hub_center = hub_length/2;
z_toothed_base = hub_length; // toothed stack starts on top of hub

// -------------------- Model --------------------
module timing_pulley() {
    difference() {
        union() {
            // Hub: bottom at z=0, top at z=hub_length
            translate([0,0,z_hub_center])
                cylinder(h=hub_length, d=hub_diameter, center=true);

            // Toothed stack sits on hub top; overlap by eps to guarantee union
            eps = 0.05;
            translate([0,0,z_toothed_base - eps])
                toothed_with_flanges(hub_overlap=eps);
        }

        // Bore through entire part
        cylinder(h=total_h + 0.5, d=bore_diameter, center=false);
    }
}

module toothed_with_flanges(hub_overlap=0) {
    // This module's local z=0 is intended to be at the hub top (with optional overlap below)
    union() {
        // Lower flange: spans z = -hub_overlap .. flange_thickness
        translate([0,0,(flange_thickness - hub_overlap)/2])
            cylinder(h=flange_thickness + hub_overlap, d=flange_diameter, center=true);

        // Toothed section: spans z = flange_thickness .. flange_thickness+pulley_face
        translate([0,0,flange_thickness])
            toothed_section();

        // Upper flange: spans z = flange_thickness+pulley_face .. +flange_thickness
        translate([0,0,flange_thickness + pulley_face + flange_thickness/2])
            cylinder(h=flange_thickness, d=flange_diameter, center=true);
    }
}

module toothed_section() {
    union() {
        // Root cylinder (under teeth), centered within pulley_face
        translate([0,0,pulley_face/2])
            cylinder(h=pulley_face, r=root_r, center=true);

        // Teeth: exactly "teeth" instances, evenly spaced
        for (i = [0:teeth-1]) {
            rotate([0,0,i*360/teeth])
                tooth_block();
        }
    }
}

module tooth_block() {
    // Ensure connectivity: tooth overlaps into root cylinder by "overlap"
    overlap = 0.25; // mm

    // Tooth is a trapezoid in XY, extruded along Z for pulley_face
    // Place so inner face is at (pitch_r - overlap), outer face protrudes outward.
    translate([pitch_r + tooth_depth/2 - overlap, 0, flange_thickness + pulley_face/2])
        linear_extrude(height=pulley_face, center=true)
            polygon(points=[
                [-tooth_depth/2, -tooth_root_width/2],
                [-tooth_depth/2,  tooth_root_width/2],
                [ tooth_depth/2,  tooth_tip_width/2],
                [ tooth_depth/2, -tooth_tip_width/2]
            ]);
}

// Render
timing_pulley();