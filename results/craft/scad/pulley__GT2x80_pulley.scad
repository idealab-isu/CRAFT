// Timing pulley: 80 teeth, pitch diameter 50.42mm
// One connected solid, teeth are visible as outward protrusions.

$fn = 240;

// Parameters
tooth_count = 80;
pitch_diameter_mm = 50.42;
pitch_radius_mm = pitch_diameter_mm/2;

pulley_width = 12;

flange_thickness = 1.5;
flange_overhang_radial = 2.0;

bore_diameter = 8;
hub_diameter = 22;
hub_length = 18;

// Tooth geometry (simple GT2-like approximation; visible teeth)
tooth_height = 1.6;          // radial protrusion above pitch circle
tooth_root_depth = 1.0;      // overlap into rim for connectivity
tooth_tangential = 1.35;     // tooth thickness along circumference (at pitch)
tooth_tip_round = 0.35;      // rounding at tooth tip

connection_overlap = 0.6;    // small overlap to guarantee manifold union

// Derived
outer_radius = pitch_radius_mm + tooth_height;
tooth_radial_len = tooth_height + tooth_root_depth;

// Place tooth so it protrudes outward and overlaps inward into rim
tooth_center_r = pitch_radius_mm + (tooth_height - tooth_root_depth)/2 - connection_overlap/2;

// Rim base radius: keep it below tooth tips so teeth are clearly visible
rim_base_radius = pitch_radius_mm - 0.25;

// Ensure rim exists and overlaps teeth
rim_base_radius_safe = max(rim_base_radius, pitch_radius_mm - tooth_root_depth - 0.2);

module pulley_body() {
    union() {
        // Main rim (under pitch circle so teeth stand out)
        cylinder(r = rim_base_radius_safe, h = pulley_width, center = true);

        // Hub (connected)
        cylinder(r = hub_diameter/2, h = hub_length, center = true);

        // Flanges (connected with overlap)
        translate([0, 0, pulley_width/2 + flange_thickness/2 - connection_overlap])
            cylinder(r = outer_radius + flange_overhang_radial, h = flange_thickness, center = true);

        translate([0, 0, -pulley_width/2 - flange_thickness/2 + connection_overlap])
            cylinder(r = outer_radius + flange_overhang_radial, h = flange_thickness, center = true);
    }
}

module tooth_2d() {
    // Tooth profile in XY: radial (X) by tangential (Y)
    // Rounded tip, slightly narrower at root (simple trapezoid-ish via hull)
    root_w = tooth_tangential * 0.95;
    tip_w  = tooth_tangential * 0.70;

    hull() {
        // Root rectangle (inside)
        translate([-tooth_radial_len/2 + tooth_root_depth*0.55, 0])
            square([tooth_root_depth*1.1, root_w], center=true);

        // Tip rounded cap (outside)
        translate([tooth_radial_len/2 - tooth_tip_round, 0])
            circle(r = tooth_tip_round);

        // Tip width control
        translate([tooth_radial_len/2 - tooth_tip_round*2.2, 0])
            square([tooth_tip_round*0.8, tip_w], center=true);
    }
}

module teeth() {
    // Teeth protrude outward; overlap inward for connectivity
    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i * 360/tooth_count])
            translate([tooth_center_r, 0, 0])
                linear_extrude(height = pulley_width + 2*connection_overlap, center = true, convexity=10)
                    tooth_2d();
    }
}

module assembly() {
    difference() {
        union() {
            pulley_body();
            teeth();
        }

        // Bore hole through entire part
        cylinder(
            r = bore_diameter/2,
            h = max(hub_length, pulley_width + 2*flange_thickness) + 6*connection_overlap,
            center = true
        );
    }
}

assembly();