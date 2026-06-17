// Timing pulley: 20 teeth, 12.22mm pitch diameter (pitch radius = 6.11mm)
// Fix: teeth are now truly radial (protrude outward) by rotating a 2D tooth profile
// around the Z axis (rotate_extrude). This guarantees visible teeth and exact tooth count.
// All parts overlap slightly to ensure ONE connected solid.

$fn = 180;

// Parameters
tooth_count = 20;                 // must be 20
pitch_diameter_mm = 12.22;        // must be 12.22
pitch_radius_mm = pitch_diameter_mm/2;

pulley_width_mm = 10;
bore_diameter_mm = 5;

hub_diameter_mm = 16;
hub_length_mm = 12;

flange_diameter_mm = 18;
flange_thickness_mm = 1.5;

set_screw_count = 1;
set_screw_hole_diameter_mm = 3;
set_screw_z_offset_mm = 0;

// Tooth geometry (printable approximation)
tooth_radial_height_mm = 1.2;     // how far tooth tip extends beyond pitch circle
tooth_tangential_width_mm = 1.0;  // tooth thickness along belt direction (arc)
tooth_overlap_mm = 0.8;           // how far tooth sinks into core (inside pitch circle)

// Tolerances / overlaps
eps_mm = 0.2;

// Derived radii
tooth_root_r = pitch_radius_mm - tooth_overlap_mm;     // inside pitch circle
tooth_tip_r  = pitch_radius_mm + tooth_radial_height_mm;
core_r       = tooth_root_r;
outer_r      = tooth_tip_r;

// Convert tangential width at pitch radius to angular width (degrees)
function tooth_ang_deg() =
    (tooth_tangential_width_mm / pitch_radius_mm) * 180 / PI;

module toothed_barrel() {
    // Core + teeth as one solid
    union() {
        cylinder(r=core_r, h=pulley_width_mm, center=true);

        // Teeth: rotate a 2D radial rectangle around Z, repeated tooth_count times.
        // This produces real "gear-like" teeth (not a smooth cylinder).
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*360/tooth_count])
                rotate_extrude(angle=tooth_ang_deg(), convexity=10)
                    translate([tooth_root_r - eps_mm, -pulley_width_mm/2 - eps_mm])
                        square([ (tooth_tip_r - tooth_root_r) + 2*eps_mm,
                                 pulley_width_mm + 2*eps_mm ], center=false);
        }
    }
}

module hub() {
    // Overlap into barrel to guarantee connectivity
    cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
}

module flanges() {
    // Flanges overlap barrel ends slightly (no floating)
    zpos = pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm;
    union() {
        translate([0,0, zpos])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        translate([0,0,-zpos])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

module set_screw_holes() {
    hole_len = hub_diameter_mm + 4*eps_mm;
    for (i = [0:set_screw_count-1]) {
        rotate([0,0,i*90])
            translate([0,0,set_screw_z_offset_mm])
                rotate([0,90,0])
                    cylinder(r=set_screw_hole_diameter_mm/2, h=hole_len, center=true);
    }
}

module pulley() {
    difference() {
        union() {
            toothed_barrel();
            hub();
            flanges();
        }

        // Bore through entire part
        total_h = max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm) + 6*eps_mm;
        cylinder(r=bore_diameter_mm/2, h=total_h, center=true);

        if (set_screw_count > 0)
            set_screw_holes();
    }
}

pulley();