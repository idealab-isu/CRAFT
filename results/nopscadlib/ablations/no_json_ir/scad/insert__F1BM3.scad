// Threaded heat-set insert (simplified solid model)
// Target: 5.8mm OD, 4.6mm long, for 3.0mm screws (modeled as straight bore)

outer_diameter   = 5.8;   // mm
length           = 4.6;   // mm
thread_diameter  = 3.0;   // mm (modeled as straight bore)
knurl_depth      = 0.3;   // mm (radial protrusion)
knurl_width      = 0.6;   // mm (tangential width)
knurl_count      = 24;    // ribs around circumference
chamfer_height   = 0.5;   // mm
overlap          = 0.05;  // mm (ensures watertight unions/differences)
$fn = 120;

module outer_shell_with_ribs() {
    union() {
        // Main cylindrical body
        cylinder(d=outer_diameter, h=length, center=false);

        // Retention ribs: protrude outward and overlap into body for connectivity
        // Place ribs centered in Z, and radially so inner face overlaps into the cylinder.
        for (i = [0 : knurl_count-1]) {
            rotate([0, 0, i * 360/knurl_count])
                translate([outer_diameter/2 + knurl_depth/2 - overlap, 0, length/2])
                    cube([knurl_depth + 2*overlap, knurl_width, length + 2*overlap], center=true);
        }
    }
}

module lead_in_chamfer_outer() {
    // Outer chamfer on top end; overlaps slightly into body
    translate([0, 0, length - chamfer_height - overlap])
        cylinder(d1=outer_diameter, d2=outer_diameter - 2*chamfer_height, h=chamfer_height + overlap, center=false);
}

module threaded_insert() {
    difference() {
        union() {
            outer_shell_with_ribs();
            lead_in_chamfer_outer();
        }

        // Internal bore (modeled as straight hole), extended beyond ends to guarantee cut
        translate([0, 0, -overlap])
            cylinder(d=thread_diameter, h=length + 2*overlap, center=false);
    }
}

threaded_insert();