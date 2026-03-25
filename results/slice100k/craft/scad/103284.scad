// Faceted truncated polyhedral solid (single connected piece)
// Bounding box target: 39.4 x 37.68 x 36.4 mm

// Parameters
bbox_X = 39.4;   //[19.7:78.8:0.01]
bbox_Y = 37.68;  //[18.84:75.36:0.01]
bbox_Z = 36.4;   //[18.2:72.8:0.01]

n_sides = 8;          //[6:16:1]
top_scale_xy = 1.0;   //[0.7:1.2:0.01]
bottom_scale_xy = 0.72; //[0.4:1.0:0.01]

// Height split: vertical upper band + tapered lower band (continuous, no step)
upper_wall_h = 12.0;  //[6.0:24.0:0.1]
lower_slope_h = 24.4; //[12.2:48.8:0.1]

// Small overlap to guarantee manifold union if needed
eps_overlap = 0.2; //[0.0:1.0:0.05]

$fn = 96;

// Regular n-gon profile sized to bbox_X/Y (supports non-square bbox)
module ngon_profile(scale_xy=1.0, n=n_sides) {
    rx = (bbox_X/2) * scale_xy;
    ry = (bbox_Y/2) * scale_xy;
    polygon(points=[
        for (i=[0:n-1])
            [ rx*cos(360*i/n), ry*sin(360*i/n) ]
    ]);
}

// Main solid: top vertical band + lower tapered frustum, sharing the same interface plane
module complete_model() {
    // Clamp heights to avoid invalid geometry
    uw = max(0, min(upper_wall_h, bbox_Z));
    lh = max(0, min(lower_slope_h, bbox_Z - uw));
    // If user sets heights that don't sum to bbox_Z, fill remainder into lower section
    lh2 = (uw + lh < bbox_Z) ? (bbox_Z - uw) : lh;

    union() {
        // Upper vertical walls (constant cross-section)
        translate([0,0, bbox_Z/2 - uw/2])
            linear_extrude(height=uw + eps_overlap, center=true, convexity=10)
                ngon_profile(top_scale_xy, n_sides);

        // Lower tapered section (continuous transition to smaller bottom face)
        // Starts exactly at z = bbox_Z/2 - uw and ends at z = -bbox_Z/2
        translate([0,0, -bbox_Z/2 + lh2/2])
            linear_extrude(
                height=lh2 + eps_overlap,
                center=true,
                convexity=10,
                scale=bottom_scale_xy
            )
                ngon_profile(top_scale_xy, n_sides);
    }
}

complete_model();