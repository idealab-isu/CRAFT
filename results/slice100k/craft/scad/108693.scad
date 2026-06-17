// Radial starburst / asterisk-like spacer (single connected solid)
// Bounding box target: ~37.7 x 40.0 x 5.0 mm

// Parameters
bbox_X = 37.7; //[20.0:80.0:0.1]
bbox_Y = 40.0; //[20.0:80.0:0.1]
bbox_Z = 5.0;  //[2.5:10.0:0.1]

hub_D = 12.0;  //[6.0:24.0:0.1]
hub_Z = bbox_Z;

long_L = bbox_Y; //[20.0:80.0:0.1]   // dominant bar spans the Y dimension
long_W = 6.0;    //[3.0:12.0:0.1]
long_Z = bbox_Z;

spoke_count = 6; //[3:12:1]
spoke_L = 18.0;  //[9.0:36.0:0.1]
spoke_W = 5.0;   //[2.5:10.0:0.1]
spoke_Z = bbox_Z;

// Explicit angles (degrees) for "several shorter spokes arranged around it"
spoke_angle_0 = 30.0;  //[0.0:360.0:1]
spoke_angle_1 = 60.0;  //[0.0:360.0:1]
spoke_angle_2 = 90.0;  //[0.0:360.0:1]
spoke_angle_3 = 120.0; //[0.0:360.0:1]
spoke_angle_4 = 150.0; //[0.0:360.0:1]
spoke_angle_5 = 210.0; //[0.0:360.0:1]

// Per-spoke length scaling
spoke_tier_scale_0 = 1.0;  //[0.6:1.4:0.05]
spoke_tier_scale_1 = 0.95; //[0.6:1.4:0.05]
spoke_tier_scale_2 = 0.9;  //[0.6:1.4:0.05]
spoke_tier_scale_3 = 0.9;  //[0.6:1.4:0.05]
spoke_tier_scale_4 = 0.95; //[0.6:1.4:0.05]
spoke_tier_scale_5 = 1.0;  //[0.6:1.4:0.05]

overlap = 1.0;      //[0.5:2.0:0.1]  // ensures spokes intersect hub
edge_round_r = 0.6; //[0.0:1.5:0.1]

// Helpers to avoid eval()
function spoke_angle(i) =
    (i==0)?spoke_angle_0:
    (i==1)?spoke_angle_1:
    (i==2)?spoke_angle_2:
    (i==3)?spoke_angle_3:
    (i==4)?spoke_angle_4:
           spoke_angle_5;

function spoke_scale(i) =
    (i==0)?spoke_tier_scale_0:
    (i==1)?spoke_tier_scale_1:
    (i==2)?spoke_tier_scale_2:
    (i==3)?spoke_tier_scale_3:
    (i==4)?spoke_tier_scale_4:
           spoke_tier_scale_5;

// Central Hub
module central_hub() {
    cylinder(r=hub_D/2, h=hub_Z, center=true, $fn=64);
}

// Dominant Long Bar (aligned along Y)
module dominant_long_bar() {
    cube([long_W, long_L, long_Z], center=true);
}

// One rectangular spoke, placed so it overlaps into the hub (connected solid)
module spoke_rect(len, ang) {
    rotate([0,0,ang])
        translate([hub_D/2 + len/2 - overlap, 0, 0])
            cube([len, spoke_W, spoke_Z], center=true);
}

// Core (no rounding)
module core_shape() {
    union() {
        central_hub();
        dominant_long_bar();
        for (i = [0:spoke_count-1]) {
            spoke_rect(spoke_L * spoke_scale(i), spoke_angle(i));
        }
    }
}

// Scale to hit requested XY bounding box (keeps Z at bbox_Z)
module scaled_to_bbox() {
    // Approximate extents before scaling:
    // X extent dominated by max radial reach of spokes: hub_D/2 + maxLen - overlap
    maxScale = max(
        spoke_tier_scale_0, spoke_tier_scale_1, spoke_tier_scale_2,
        spoke_tier_scale_3, spoke_tier_scale_4, spoke_tier_scale_5
    );
    maxLen = spoke_L * maxScale;
    approx_X = 2 * (hub_D/2 + maxLen - overlap);
    approx_Y = long_L;

    sx = bbox_X / approx_X;
    sy = bbox_Y / approx_Y;

    scale([sx, sy, 1]) children();
}

// Final Output (single connected solid, no holes)
minkowski() {
    scaled_to_bbox() core_shape();
    sphere(r=edge_round_r, $fn=32);
}