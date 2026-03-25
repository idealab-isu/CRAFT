// Aluminium tooling plate (single connected solid)

// Parameters
plate_length = 300; //[150:600:1]
plate_width  = 200; //[100:400:1]
plate_thickness = 10; //[5:20:1]
corner_radius = 10; //[5:20:1]
edge_chamfer  = 1;  //[0.5:3:0.5]
overlap = 1;        //[0.5:2:0.5]

$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep features valid for any parameter combination
r = clamp(corner_radius, 0, min(plate_length, plate_width)/2 - 0.01);
c = clamp(edge_chamfer, 0, plate_thickness/2 - 0.01);

// Rounded-rectangle prism via hull of corner cylinders
module rounded_plate(L, W, T, R) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(r=R, h=T, center=true);
    }
}

// Chamfered edges by subtracting 4 long wedges (top and bottom)
module chamfer_cuts(L, W, T, C, ov) {
    // Wedge size: long enough to cover the plate, thick enough to cut
    cutL = L + 2*ov + 2*C;
    cutW = W + 2*ov + 2*C;
    cutH = C + 2*ov;

    // Top chamfers
    zTop =  T/2 - C/2;
    // Bottom chamfers
    zBot = -T/2 + C/2;

    // Along +Y / -Y edges
    for (zpos = [zTop, zBot]) {
        translate([0,  (W/2 + C/2 - ov), zpos])
            rotate([45, 0, 0])
                cube([cutL, cutH, cutH], center=true);

        translate([0, -(W/2 + C/2 - ov), zpos])
            rotate([-45, 0, 0])
                cube([cutL, cutH, cutH], center=true);
    }

    // Along +X / -X edges
    for (zpos = [zTop, zBot]) {
        translate([ (L/2 + C/2 - ov), 0, zpos])
            rotate([0, -45, 0])
                cube([cutH, cutW, cutH], center=true);

        translate([-(L/2 + C/2 - ov), 0, zpos])
            rotate([0, 45, 0])
                cube([cutH, cutW, cutH], center=true);
    }
}

module tooling_plate_complete() {
    difference() {
        rounded_plate(plate_length, plate_width, plate_thickness, r);
        if (c > 0)
            chamfer_cuts(plate_length, plate_width, plate_thickness, c, overlap);
    }
}

// Final Output
color("Silver") tooling_plate_complete();