// Dimension-calibrated (target: 46.19 x 40.00 x 7.00 mm)
scale([0.865950, 1.154758, 1.000286])
{
$fn = 96;

// Parameters (mm)
bbox_L = 46.19;                 // overall across flats (X)
bbox_W = 40.0;                  // overall across corners (Y) for pointy-top orientation
T = 7.0;                        // thickness (Z)

hole_d = 10.0;
hole_offset_x = 0.0;
hole_offset_y = 0.0;

groove_depth = 0.8;             // recess depth into face
groove_angle_deg = 60.0;        // included angle of V (in face plane)
groove_land_w = 2.0;            // small flat land at the chevron meeting line
groove_span_w = 28.0;           // span along Z (height on the face)
groove_span_h = 14.0;           // span along Y (width on the face)
overlap = 1.0;                  // boolean robustness

// --- Helpers ---
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Regular hex in XY with flat-to-flat = bbox_L (pointy-top orientation gives corner-to-corner = bbox_W)
module hex_prism_body() {
    // For a regular hex: across flats = sqrt(3)*R, across corners = 2*R
    // Choose R from bbox_L, and scale Y slightly to match bbox_W exactly.
    R = bbox_L / sqrt(3);
    yscale = bbox_W / (2*R);

    linear_extrude(height=T, center=true, convexity=10)
        scale([1, yscale])
            circle(r=R, $fn=6);
}

module through_hole() {
    translate([hole_offset_x, hole_offset_y, 0])
        cylinder(d=hole_d, h=T + 2*overlap, center=true);
}

// V/chevron recess cut into the +X face, spanning Y and Z.
// Implemented as intersection of two half-spaces (forming a V) extruded along X.
module chevron_cut_on_posX() {
    // Keep groove within the face extents
    spanY = clamp(groove_span_h, groove_land_w + 0.2, bbox_W - 2);
    spanZ = clamp(groove_span_w, 1, T - 0.2);

    // Place the cutter so it starts at the +X face and goes inward by groove_depth
    // Body max X is bbox_L/2 (across flats)
    x_face = bbox_L/2;
    x_center = x_face - groove_depth/2 + overlap/2;

    // V geometry in the YZ plane:
    // Two planes: |y| <= land/2 + z*tan(theta/2), with z measured from the face midline.
    theta = groove_angle_deg;
    tanh = tan(theta/2);

    translate([x_center, 0, 0])
    rotate([0, 90, 0])  // extrude along X by linear_extrude in local Z
    linear_extrude(height=groove_depth + overlap, center=true, convexity=10)
        intersection() {
            // Limit to a rectangle window on the face
            square([spanY, spanZ], center=true);

            // Intersect the two half-planes to form the V (chevron) with a flat land
            // Use a big bounding square and clip with polygons representing the half-planes.
            // Condition: y <= land/2 + z*tanh  and  y >= -land/2 - z*tanh
            // Achieved by intersecting two large polygons.
            union() {
                // Upper bound polygon for y <= land/2 + z*tanh
                polygon(points=[
                    [-1e3, -1e3],
                    [ 1e3, -1e3],
                    [ 1e3,  (groove_land_w/2) + 1e3*tanh],
                    [-1e3,  (groove_land_w/2) - 1e3*tanh]
                ]);

                // Lower bound polygon for y >= -land/2 - z*tanh  (i.e., -y <= land/2 + z*tanh)
                // Equivalent to y >= -land/2 - z*tanh
                polygon(points=[
                    [-1e3, (-groove_land_w/2) - 1e3*tanh],
                    [ 1e3, (-groove_land_w/2) + 1e3*tanh],
                    [ 1e3,  1e3],
                    [-1e3,  1e3]
                ]);
            }
        }
}

// Same chevron on the -X face (opposing face)
module chevron_cut_on_negX() {
    mirror([1,0,0]) chevron_cut_on_posX();
}

// Final Model
module final_model() {
    difference() {
        hex_prism_body();
        through_hole();
        chevron_cut_on_posX();
        chevron_cut_on_negX();
    }
}

color("Silver") final_model();
}
