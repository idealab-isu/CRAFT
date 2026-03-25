// Timing pulley: 16 teeth, 9.75mm pitch diameter (pitch circle)
// Standalone pulley only (no extra shaft/rod)

// ---------- Parameters ----------
tooth_count = 16;                 // teeth
pitch_diameter_mm = 9.75;         // pitch diameter
pitch_radius_mm = pitch_diameter_mm/2;

pulley_width_mm = 10;

tooth_radial_height_mm = 1.2;     // tooth protrusion above pitch circle
tooth_root_clearance_mm = 0.6;    // below pitch circle (root depth)

bore_diameter_mm = 5;

hub_diameter_mm = 14;
hub_length_mm = 12;

flange_outer_diameter_mm = 18;
flange_thickness_mm = 1.5;

set_screw_count = 1;              // 0..2
set_screw_hole_diameter_mm = 3;
set_screw_z_offset_mm = 0;
set_screw_hole_length_mm = 30;

overlap_mm = 0.4;                 // small overlap to ensure manifold unions

$fn = 220;

// ---------- Derived radii ----------
root_radius_mm  = max(0.1, pitch_radius_mm - tooth_root_clearance_mm);
outer_radius_mm = pitch_radius_mm + tooth_radial_height_mm;

// Tooth angular width derived from pitch circumference so tooth count is verifiable.
// (This is a simplified tooth form, not a specific belt standard profile.)
pitch_circumference_mm = PI * pitch_diameter_mm;
tooth_pitch_mm = pitch_circumference_mm / tooth_count;
tooth_arc_fraction = 0.55; // fraction of tooth pitch occupied by tooth at pitch circle
tooth_arc_mm = tooth_pitch_mm * tooth_arc_fraction;
tooth_angle_deg = (tooth_arc_mm / pitch_circumference_mm) * 360;

// ---------- Modules ----------
module pulley_body() {
    union() {
        // Root cylinder (under teeth)
        cylinder(r=root_radius_mm, h=pulley_width_mm, center=true);

        // Hub (centered)
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Flanges (connected with overlap)
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
            cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
            cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

module timing_teeth() {
    // Create teeth as wedge sectors so they are clearly visible and countable.
    // Each tooth overlaps into the root cylinder to ensure a single connected solid.
    tooth_h = pulley_width_mm - 2*overlap_mm;
    tooth_z = 0;

    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
            translate([0, 0, tooth_z])
                rotate_extrude(angle=tooth_angle_deg, convexity=10)
                    translate([root_radius_mm - overlap_mm, 0, 0])
                        square([ (outer_radius_mm - (root_radius_mm - overlap_mm)), tooth_h ], center=false);
    }
}

module set_screw_holes() {
    if (set_screw_count > 0) {
        for (i = [0:set_screw_count-1]) {
            // 1 hole at 0°, 2 holes at 0° and 90°
            rotate([0, 0, i*180/set_screw_count])
                rotate([0, 90, 0])
                    translate([hub_diameter_mm/2 - set_screw_hole_diameter_mm/2, 0, set_screw_z_offset_mm])
                        cylinder(r=set_screw_hole_diameter_mm/2, h=set_screw_hole_length_mm, center=true);
        }
    }
}

module timing_pulley() {
    difference() {
        union() {
            pulley_body();
            timing_teeth();
        }

        // Bore through entire part
        total_h = max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm) + 2*overlap_mm;
        cylinder(r=bore_diameter_mm/2, h=total_h, center=true);

        // Set screw holes
        set_screw_holes();
    }
}

// ---------- Output ----------
timing_pulley();