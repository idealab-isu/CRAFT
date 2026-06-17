$fn = 96;

// Parameters
ring_diameter = 20;
ring_thickness = 2;
bolt_hole_diameter = 5;

tongue_length = 30;
tongue_width = 10;
tongue_thickness = 2;

crimp_barrel_diameter = 8;
crimp_barrel_length = 15;

bend_angle = 30;          // only used if include_bend=true and include_crimp=false
wire_hole_diameter = 3;   // only used if include_crimp=true

include_crimp = true;
include_bend  = false;

// Small overlap to guarantee watertight unions
overlap = 0.6;

// Derived
ring_r = ring_diameter/2;
bolt_r = bolt_hole_diameter/2;

// Place ring center at origin; tongue extends in +Y
// Make tongue start at ring outer edge (tangent) with a slight overlap
tongue_y0 = ring_r - overlap;                 // tongue start (near ring)
tongue_y1 = tongue_y0 + tongue_length;        // tongue end

// Crimp barrel center so it touches tongue end with overlap
barrel_cy = tongue_y1 + crimp_barrel_length/2 - overlap;

// Ring (eyelet) with central hole
module ring_eyelet() {
    difference() {
        cylinder(d=ring_diameter, h=ring_thickness, center=true);
        cylinder(d=bolt_hole_diameter, h=ring_thickness + 2, center=true);
    }
}

// Flat tongue (shank)
module tongue() {
    translate([0, (tongue_y0 + tongue_y1)/2, 0])
        cube([tongue_width, tongue_length, tongue_thickness], center=true);
}

// Smooth transition between ring and tongue (integrated, not floating)
module ring_to_tongue_transition() {
    hull() {
        // small pad at tongue start
        translate([0, tongue_y0 + tongue_thickness/2, 0])
            cube([tongue_width, tongue_thickness, tongue_thickness], center=true);

        // small pad on ring edge (toward +Y)
        translate([0, ring_r - tongue_thickness/2, 0])
            cylinder(d=tongue_width, h=ring_thickness, center=true);
    }
}

// Crimp barrel (tube) aligned with tongue, connected with overlap
module crimp_barrel() {
    // Outer barrel
    difference() {
        translate([0, barrel_cy, 0])
            rotate([90, 0, 0])  // axis along Y
                cylinder(d=crimp_barrel_diameter, h=crimp_barrel_length, center=true);

        // Inner wire passage (hollow tube)
        translate([0, barrel_cy, 0])
            rotate([90, 0, 0])
                cylinder(d=wire_hole_diameter, h=crimp_barrel_length + 2, center=true);
    }
}

// Optional bent tongue variant (kept connected by using same start point)
module bent_tongue_variant() {
    // A simple bent extension after the flat tongue end
    bend_len = tongue_length/2;
    translate([0, tongue_y1 - overlap, 0])
        rotate([bend_angle, 0, 0])
            translate([0, bend_len/2, 0])
                cube([tongue_width, bend_len, tongue_thickness], center=true);
}

// Assembly: one connected solid
module ring_terminal() {
    union() {
        ring_eyelet();
        tongue();
        ring_to_tongue_transition();

        if (include_crimp) {
            // Connect barrel to tongue with a small hull "collar"
            hull() {
                // pad at tongue end
                translate([0, tongue_y1 - overlap, 0])
                    cube([tongue_width, tongue_thickness, tongue_thickness], center=true);

                // pad at barrel near end (toward tongue)
                translate([0, barrel_cy - crimp_barrel_length/2 + overlap, 0])
                    rotate([90, 0, 0])
                        cylinder(d=crimp_barrel_diameter, h=tongue_thickness, center=true);
            }
            crimp_barrel();
        } else if (include_bend) {
            bent_tongue_variant();
        }
    }
}

ring_terminal();