// Aluminium tooling plate (single connected solid)

// Parameters
plate_length = 300; //[150:600:1]
plate_width  = 200; //[100:400:1]
plate_thickness = 10; //[5:20:1]
edge_chamfer_size = 1; //[0.5:4:0.5]
corner_radius_value = 5; //[2:15:1]

// Quality
$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Main plate with rounded corners and optional edge chamfer
module tooling_plate_complete() {
    // Ensure parameters are valid and cannot erase the whole part
    chamfer = clamp(edge_chamfer_size, 0, min(plate_thickness/2 - 0.01, min(plate_length, plate_width)/4));
    r = clamp(corner_radius_value, 0, min(plate_length, plate_width)/2 - 0.01);

    // 2D rounded rectangle
    module rounded_rect_2d(L, W, R) {
        if (R <= 0)
            square([L, W], center=true);
        else
            offset(r=R) square([L - 2*R, W - 2*R], center=true);
    }

    // Base solid (extruded rounded rectangle)
    module base_solid() {
        linear_extrude(height=plate_thickness, center=true, convexity=10)
            rounded_rect_2d(plate_length, plate_width, r);
    }

    // Chamfer by subtracting a slightly larger, slightly taller copy (minkowski with a cone)
    // This creates a bevel around all outer edges while keeping one connected solid.
    if (chamfer <= 0) {
        color("Silver") base_solid();
    } else {
        color("Silver")
        difference() {
            base_solid();

            // Subtract chamfer volume: expanded outline + cone creates sloped cut
            // Translate is formula-based: align to top face with a tiny overlap.
            translate([0, 0, plate_thickness/2 - 0.001])
                minkowski() {
                    // Expanded 2D outline extruded a tiny amount
                    linear_extrude(height=0.002, center=false, convexity=10)
                        rounded_rect_2d(plate_length, plate_width, r);

                    // Cone defines chamfer slope (height = chamfer, radius = chamfer)
                    cylinder(h=chamfer + 0.002, r1=chamfer, r2=0);
                }
        }
    }
}

// Render
tooling_plate_complete();