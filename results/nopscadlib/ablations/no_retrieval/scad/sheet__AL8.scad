// Aluminium Tooling Plate (single connected solid, non-blank render)

// Parameters
plate_length = 300; //[150:600:1]
plate_width = 200;  //[100:400:1]
plate_thickness = 10; //[5:20:1]

edge_chamfer_size = 1; //[0.5:3:0.5]
corner_radius_value = 2; //[1:6:0.5]

surface_finish_depth = 0.2; //[0.1:0.5:0.05]
engraved_label_depth = 0.2; //[0.1:0.5:0.05]

connect_overlap = 1; //[0.5:2:0.5]
marking_band_width = 10; //[5:30:1]

$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Robust 2D rounded rectangle (avoids offset degeneracy)
module rounded_rect_2d(L, W, R) {
    R2 = clamp(R, 0, min(L, W)/2);
    if (R2 <= 0) {
        square([L, W], center=true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                    circle(r=R2);
        }
    }
}

// Main plate with corner radii (single solid)
module plate_solid() {
    linear_extrude(height=plate_thickness, center=true, convexity=10)
        rounded_rect_2d(plate_length, plate_width, corner_radius_value);
}

// Subtle top band (solid addition, connected by overlap)
module top_edge_band() {
    band_h = min(edge_chamfer_size, plate_thickness);
    translate([0, 0, plate_thickness/2 - band_h/2 - connect_overlap/2])
        linear_extrude(height=band_h + connect_overlap, center=true, convexity=10)
            rounded_rect_2d(plate_length, plate_width, corner_radius_value);
}

// Subtle bottom band (solid addition, connected by overlap)
module bottom_edge_band() {
    band_h = min(edge_chamfer_size, plate_thickness);
    translate([0, 0, -plate_thickness/2 + band_h/2 + connect_overlap/2])
        linear_extrude(height=band_h + connect_overlap, center=true, convexity=10)
            rounded_rect_2d(plate_length, plate_width, corner_radius_value);
}

// Very shallow surface finish pad (solid addition, connected)
module surface_finish_pad() {
    pad_L = max(plate_length - 2*marking_band_width, 0.1);
    pad_W = max(plate_width  - 2*marking_band_width, 0.1);
    pad_h = min(surface_finish_depth, plate_thickness);

    translate([0, 0, plate_thickness/2 - pad_h/2 - connect_overlap/2])
        cube([pad_L, pad_W, pad_h + connect_overlap], center=true);
}

// Very shallow label pad (solid addition, connected)
module label_pad() {
    lab_L = plate_length/4;
    lab_W = plate_width/6;
    lab_h = min(engraved_label_depth, plate_thickness);

    x0 = -plate_length/2 + marking_band_width + lab_L/2;
    y0 = -plate_width/2  + marking_band_width + lab_W/2;

    translate([x0, y0, plate_thickness/2 - lab_h/2 - connect_overlap/2])
        cube([lab_L, lab_W, lab_h + connect_overlap], center=true);
}

// Final Output: ONE connected solid
union() {
    plate_solid();
    top_edge_band();
    bottom_edge_band();
    surface_finish_pad();
    label_pad();
}