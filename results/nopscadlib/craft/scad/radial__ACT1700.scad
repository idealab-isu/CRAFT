// Parameters (A radial: [10.8, 10.8, 5.3, 1])
outer_radius = 10.8; //[5.4:21.6:0.1]
inner_radius = 10.8; //[5.4:21.6:0.1]
height       = 5.3;  //[2.65:10.6:0.1]
n            = 1;    //[1:20:1]

// Robustness / connectivity
eps = 0.02;

// Ensure a single connected solid even when outer_radius == inner_radius
ring_thickness = max(0.8, abs(outer_radius - inner_radius));
r_out = max(outer_radius, inner_radius) + ring_thickness/2;
r_in  = max(0, min(outer_radius, inner_radius) - ring_thickness/2);

// Geometry: solid ring (washer)
module radial_body() {
    difference() {
        cylinder(h=height, r=r_out, center=true, $fn=128);
        cylinder(h=height + 2*eps, r=r_in, center=true, $fn=128);
    }
}

// Final Output
radial_body();