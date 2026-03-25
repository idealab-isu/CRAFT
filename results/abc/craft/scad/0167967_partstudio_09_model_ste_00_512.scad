// Dimension-calibrated (target: 0.09 x 0.09 x 0.03 mm)
scale([0.931080, 0.931080, 0.833333])
{
// Flat toothed rosette / gear-like disk (solid, no cutouts)
// Target bbox ~0.1 x 0.1 x thin Z

$fn = 180;

// Parameters (mm)
bbox_xy      = 0.10;
thickness_z  = 0.03;

tooth_count  = 36;          // many evenly spaced teeth
outer_radius = bbox_xy/2;   // tooth tip radius
root_radius  = outer_radius * 0.82;  // base disk radius (between teeth)

// Tooth shape control (2D)
tooth_angle_frac = 0.55;    // fraction of pitch occupied by tooth (0..1)
tooth_overlap    = outer_radius * 0.01; // small overlap into root for watertight union

module rosette_2d() {
    pitch = 360 / tooth_count;
    half_tooth = (pitch * tooth_angle_frac) / 2;

    union() {
        // Base circular disk (ensures round body, not polygonal)
        circle(r = root_radius);

        // Triangular teeth (2D), then extruded uniformly
        for (i = [0:tooth_count-1]) {
            rotate(i * pitch)
                polygon(points = [
                    // two base points slightly inside root radius for solid connectivity
                    [root_radius - tooth_overlap, 0],
                    [outer_radius * cos( half_tooth), outer_radius * sin( half_tooth)],
                    [outer_radius * cos(-half_tooth), outer_radius * sin(-half_tooth)]
                ]);
        }
    }
}

linear_extrude(height = thickness_z, center = true, convexity = 10)
    rosette_2d();
}
