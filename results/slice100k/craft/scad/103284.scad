// Faceted truncated polyhedral solid (single connected piece)
// Bounding box target: 39.4 x 37.68 x 36.4 mm

bbox_X = 39.4;   //[19.7:78.8:0.01]
bbox_Y = 37.68;  //[18.84:75.36:0.01]
bbox_Z = 36.4;   //[18.2:72.8:0.01]

n_sides = 8;     //[6:16:1]

// Top (largest) polygon scale relative to bbox
top_scale_X = 1; //[0.8:1.2:0.01]
top_scale_Y = 1; //[0.8:1.2:0.01]

// Bottom (smallest) polygon scale relative to bbox
bottom_scale_X = 0.72; //[0.36:1.44:0.01]
bottom_scale_Y = 0.72; //[0.36:1.44:0.01]

// Height of near-vertical upper band (rest is tapered)
z_upper_wall = 14; //[7:28:0.1]

// Small overlap to guarantee watertight union
eps_overlap = 0.6; //[0.2:2:0.1]

function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Regular n-gon points with independent X/Y scaling (ellipse-like scaling)
function ngon_pts(n, rx, ry, rot=0) =
    [ for (i = [0:n-1])
        [ rx * cos(rot + 360*i/n), ry * sin(rot + 360*i/n) ]
    ];

module truncated_faceted_solid() {
    // Derived dimensions
    z_upper = clamp(z_upper_wall, 0, bbox_Z);
    z_lower = bbox_Z - z_upper;

    rx_top = (bbox_X * top_scale_X) / 2;
    ry_top = (bbox_Y * top_scale_Y) / 2;

    rx_bot = (bbox_X * bottom_scale_X) / 2;
    ry_bot = (bbox_Y * bottom_scale_Y) / 2;

    // Slight rotation so front/back/left/right read as regular polygon silhouette
    rot = 180 / n_sides;

    union() {
        // Upper near-vertical band: straight extrusion of the top polygon
        translate([0, 0, bbox_Z/2 - z_upper/2])
            linear_extrude(height = z_upper + eps_overlap, center = true, convexity = 10)
                polygon(points = ngon_pts(n_sides, rx_top, ry_top, rot));

        // Lower tapered band: hull between a top polygon (at transition) and smaller bottom polygon
        hull() {
            // Transition ring (same as top polygon) at z = -bbox_Z/2 + z_lower
            translate([0, 0, -bbox_Z/2 + z_lower])
                linear_extrude(height = eps_overlap, center = true, convexity = 10)
                    polygon(points = ngon_pts(n_sides, rx_top, ry_top, rot));

            // Bottom polygon at z = -bbox_Z/2
            translate([0, 0, -bbox_Z/2])
                linear_extrude(height = eps_overlap, center = true, convexity = 10)
                    polygon(points = ngon_pts(n_sides, rx_bot, ry_bot, rot));
        }
    }
}

truncated_faceted_solid();