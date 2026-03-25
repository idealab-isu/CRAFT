// Thin tapered rounded-rectangle plate with shallow side scallops and subtle diagonal relief
// Target bounding box: X=5.45, Y=6.74, Z=0.61 (mm)  (elongated along Y)
// Render-safe: no minkowski(), moderate $fn, connected solid.

$fn = 48;

// Parameters (mm)
L = 6.74;   // length (elongated axis, Y)
W = 5.45;   // width (X)
T = 0.61;   // thickness (Z)

corner_R = 0.85;          // planar corner rounding
taper_delta_W = 0.35;     // width reduction at +Y end (slight taper)

scallop_depth = 0.28;     // shallow bite into side
scallop_R = 0.70;         // scallop radius
scallop_offset_from_center = 1.55; // along length (Y) from center

relief_height = 0.05;     // raised ribs height
relief_band_width = 0.55; // rib band width
relief_angle_deg = 35;    // diagonal angle

edge_chamfer = 0.10;      // simple 3D edge softening (chamfer-like)
eps = 0.02;

// ---------- 2D outline (in XY, length along Y) ----------
module tapered_outline_2d(){
    // width at -Y and +Y
    w0 = W;
    w1 = max(0.5, W - taper_delta_W);

    r = min(corner_R, min(w0, w1)/2 - 0.01);
    baseL = max(0.2, L - 2*r);
    baseW0 = max(0.2, w0 - 2*r);
    baseW1 = max(0.2, w1 - 2*r);

    // Rounded trapezoid via offset on a simple polygon
    offset(r=r)
        polygon(points=[
            [-baseW0/2, -baseL/2],
            [ baseW0/2, -baseL/2],
            [ baseW1/2,  baseL/2],
            [-baseW1/2,  baseL/2]
        ]);
}

// ---------- 3D helpers ----------
module scallop_cutter(){
    cylinder(r=scallop_R, h=T + 6*eps, center=true);
}

module rib(){
    cube([max(W,L)*2.0, relief_band_width, relief_height], center=true);
}

// Simple chamfered plate by hulling two extrusions (fast, no minkowski)
module plate_chamfered(){
    c = min(edge_chamfer, T/2 - 0.001);
    if (c <= 0){
        linear_extrude(height=T, center=true, convexity=6) tapered_outline_2d();
    } else {
        hull(){
            // middle (full size)
            linear_extrude(height=max(0.001, T - 2*c), center=true, convexity=6)
                tapered_outline_2d();

            // top & bottom slightly inset to create a chamfer-like edge
            translate([0,0, (T/2 - c/2)])
                linear_extrude(height=c, center=true, convexity=6)
                    offset(delta=-c) tapered_outline_2d();

            translate([0,0, -(T/2 - c/2)])
                linear_extrude(height=c, center=true, convexity=6)
                    offset(delta=-c) tapered_outline_2d();
        }
    }
}

// ---------- Model ----------
module model(){
    difference(){
        union(){
            plate_chamfered();

            // Subtle diagonal ribs on both faces (raised, shallow)
            // Keep ribs within the plate footprint by intersecting with a thin slab.
            intersection(){
                union(){
                    for (k = [-2,-1,0,1,2]){
                        translate([0, k*relief_band_width*1.35,  T/2 - relief_height/2 + eps])
                            rotate([0,0, relief_angle_deg]) rib();
                    }
                }
                // limit to near-top face region
                translate([0,0, T/2 - relief_height/2])
                    linear_extrude(height=relief_height + 2*eps, center=true, convexity=4)
                        offset(delta=-0.15) tapered_outline_2d();
            }

            intersection(){
                union(){
                    for (k = [-2,-1,0,1,2]){
                        translate([0, k*relief_band_width*1.35, -T/2 + relief_height/2 - eps])
                            rotate([0,0,-relief_angle_deg]) rib();
                    }
                }
                // limit to near-bottom face region
                translate([0,0, -T/2 + relief_height/2])
                    linear_extrude(height=relief_height + 2*eps, center=true, convexity=4)
                        offset(delta=-0.15) tapered_outline_2d();
            }
        }

        // Shallow scallops on left/right edges (X sides), two per side along Y
        x_out = W/2 + scallop_R - scallop_depth;

        for (sy = [-1, 1]){
            translate([ x_out, sy*scallop_offset_from_center, 0]) scallop_cutter();
            translate([-x_out, sy*scallop_offset_from_center, 0]) scallop_cutter();
        }
    }
}

model();