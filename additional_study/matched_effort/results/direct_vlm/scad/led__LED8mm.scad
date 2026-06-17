$fn=96;

// 8.0mm through-hole LED, 9.2mm body height (approximate)
// Dimensions in mm

module led_8mm_tht(body_d=8.0, body_h=9.2,
                   flange_d=9.0, flange_h=1.0,
                   dome_h=3.0,
                   lead_d=0.6, lead_pitch=2.54,
                   lead_len=25.0, lead_exposed_below=18.0)
{
    // Body sits on top of flange; leads extend downward from flange bottom (z=0)
    // Coordinate system: flange bottom at z=0, body above, leads below.
    union() {
        // Leads
        for (x = [-lead_pitch/2, lead_pitch/2]) {
            translate([x, 0, -lead_exposed_below])
                cylinder(h=lead_exposed_below, d=lead_d);
        }

        // Flange (rim)
        translate([0,0,0])
            cylinder(h=flange_h, d=flange_d);

        // Main cylindrical body (excluding dome)
        body_cyl_h = max(0, body_h - dome_h);
        translate([0,0,flange_h])
            cylinder(h=body_cyl_h, d=body_d);

        // Dome (spherical cap approximation)
        // Use a sphere intersected with a half-space to create a dome of height dome_h.
        // Sphere radius chosen so that cap height equals dome_h with base radius = body_d/2.
        r_base = body_d/2;
        h_cap = dome_h;
        // r_sphere = (r_base^2 + h_cap^2) / (2*h_cap)
        r_sphere = (r_base*r_base + h_cap*h_cap) / (2*h_cap);

        // Place sphere so that cap base plane is at z = flange_h + body_cyl_h
        // Sphere center is below cap top by r_sphere, and above base plane by (r_sphere - h_cap)
        z_base = flange_h + body_cyl_h;
        z_center = z_base + (r_sphere - h_cap);

        intersection() {
            translate([0,0,z_center])
                sphere(r=r_sphere);
            // Keep only the portion above the base plane
            translate([0,0,z_base])
                cube([2*flange_d, 2*flange_d, 2*(body_h+lead_len)], center=false);
        }

        // Optional slight flat on one side (cathode mark) - subtle
        // Create a small planar cut on the body cylinder region
        difference() {
            // no-op placeholder to keep union valid if removed
            translate([0,0,0]) cube([0,0,0]);
        }
    }
}

led_8mm_tht();