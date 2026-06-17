$fn=128;

// HT 50 cap (approximate) for 50mm HT pipe
// Dimensions are typical/approximate; adjust as needed.
pipe_od = 50.0;          // nominal outer diameter of pipe
socket_id_clear = 50.6;  // inner diameter of cap socket (clearance)
wall = 3.2;              // socket wall thickness
socket_depth = 35.0;     // insertion depth
top_thickness = 4.0;     // thickness of closed end
outer_lip = 2.0;         // extra outer radius at rim
rim_height = 6.0;        // height of rim/lip section
chamfer = 1.2;           // small chamfer at opening

// Derived
socket_od = socket_id_clear + 2*wall;
cap_od = socket_od + 2*outer_lip;
total_h = socket_depth + top_thickness;

module ht50_cap() {
    difference() {
        union() {
            // Main outer body
            cylinder(d=socket_od, h=total_h);

            // Outer rim/lip near opening
            translate([0,0,0])
                cylinder(d=cap_od, h=rim_height);

            // Slight rounding on top edge (simple fillet approximation)
            translate([0,0,total_h-0.8])
                cylinder(d1=socket_od, d2=socket_od-1.2, h=0.8);
        }

        // Inner cavity (socket)
        translate([0,0,top_thickness])
            cylinder(d=socket_id_clear, h=socket_depth + 0.2);

        // Opening chamfer
        translate([0,0,top_thickness])
            cylinder(d1=socket_id_clear + 2*chamfer, d2=socket_id_clear, h=chamfer);

        // Slight inner relief near rim (helps fit)
        translate([0,0,top_thickness + socket_depth - 6])
            cylinder(d=socket_id_clear + 0.6, h=6.2);
    }
}

ht50_cap();