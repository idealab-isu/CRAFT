$fn=96;

insert_od = 3.0;
insert_len = 4.6;

bore_d = 2.5;          // approximate minor diameter for M3 internal thread
thread_pitch = 0.5;    // M3 coarse pitch
thread_depth = 0.18;   // approximate internal thread depth
thread_turns = insert_len / thread_pitch;

lead_in = 0.5;         // small chamfer/lead-in length
chamfer = 0.25;        // chamfer size

module internal_thread(d_minor, pitch, depth, turns) {
    // Creates a helical ridge that is subtracted from the bore to approximate internal threads
    linear_extrude(height = turns * pitch, twist = -360 * turns, slices = max(ceil(turns * 24), 24), convexity = 10)
        translate([d_minor/2, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0, pitch*0.22]
            ]);
}

module heat_set_insert() {
    difference() {
        // Outer body with slight end chamfers
        union() {
            // main cylinder
            cylinder(d=insert_od, h=insert_len);

            // top chamfer
            translate([0,0,insert_len - lead_in])
                cylinder(d1=insert_od, d2=insert_od - 2*chamfer, h=lead_in);

            // bottom chamfer
            cylinder(d1=insert_od - 2*chamfer, d2=insert_od, h=lead_in);
        }

        // Through bore
        translate([0,0,-0.2])
            cylinder(d=bore_d, h=insert_len + 0.4);

        // Thread form subtraction
        translate([0,0,0])
            internal_thread(bore_d, thread_pitch, thread_depth, thread_turns);

        // Slight countersink/lead-in at both ends
        translate([0,0,-0.01])
            cylinder(d1=bore_d + 0.6, d2=bore_d, h=0.5);
        translate([0,0,insert_len - 0.49])
            cylinder(d1=bore_d, d2=bore_d + 0.6, h=0.5);
    }
}

translate([0,0,-insert_len/2])
    heat_set_insert();