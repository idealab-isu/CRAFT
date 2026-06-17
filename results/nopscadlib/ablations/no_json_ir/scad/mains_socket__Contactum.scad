// Dimensions
faceplate_width = 86;
faceplate_height = 86;
faceplate_thickness = 5;
socket_body_depth = 30;

pin_aperture_width = 5;
pin_aperture_height = 20;
pin_aperture_spacing = 19;
earth_aperture_diameter = 7;

mounting_hole_diameter = 4;
mounting_hole_spacing = 60;
counterbore_diameter = 8;
counterbore_depth = 2;

// Connectivity overlap (1–2mm) to guarantee attachment
overlap = 1.5;

// Main function
module mains_socket() {
    union() {
        // Main blue body with all orange features CUT INTO it (not floating)
        difference() {
            union() {
                socket_body();
                faceplate_profile();
            }
            // Cutouts go slightly beyond the full depth to ensure clean boolean
            pin_apertures();
            internal_hollow();
            mounting_screw_holes();
        }
    }
}

// Socket body
module socket_body() {
    translate([0, 0, -socket_body_depth])
        cube([faceplate_width, faceplate_height, socket_body_depth], center=false);
}

// Faceplate profile
module faceplate_profile() {
    translate([0, 0, 0])
        cube([faceplate_width, faceplate_height, faceplate_thickness], center=false);
}

// Pin apertures (cut into faceplate/body; extend past both sides for robust difference)
module pin_apertures() {
    z0 = -socket_body_depth - overlap;
    h  = socket_body_depth + faceplate_thickness + 2*overlap;

    // Live/Neutral slots
    translate([
        faceplate_width/2 - pin_aperture_spacing/2 - pin_aperture_width/2,
        faceplate_height/2 - pin_aperture_height/2,
        z0
    ])
        cube([pin_aperture_width, pin_aperture_height, h], center=false);

    translate([
        faceplate_width/2 + pin_aperture_spacing/2 - pin_aperture_width/2,
        faceplate_height/2 - pin_aperture_height/2,
        z0
    ])
        cube([pin_aperture_width, pin_aperture_height, h], center=false);

    // Earth pin hole
    translate([
        faceplate_width/2,
        faceplate_height/2 + pin_aperture_height/2 + 5,
        z0
    ])
        cylinder(h=h, d=earth_aperture_diameter, center=false, $fn=48);
}

// Internal hollow (kept inside body; overlaps slightly to avoid thin uncut skins)
module internal_hollow() {
    wall = 5;
    z0 = -socket_body_depth + wall - overlap;
    h  = socket_body_depth - wall + overlap;

    translate([wall, wall, z0])
        cube([faceplate_width - 2*wall, faceplate_height - 2*wall, h], center=false);
}

// Mounting screw holes + counterbores (cut through; extend beyond for robust difference)
module mounting_screw_holes() {
    z0 = -socket_body_depth - overlap;
    h  = socket_body_depth + faceplate_thickness + 2*overlap;

    for (x = [-mounting_hole_spacing/2, mounting_hole_spacing/2]) {
        // Through hole
        translate([faceplate_width/2 + x, faceplate_height/2, z0])
            cylinder(h=h, d=mounting_hole_diameter, center=false, $fn=48);

        // Counterbore from front face (z=0) into faceplate
        translate([faceplate_width/2 + x, faceplate_height/2, -overlap])
            cylinder(h=counterbore_depth + overlap, d=counterbore_diameter, center=false, $fn=48);
    }
}

// Render the mains socket
mains_socket();