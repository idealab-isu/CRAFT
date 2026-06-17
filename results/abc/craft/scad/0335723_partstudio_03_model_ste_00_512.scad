// Dimension-calibrated (target: 0.02 x 0.01 x 0.02 mm)
scale([1.500000, 1.700000, 1.818653])
{
$fn = 96;

// Parameters (meters; original values kept)
bbox_x = 0.02; //[0.01:0.04:0.001]
bbox_y = 0.01; //[0.005:0.02:0.001]
bbox_z = 0.02; //[0.01:0.04:0.001]
shaft_d = 0.006; //[0.003:0.012:0.0005]
shaft_len_total = 0.01; //[0.006:0.02:0.001]
collar_thk = 0.006; //[0.003:0.01:0.0005]
hex_flat_to_flat = 0.01; //[0.005:0.02:0.0005]
overlap = 0.0005; //[0.0002:0.001:0.0001]
chamfer_len = 0.0006; //[0.0002:0.0012:0.0001]
chamfer_d_reduction = 0.001; //[0.0004:0.002:0.0001]

// Derived
shaft_r = shaft_d/2;
hex_R = hex_flat_to_flat / sqrt(3); // circumradius for flat-to-flat size
end_len_each = max(0, (shaft_len_total - collar_thk)/2);

// Helpers
module bbox_limit() { cube([bbox_x, bbox_y, bbox_z], center=true); }

module hex_prism(h) {
    // Hex with flats aligned to X axis (wrench flats)
    rotate([0,0,30]) cylinder(h=h, r=hex_R, center=true, $fn=6);
}

module shaft_body() {
    // Axis along Y to match original orientation
    rotate([90,0,0]) cylinder(h=shaft_len_total, r=shaft_r, center=true);
}

module collar_hex() {
    rotate([90,0,0]) hex_prism(collar_thk);
}

module end_chamfer_cut(sign=1) {
    // Conical cut at each shaft end to create a small chamfer
    // sign = +1 (positive Y end), -1 (negative Y end)
    translate([0, sign*(shaft_len_total/2 - chamfer_len/2), 0])
        rotate([90,0,0])
            cylinder(
                h=chamfer_len,
                r1=shaft_r,
                r2=max(0.00001, (shaft_d - chamfer_d_reduction)/2),
                center=true
            );
}

module final_model() {
    intersection() {
        difference() {
            union() {
                // Main connected solid: cylinder shaft + central hex collar
                shaft_body();
                collar_hex();
            }
            // Chamfer both ends of the shaft (cuts remain connected)
            end_chamfer_cut(+1);
            end_chamfer_cut(-1);
        }
        // Keep within requested bounding box limits (non-zero)
        bbox_limit();
    }
}

final_model();
}
