// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 10; //[5:20:1]
chamfer_size = 0.8; //[0.3:2:0.1]
film_thickness = 0.08; //[0.03:0.2:0.01]
overlap = 1; //[0.5:2:0.1]
film_inset = 0.5; //[0.2:2:0.1]

$fn = 32;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep parameters valid
r  = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2);
c  = clamp(chamfer_size, 0, min(sheet_length, sheet_width)/2 - r);
fi = clamp(film_inset, 0, min(sheet_length, sheet_width)/2 - r);
eps = 0.01;

// 2D rounded rectangle (fast hull of 4 circles)
module rounded_rect_2d(L, W, R) {
    L2 = max(L, eps);
    W2 = max(W, eps);
    R2 = clamp(R, 0, min(L2, W2)/2);

    if (R2 <= 0)
        square([L2, W2], center=true);
    else
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L2/2 - R2), sy*(W2/2 - R2)])
                    circle(r=R2);
        }
}

// Acrylic sheet with simplified chamfer (single hull between top/bottom outlines)
module acrylic_sheet() {
    if (c <= 0) {
        linear_extrude(height=sheet_thickness, center=true)
            rounded_rect_2d(sheet_length, sheet_width, r);
    } else {
        // Ensure inset outline stays valid
        L2 = max(sheet_length - 2*c, eps);
        W2 = max(sheet_width  - 2*c, eps);
        R2 = max(r - c, 0);

        hull() {
            // Top: inset outline
            translate([0,0, sheet_thickness/2 - c])
                linear_extrude(height=c, center=false)
                    rounded_rect_2d(L2, W2, R2);

            // Middle: full outline (gives flat faces)
            translate([0,0, -sheet_thickness/2 + c])
                linear_extrude(height=sheet_thickness - 2*c, center=false)
                    rounded_rect_2d(sheet_length, sheet_width, r);

            // Bottom: inset outline
            translate([0,0, -sheet_thickness/2])
                linear_extrude(height=c, center=false)
                    rounded_rect_2d(L2, W2, R2);
        }
    }
}

// Protective film layer (fused to sheet with overlap)
module protective_film() {
    Lf = max(sheet_length - 2*fi, eps);
    Wf = max(sheet_width  - 2*fi, eps);
    Rf = max(r - fi, 0);

    translate([0, 0, sheet_thickness/2 + film_thickness/2 - overlap])
        linear_extrude(height=film_thickness, center=true)
            rounded_rect_2d(Lf, Wf, Rf);
}

// Final Model (ONE connected solid)
color([0.85, 0.85, 0.8])
union() {
    acrylic_sheet();
    protective_film();
}