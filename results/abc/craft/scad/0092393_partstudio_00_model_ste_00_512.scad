// Dimension-calibrated (target: 0.09 x 0.09 x 0.01 mm)
scale([0.923880, 0.913614, 0.800000])
{
// Thin faceted washer ring with circular inner opening,
// 8 evenly spaced square through-holes (one per facet),
// and segmented beveled/chamfered faces.
//
// Units: mm

$fn = 128;

// ---- Parameters (kept near original scale) ----
outer_flat_to_flat = 0.09;     // across flats of outer octagon
inner_d            = 0.045;    // circular inner opening diameter
thk                = 0.01;     // plate thickness

hole_count         = 8;
hole_size          = 0.008;    // square through-hole size
hole_radial_pos    = 0.036;    // radius to hole centers (near perimeter)

bevel_h            = 0.002;    // height of top/bottom bevel band
bevel_inset        = 0.003;    // inset of bevel band from outer edge

seg_depth          = 0.0012;   // shallow segmentation grooves depth (per face)
seg_width          = 0.006;    // groove width along tangent

overlap            = 0.001;    // boolean overlap

// ---- Helpers ----
function oct_r_from_flat(flat) = flat/(2*cos(180/8)); // circumradius for regular octagon

module octagon2d(flat) {
    r = oct_r_from_flat(flat);
    polygon(points=[ for(i=[0:7]) [ r*cos(45*i), r*sin(45*i) ] ]);
}

module ring_base() {
    // Outer octagon minus circular inner opening
    difference() {
        linear_extrude(height=thk, center=true) octagon2d(outer_flat_to_flat);
        cylinder(d=inner_d, h=thk + 2*overlap, center=true);
    }
}

module square_holes() {
    // 8 square through-holes, centered on each facet normal direction
    union() {
        for (i=[0:hole_count-1]) {
            rotate([0,0,i*360/hole_count])
                translate([hole_radial_pos, 0, 0])
                    cube([hole_size, hole_size, thk + 2*overlap], center=true);
        }
    }
}

module bevel_band_solid() {
    // Solid "band" near the outer edge used to carve a chamfer-like step
    // (difference of two octagons), then placed at top and bottom.
    difference() {
        linear_extrude(height=bevel_h, center=true) octagon2d(outer_flat_to_flat);
        linear_extrude(height=bevel_h + 2*overlap, center=true) octagon2d(outer_flat_to_flat - 2*bevel_inset);
    }
}

module top_bottom_bevel_cuts() {
    union() {
        translate([0,0, thk/2 - bevel_h/2]) bevel_band_solid();
        translate([0,0,-thk/2 + bevel_h/2]) bevel_band_solid();
    }
}

module facet_segmentation_grooves() {
    // Shallow grooves centered on each facet to give segmented/beveled appearance.
    // These are cuts (subtracted) and do not break connectivity.
    union() {
        // Place grooves at radius near outer edge but inside it
        r_outer = oct_r_from_flat(outer_flat_to_flat);
        r_g = r_outer - bevel_inset*0.6;

        for (i=[0:hole_count-1]) {
            rotate([0,0,i*360/hole_count]) {
                // Groove aligned with facet (tangent direction = Y in local frame)
                translate([r_g, 0, 0])
                    cube([seg_depth + 2*overlap, seg_width, thk + 2*overlap], center=true);
            }
        }
    }
}

// ---- Final model ----
difference() {
    // One connected solid
    difference() {
        ring_base();
        square_holes();
    }

    // Carve top/bottom bevel steps and segmentation grooves
    top_bottom_bevel_cuts();
    facet_segmentation_grooves();
}
}
