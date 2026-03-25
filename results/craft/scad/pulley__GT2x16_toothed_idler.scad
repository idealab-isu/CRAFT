// Timing pulley: 16 teeth, 9.75mm pitch diameter (pitch circle)
// One connected solid; teeth are radial around circumference and countable.

tooth_count = 16;
pitch_diameter_mm = 9.75;

pulley_width_mm = 10;                 // toothed section width (between flanges)
tooth_radial_height_mm = 1.2;         // tooth height above pitch circle
tooth_overlap_mm = 0.6;               // overlap into ring for solid union

ring_radial_thickness_mm = 1.6;       // material below pitch circle to tooth root

bore_diameter_mm = 5;

hub_diameter_mm = 12;
hub_length_mm = 8;

flange_diameter_mm = 14;
flange_thickness_mm = 1.5;

set_screw_count = 1;                  // 0..2
set_screw_hole_diameter_mm = 2.5;
set_screw_z_offset_mm = 4;            // from bottom of hub upward

eps_mm = 0.2;
$fn = 160;

// ---- Derived ----
pitch_radius_mm = pitch_diameter_mm/2;

// Tooth spacing along pitch circle
tooth_pitch_mm = PI * pitch_diameter_mm / tooth_count;

// Approximate timing-tooth proportions (printable, not a specific belt standard)
tooth_tip_width_mm  = 0.45 * tooth_pitch_mm;
tooth_root_width_mm = 0.75 * tooth_pitch_mm;

// Radii
root_radius_mm  = max(0.2, pitch_radius_mm - ring_radial_thickness_mm);
outer_radius_mm = pitch_radius_mm + tooth_radial_height_mm;

// ---- Modules ----
module pulley_core() {
    union() {
        // Toothed ring base (up to tooth root)
        cylinder(r=root_radius_mm, h=pulley_width_mm, center=true);

        // Hub attached to bottom of toothed section (with overlap)
        translate([0, 0, -(pulley_width_mm/2 + hub_length_mm/2 - eps_mm)])
            cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Flanges at both ends of toothed section (with overlap)
        translate([0, 0, +(pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm)])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0, 0, -(pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm)])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

module tooth_2d() {
    // 2D trapezoid in XY: X=radial, Y=tangential
    // Inner face starts slightly inside pitch circle to guarantee union.
    x0 = pitch_radius_mm - tooth_overlap_mm;     // inner (toward center)
    x1 = outer_radius_mm;                        // outer (tooth tip)
    w0 = tooth_root_width_mm;
    w1 = tooth_tip_width_mm;

    polygon(points=[
        [x0, -w0/2],
        [x1, -w1/2],
        [x1,  w1/2],
        [x0,  w0/2]
    ]);
}

module timing_teeth() {
    // Teeth are extruded along Z (pulley width) and arrayed around Z axis.
    union() {
        for (i = [0:tooth_count-1]) {
            rotate([0, 0, i*360/tooth_count])
                linear_extrude(height=pulley_width_mm, center=true, convexity=10)
                    tooth_2d();
        }
    }
}

module bore_hole() {
    total_h = pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 6*eps_mm;
    cylinder(r=bore_diameter_mm/2, h=total_h, center=true);
}

module set_screw_holes() {
    if (set_screw_count > 0) {
        // Hub center is at z = -(pulley_width/2 + hub_length/2 - eps)
        hub_center_z = -(pulley_width_mm/2 + hub_length_mm/2 - eps_mm);
        hub_bottom_z = hub_center_z - hub_length_mm/2;
        hole_z = hub_bottom_z + set_screw_z_offset_mm;

        for (i = [0:set_screw_count-1]) {
            rotate([0, 0, i*90])
                translate([0, 0, hole_z])
                    rotate([0, 90, 0])
                        cylinder(r=set_screw_hole_diameter_mm/2,
                                 h=hub_diameter_mm + 4*eps_mm,
                                 center=true);
        }
    }
}

// ---- Final Assembly ----
difference() {
    union() {
        pulley_core();
        timing_teeth();
    }
    bore_hole();
    set_screw_holes();
}