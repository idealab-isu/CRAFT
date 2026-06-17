// Dimension-calibrated (target: 0.09 x 0.09 x 0.03 mm)
scale([1.033333, 1.033333, 8.333333])
{
// Flat rosette/gear-like disk with evenly spaced triangular teeth
// Target: uniform thin plate, circular core, no cutouts, one connected solid

$fn = 180;

// Parameters (mm)
bbox_x = 0.09;                 //[0.045:0.18:0.001]
bbox_y = 0.09;                 //[0.045:0.18:0.001]
thickness_z = 0.003;           //[0.001:0.01:0.0005]  // thin, constant thickness

tooth_count = 24;              //[6:96:1]
tooth_depth = 0.009;           //[0.0045:0.018:0.0005]
tooth_half_width = 0.004;      //[0.001:0.01:0.0005]
overlap = 0.001;               //[0.0005:0.002:0.0001]

// Derived radii to respect bounding box (outer diameter = min(bbox_x,bbox_y))
outer_radius = min(bbox_x, bbox_y) / 2;
core_radius  = outer_radius - tooth_depth;

// 2D tooth (triangle) placed so it overlaps into the core for guaranteed connectivity
module tooth_2d() {
    polygon(points=[
        [core_radius - overlap, -tooth_half_width],
        [core_radius - overlap,  tooth_half_width],
        [outer_radius,           0]
    ]);
}

// 2D outline: circular disk + radial teeth
module rosette_2d() {
    union() {
        circle(r=core_radius);
        for (i = [0:tooth_count-1])
            rotate(i * 360 / tooth_count)
                tooth_2d();
    }
}

// Final solid: uniform extrusion (flat plate)
linear_extrude(height=thickness_z, center=true, convexity=10)
    rosette_2d();
}
