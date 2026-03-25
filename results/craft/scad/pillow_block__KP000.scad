// Pillow block bearing (KP-style) for 10mm shaft, 67x53 base
// One connected solid, with raised bearing seat/arch, central bore, and 4 mounting through-holes.

// ---------- Parameters ----------
shaft_diameter_mm = 10; //[5:20:0.5]
base_length_mm = 67; //[34:134:1]
base_width_mm  = 53; //[27:106:1]
base_thickness_mm = 10; //[5:20:1]

housing_length_mm = 50; //[25:100:1]
housing_width_mm  = 36; //[18:72:1]
housing_height_mm = 34; //[17:68:1]

bearing_outer_diameter_mm = 30; //[18:60:0.5]
bearing_boss_length_mm = 22; //[12:44:1]

mounting_hole_diameter_mm = 6; //[3:12:0.5]
mounting_hole_spacing_x_mm = 54; //[30:62:1]
mounting_hole_spacing_y_mm = 38; //[20:48:1]

clearance_mm = 0.3; //[0:1:0.05]
overlap_mm = 1; //[0.5:2:0.1]

// ---------- Quality ----------
$fn = 96;

// ---------- Helpers ----------
module rounded_rect_prism(size=[10,10,10], r=2, center=true) {
    // size = [x,y,z]
    x=size[0]; y=size[1]; z=size[2];
    r2 = min(r, x/2, y/2);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r2)
                square([x-2*r2, y-2*r2], center=true);
}

module kp_body_solid() {
    // Base
    base_r = 3;
    base_zc = base_thickness_mm/2;

    // Housing block sits on base
    housing_zc = base_thickness_mm + housing_height_mm/2 - overlap_mm;

    // Bearing seat (arch) centered on housing, axis along X
    seat_r = bearing_outer_diameter_mm/2;
    seat_len = bearing_boss_length_mm;

    // Place seat so its bottom slightly intersects the housing top region
    // (ensures connectivity and a "raised" look)
    seat_zc = base_thickness_mm + housing_height_mm - seat_r*0.55;

    union() {
        // Base plate
        translate([0,0,base_zc])
            rounded_rect_prism([base_length_mm, base_width_mm, base_thickness_mm], r=base_r, center=true);

        // Main housing block
        translate([0,0,housing_zc])
            rounded_rect_prism([housing_length_mm, housing_width_mm, housing_height_mm], r=2, center=true);

        // Raised bearing seat (cylindrical boss)
        translate([0,0,seat_zc])
            rotate([0,90,0])
                cylinder(r=seat_r, h=seat_len, center=true);

        // Side gussets (triangular ribs) to resemble KP pillow block
        // Connect from base to seat area on both sides (Y +/-)
        gusset_th = (base_width_mm - housing_width_mm)/2 + 2; // extend slightly onto base
        gusset_th = max(gusset_th, 4);

        for (sy = [-1, 1]) {
            translate([0, sy*(housing_width_mm/2 + gusset_th/2 - overlap_mm), base_thickness_mm - overlap_mm])
                rotate([90,0,0])
                    linear_extrude(height=gusset_th, center=true)
                        polygon(points=[
                            [-housing_length_mm/2, 0],
                            [ housing_length_mm/2, 0],
                            [ housing_length_mm/2, housing_height_mm*0.55],
                            [-housing_length_mm/2, housing_height_mm*0.25]
                        ]);
        }
    }
}

module kp_cutouts() {
    // Through bore for shaft (axis along X), passes through seat and housing
    seat_r = bearing_outer_diameter_mm/2;
    seat_zc = base_thickness_mm + housing_height_mm - seat_r*0.55;

    bore_r = (shaft_diameter_mm + clearance_mm)/2;
    bore_len = base_length_mm + 2*overlap_mm;

    translate([0,0,seat_zc])
        rotate([0,90,0])
            cylinder(r=bore_r, h=bore_len, center=true);

    // Mounting holes (4) through base
    hole_h = base_thickness_mm + 2*overlap_mm;
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*mounting_hole_spacing_x_mm/2,
                       sy*mounting_hole_spacing_y_mm/2,
                       base_thickness_mm/2])
                cylinder(r=mounting_hole_diameter_mm/2, h=hole_h, center=true);

    // Optional shallow counterbore (very small) to make holes visible in renders
    cb_r = mounting_hole_diameter_mm/2 + 1.2;
    cb_h = min(2.0, base_thickness_mm*0.35);
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*mounting_hole_spacing_x_mm/2,
                       sy*mounting_hole_spacing_y_mm/2,
                       base_thickness_mm - cb_h/2 + overlap_mm*0.2])
                cylinder(r=cb_r, h=cb_h + overlap_mm, center=true);
}

// ---------- Final Model ----------
difference() {
    kp_body_solid();
    kp_cutouts();
}