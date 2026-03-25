// Sheet silicone (simple connected sheet with rounded corners)
// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 12; //[6:24:1]
edge_fillet_radius = 1; //[0.5:3:0.25]
overlap = 0.5; //[0.2:2:0.1]

$fn = 96;

// 2D rounded rectangle (centered)
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                circle(r=R2);
    }
}

// Main sheet with optional edge fillet via minkowski
module silicone_sheet() {
    R = min(corner_radius, min(sheet_length, sheet_width)/2);
    fil = min(edge_fillet_radius, sheet_thickness/2 - 0.01);

    if (fil <= 0) {
        linear_extrude(height=sheet_thickness, center=true)
            rounded_rect_2d(sheet_length, sheet_width, R);
    } else {
        minkowski() {
            linear_extrude(height=sheet_thickness - 2*fil, center=true)
                rounded_rect_2d(sheet_length, sheet_width, R - fil);
            sphere(r=fil);
        }
    }
}

// Final output
color([0.2, 0.2, 0.2]) silicone_sheet();