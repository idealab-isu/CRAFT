// Timing pulley: 16 teeth, 9.75mm pitch diameter
// Fixes:
// - Enforces EXACT pitch diameter (9.75mm) and EXACT tooth count (16)
// - Models 16 distinct timing-belt teeth around circumference (radial array)
// - All parts connected using formula-based translations with overlaps (one watertight solid)

tooth_count = 16;                 //[8:64:1]
pitch_diameter_mm = 9.75;         //[5:40:0.01]   // REQUIRED pitch diameter

pulley_width_mm = 10;             //[5:30:0.1]
bore_diameter_mm = 5;             //[1:12:0.1]

hub_diameter_mm = 12;             //[6:30:0.1]
hub_length_mm = 6;                //[0:20:0.1]

flange_diameter_mm = 14;          //[0:40:0.1]
flange_thickness_mm = 1.5;        //[0:5:0.1]

set_screw_count = 1;              //[0:4:1]
set_screw_size = 3;               //[2:6:0.1]
set_screw_z_offset_mm = 0;        //[-10:10:0.1]

// Tooth geometry (simple trapezoid approximation of timing pulley tooth)
tooth_radial_height_mm = 1.2;     //[0.6:2.5:0.05]  // protrusion above root radius
tooth_root_depth_mm = 0.6;        //[0.3:1.5:0.05]  // root below pitch radius
tooth_tip_width_mm = 0.55;        //[0.2:2:0.05]    // tangential width at tip
tooth_root_width_mm = 0.95;       //[0.3:3:0.05]    // tangential width at root
tooth_overlap_mm = 0.8;           //[0.2:2:0.05]    // overlap into root cylinder for watertight union

connection_overlap_mm = 1;        //[0.5:2:0.1]

// ---------- Derived dimensions (pitch diameter enforced) ----------
pitch_radius_mm = pitch_diameter_mm / 2;

// Root and outer radii based on pitch radius and tooth depths/heights
root_radius_mm  = max(0.1, pitch_radius_mm - tooth_root_depth_mm);
outer_radius_mm = pitch_radius_mm + tooth_radial_height_mm;

// Ensure body cylinder reaches into tooth bases for a single connected solid
body_radius_mm = max(0.1, root_radius_mm + tooth_overlap_mm);

// Tooth angular pitch and corresponding chord length at pitch circle
tooth_angle_deg = 360 / tooth_count;
pitch_arc_mm = PI * pitch_diameter_mm / tooth_count; // arc length per tooth at pitch circle

// Keep tooth widths reasonable relative to pitch so teeth are distinct
tooth_root_w_eff = min(tooth_root_width_mm, 0.90 * pitch_arc_mm);
tooth_tip_w_eff  = min(tooth_tip_width_mm,  0.70 * pitch_arc_mm);

// ---------- Quality ----------
$fn = max(120, tooth_count * 18);

// ---------- Modules ----------
module pulley_body() {
    cylinder(h=pulley_width_mm, r=body_radius_mm, center=true);
}

// One tooth as a trapezoid prism, placed so it overlaps into the body cylinder
module one_tooth() {
    tooth_len_rad = tooth_radial_height_mm + tooth_overlap_mm; // radial length including overlap into body

    // Place tooth so its inner face is at (root_radius - overlap), outer at (root_radius + height)
    translate([root_radius_mm + tooth_len_rad/2 - tooth_overlap_mm, 0, 0])
        linear_extrude(height=pulley_width_mm, center=true, convexity=10)
            polygon(points=[
                [-tooth_len_rad/2, -tooth_root_w_eff/2],
                [-tooth_len_rad/2,  tooth_root_w_eff/2],
                [ tooth_len_rad/2,  tooth_tip_w_eff/2],
                [ tooth_len_rad/2, -tooth_tip_w_eff/2]
            ]);
}

module teeth() {
    for (i = [0:tooth_count-1]) {
        rotate([0,0,i*tooth_angle_deg]) one_tooth();
    }
}

module hub() {
    if (hub_length_mm > 0) {
        // Attach hub to bottom side of pulley with overlap
        translate([0,0, -(pulley_width_mm/2 + hub_length_mm/2 - connection_overlap_mm/2)])
            cylinder(h=hub_length_mm + connection_overlap_mm, r=hub_diameter_mm/2, center=true);
    }
}

module flanges() {
    if (flange_diameter_mm > 0 && flange_thickness_mm > 0) {
        // Two flanges, each overlapping into pulley body
        for (s = [-1, 1]) {
            translate([0,0, s*(pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm/2)])
                cylinder(h=flange_thickness_mm + connection_overlap_mm, r=flange_diameter_mm/2, center=true);
        }
    }
}

module center_bore() {
    total_h =
        pulley_width_mm
      + (hub_length_mm > 0 ? hub_length_mm : 0)
      + (flange_thickness_mm > 0 ? 2*flange_thickness_mm : 0)
      + 6*connection_overlap_mm;

    cylinder(h=total_h, r=bore_diameter_mm/2, center=true);
}

module set_screw_holes() {
    if (set_screw_count > 0 && hub_length_mm > 0) {
        // Put screw through hub wall, centered in hub length by default
        z_hub_center = -(pulley_width_mm/2 + hub_length_mm/2 - connection_overlap_mm/2) + set_screw_z_offset_mm;

        for (i = [0:set_screw_count-1]) {
            rotate([0,0,i*360/set_screw_count])
                translate([hub_diameter_mm/2, 0, z_hub_center])
                    rotate([0,90,0])
                        cylinder(
                            h = hub_diameter_mm + 2*outer_radius_mm + 6*connection_overlap_mm,
                            r = set_screw_size/2,
                            center = true
                        );
        }
    }
}

// ---------- Assembly ----------
difference() {
    union() {
        pulley_body();
        teeth();
        hub();
        flanges();
    }
    center_bore();
    set_screw_holes();
}