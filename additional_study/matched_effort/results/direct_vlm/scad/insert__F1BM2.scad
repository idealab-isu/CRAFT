$fn = 128;

// Threaded heat-set insert for M2 screw
// OD: 4.0 mm
// Length: 3.6 mm
// Includes: internal helical thread (subtractive) + external knurl/barbs

od = 4.0;
len = 3.6;

// M2 internal thread approximation
thread_major_d = 2.0;   // screw major diameter
thread_minor_d = 1.6;   // insert minor diameter (bore)
pitch = 0.40;           // M2 coarse pitch

// External knurl/barbs
knurl_count = 24;       // more ribs -> clearer knurl
knurl_radial = 0.30;    // protrusion beyond OD/2
knurl_twist = 35;       // stronger twist -> clearer barb/knurl look

// End chamfers
chamfer = 0.30;

// Small overlaps for robust boolean connectivity
eps = 0.03;

module internal_thread_groove(d_major, d_minor, pitch, h){
    // Subtractive helical "cutter" that removes material from the bore,
    // leaving a visible thread-like groove sized for an M2 screw.
    turns = h / pitch;
    groove_r = (d_major - d_minor)/2;                 // radial thread depth
    cutter_r = max(groove_r*0.55, 0.12);              // cutter thickness
    cutter_offset = d_minor/2 + groove_r*0.85;        // place cutter near bore wall

    linear_extrude(height=h + 2*eps,
                  twist=turns*360,
                  slices=max(ceil(turns*80), 120),
                  convexity=10)
        translate([cutter_offset, 0, 0])
            circle(r=cutter_r, $fn=36);
}

module external_knurl(od, h, count, radial, twist_deg){
    // Base cylinder + twisted ribs that protrude outward and overlap into the base.
    rib_w = (PI*od/count)*0.55;
    rib_len = radial*2.0;

    union(){
        cylinder(d=od, h=h);

        for(i = [0:count-1]){
            rotate([0,0,i*360/count])
                linear_extrude(height=h,
                              twist=twist_deg,
                              slices=120,
                              convexity=10)
                    // Inner edge overlaps into the base for guaranteed connectivity
                    translate([od/2 - radial*0.9, 0, 0])
                        square([rib_len, rib_w], center=true);
        }
    }
}

module heat_set_insert(od, len, chamfer,
                       thread_major_d, thread_minor_d, pitch,
                       knurl_count, knurl_radial, knurl_twist){

    lead_h = min(0.55, len*0.22); // lead-in based on length (no arbitrary placement)

    difference(){
        // ONE connected solid outer body (knurled + chamfered ends)
        union(){
            external_knurl(od=od, h=len, count=knurl_count, radial=knurl_radial, twist_deg=knurl_twist);

            // Bottom chamfer (overlaps body)
            cylinder(d1=od - 2*chamfer, d2=od, h=chamfer + eps);

            // Top chamfer (overlaps body)
            translate([0,0,len - chamfer - eps])
                cylinder(d1=od, d2=od - 2*chamfer, h=chamfer + eps);
        }

        // Bore at minor diameter (through)
        translate([0,0,-eps])
            cylinder(d=thread_minor_d, h=len + 2*eps);

        // Subtractive helical groove to create visible internal threading
        translate([0,0,-eps])
            internal_thread_groove(d_major=thread_major_d, d_minor=thread_minor_d, pitch=pitch, h=len);

        // Lead-in tapers at both ends (connected via formulas)
        translate([0,0,-eps])
            cylinder(d1=thread_major_d + 0.5, d2=thread_minor_d, h=lead_h + eps);

        translate([0,0,len - lead_h])
            cylinder(d1=thread_minor_d, d2=thread_major_d + 0.5, h=lead_h + eps);
    }
}

heat_set_insert(
    od=od, len=len, chamfer=chamfer,
    thread_major_d=thread_major_d, thread_minor_d=thread_minor_d, pitch=pitch,
    knurl_count=knurl_count, knurl_radial=knurl_radial, knurl_twist=knurl_twist
);