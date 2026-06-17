// Timing pulley: 20 teeth, 12.22mm pitch diameter
// Single connected solid with clearly countable teeth and connected hub/flanges

$fn = 220;

// Parameters
tooth_count      = 20;
pitch_diameter   = 12.22;                 // mm (pitch circle diameter)
pitch_radius     = pitch_diameter/2;

belt_pitch       = PI * pitch_diameter / tooth_count; // mm per tooth at pitch circle

pulley_face_w    = 7;                     // mm (toothed section width)
bore_diameter    = 5;                     // mm

hub_diameter     = 8;                     // mm
hub_length       = 10;                    // mm

flange_thickness = 1;                     // mm
flange_diameter  = pitch_diameter + 4;    // mm

// Tooth geometry (simple rectangular timing-tooth approximation)
tooth_radial     = 1.6;                   // mm radial tooth height above root
tooth_width      = belt_pitch * 0.45;     // mm tangential tooth thickness (narrower -> clearer tooth gaps)
tooth_overlap    = 0.8;                   // mm sinks into root cylinder for guaranteed union

// Root radius chosen so pitch circle lies within tooth body (approximation)
// Ensure enough material around bore
root_radius      = max(pitch_radius - tooth_radial*0.55, bore_diameter/2 + 1.2);
outer_radius     = root_radius + tooth_radial;

// Tooth prism (extruded along Z by pulley_face_w)
module tooth_prism() {
    // Inner face overlaps into root cylinder by tooth_overlap
    translate([root_radius + tooth_radial/2 - tooth_overlap, 0, 0])
        cube([tooth_radial + 2*tooth_overlap, tooth_width, pulley_face_w], center=true);
}

// Toothed section (root cylinder + radial array of teeth)
module toothed_section() {
    union() {
        cylinder(h=pulley_face_w, r=root_radius, center=true);
        for (i = [0:tooth_count-1])
            rotate([0, 0, i * 360/tooth_count])
                tooth_prism();
    }
}

// Hub + flanges, all connected to toothed section
module hub_and_flanges() {
    overlap_z = 0.25; // small overlap to guarantee connectivity

    union() {
        // Hub centered; overlaps toothed section automatically (hub_length > pulley_face_w)
        cylinder(h=hub_length, d=hub_diameter, center=true);

        // Flanges at ends of toothed section with overlap into toothed section
        translate([0, 0, pulley_face_w/2 + flange_thickness/2 - overlap_z])
            cylinder(h=flange_thickness, d=flange_diameter, center=true);

        translate([0, 0, -pulley_face_w/2 - flange_thickness/2 + overlap_z])
            cylinder(h=flange_thickness, d=flange_diameter, center=true);
    }
}

// Complete pulley
module pulley() {
    total_h = max(hub_length, pulley_face_w + 2*flange_thickness);

    difference() {
        union() {
            toothed_section();
            hub_and_flanges();
        }

        // Bore through entire part
        cylinder(h=total_h + 2, d=bore_diameter, center=true);
    }
}

pulley();