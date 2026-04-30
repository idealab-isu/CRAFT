$fn = 96;

module hex_nut(thread_bore_d=2, thickness=1.6, across_flats=4.0, chamfer=0.25) {
    difference() {
        union() {
            // Main hex prism
            linear_extrude(height=thickness, center=true)
                circle(d=across_flats, $fn=6);

            // Small chamfers on both faces (approx)
            translate([0,0, thickness/2 - chamfer/2])
                cylinder(h=chamfer, r1=across_flats*0.62, r2=across_flats*0.50, center=true, $fn=6);
            translate([0,0,-thickness/2 + chamfer/2])
                cylinder(h=chamfer, r1=across_flats*0.50, r2=across_flats*0.62, center=true, $fn=6);
        }

        // Thread bore (modeled as plain cylindrical hole)
        cylinder(h=thickness + 2, d=thread_bore_d, center=true);
    }
}

hex_nut(thread_bore_d=2, thickness=1.6);