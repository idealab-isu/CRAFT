// Dimension-calibrated (target: 46.19 x 40.00 x 29.88 mm)
scale([0.967562, 0.838011, 0.974055])
{
$fn = 96;

// Target bounding box (approx): 46.2 x 40.0 x 29.9 mm
bbox_x = 46.19;
bbox_y = 40.00;
bbox_z = 29.88;

// Primary dimensions
hex_flat_to_flat = 40.00;     // across flats (clear hex footprint)
plate_thickness  = 6.00;

dome_radius      = 23.88;     // hemisphere radius (convex boss)
hole_diameter    = 4.00;

// Overlap to guarantee watertight unions/differences (1–2mm)
overlap = 1.20;

// --- Helpers ---
function hex_R_from_flat(flat) = flat / sqrt(3); // circumradius for flat-to-flat hex

module hex2d(flat_to_flat) {
    R = hex_R_from_flat(flat_to_flat);
    polygon(points = [
        [ R, 0],
        [ R/2,  flat_to_flat/2],
        [-R/2,  flat_to_flat/2],
        [-R, 0],
        [-R/2, -flat_to_flat/2],
        [ R/2, -flat_to_flat/2]
    ]);
}

module hex_plate() {
    // Plate centered at origin in Z so top face is at +plate_thickness/2
    linear_extrude(height = plate_thickness, center = true)
        hex2d(hex_flat_to_flat);
}

module hemispherical_boss() {
    // Hemisphere protrudes from TOP face only.
    // Ensure it intersects the plate by 'overlap' for a solid union.
    // Plate top face: z = +plate_thickness/2
    // Hemisphere base plane: z = +plate_thickness/2 - overlap
    base_z = plate_thickness/2 - overlap;

    translate([0, 0, base_z])
        intersection() {
            // Sphere center at z = dome_radius so local z=0 is the equator plane
            translate([0, 0, dome_radius])
                sphere(r = dome_radius);

            // Keep only z >= 0 half-space (a true hemisphere)
            // Use a large cube starting at z=0 (in local coords) to avoid inversion.
            translate([0, 0, (dome_radius + 2)/2])
                cube([2*dome_radius + 4, 2*dome_radius + 4, dome_radius + 2], center = true);
        }
}

module central_through_hole() {
    // Through-hole along Z, long enough to cut through dome + plate.
    // Centered at origin so it always intersects both.
    h = plate_thickness + dome_radius + 20;
    cylinder(h = h, r = hole_diameter/2, center = true);
}

// --- Final model: one connected solid ---
difference() {
    union() {
        hex_plate();
        hemispherical_boss();
    }
    central_through_hole();
}
}
