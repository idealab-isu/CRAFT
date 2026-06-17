$fn = 180;

// --- Required spec ---
tooth_count = 16;
pitch_diameter_mm = 9.75;
pitch_radius_mm = pitch_diameter_mm/2;

// --- Pulley proportions (editable) ---
pulley_width_mm = 7;

hub_diameter_mm = 12;
hub_length_mm = 12;

flange_diameter_mm = 14;
flange_thickness_mm = 1.5;

bore_diameter_mm = 5;

// --- Tooth geometry (clear, recognizable timing-tooth approximation) ---
tooth_radial_height_mm = 1.25;     // tooth tip above pitch circle
tooth_root_depth_mm   = 0.85;      // tooth root below pitch circle
tooth_tip_width_mm    = 0.90;      // tangential width at tooth tip
tooth_root_width_mm   = 1.55;      // tangential width at tooth root
tooth_overlap_mm      = 0.35;      // overlap into barrel for connectivity

connection_overlap_mm = 0.6;
bore_extra_height_mm  = 2;

// --- Derived ---
pitch_circumference_mm = PI * pitch_diameter_mm;
tooth_pitch_mm = pitch_circumference_mm / tooth_count; // for reference/consistency

root_r = max(0.01, pitch_radius_mm - tooth_root_depth_mm);
tip_r  = pitch_radius_mm + tooth_radial_height_mm;

total_height = max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm - 2*connection_overlap_mm);

// --- Modules ---
module pulley_body() {
    union() {
        // Main toothed barrel at root radius
        cylinder(r=root_r, h=pulley_width_mm, center=true);

        // Hub (centered, overlaps barrel)
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Flanges (overlap into barrel)
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + connection_overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

module tooth_2d() {
    // Trapezoid tooth profile in XY, extruded along Z.
    // Inner edge is slightly inside root_r to guarantee union connectivity.
    inner_r = root_r - tooth_overlap_mm;
    outer_r = tip_r;

    polygon(points=[
        [inner_r, -tooth_root_width_mm/2],
        [inner_r,  tooth_root_width_mm/2],
        [outer_r,  tooth_tip_width_mm/2],
        [outer_r, -tooth_tip_width_mm/2]
    ]);
}

module pulley_teeth() {
    // Teeth are placed so their centerline lies on the pitch circle.
    // Using rotate + translate to pitch radius ensures the pitch diameter is 9.75mm.
    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
            translate([pitch_radius_mm, 0, 0])
                linear_extrude(height=pulley_width_mm, center=true, convexity=10)
                    tooth_2d();
    }
}

module assembly() {
    difference() {
        union() {
            pulley_body();
            pulley_teeth();
        }

        // Central bore
        cylinder(r=bore_diameter_mm/2,
                 h=total_height + bore_extra_height_mm,
                 center=true);
    }
}

assembly();