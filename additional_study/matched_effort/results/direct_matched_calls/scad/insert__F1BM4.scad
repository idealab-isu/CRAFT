$fn = 128;

// Threaded heat-set insert (simplified, renderable model)
// Specs: 8.2mm outer diameter, 6.3mm long, for 4.0mm screws

od = 8.2;
len = 6.3;

// Typical M4 internal thread minor diameter ~3.3mm; use a slightly generous clearance
id = 3.4;

// Small lead-in chamfers
ch = 0.4;

// Knurl approximation (optional visual detail)
knurl = true;
knurl_depth = 0.35;
knurl_count = 28;

module insert_body() {
    // Main cylinder with chamfers
    union() {
        // center section
        translate([0,0,ch])
            cylinder(d=od, h=len-2*ch);

        // bottom chamfer
        cylinder(d1=od-2*ch, d2=od, h=ch);

        // top chamfer
        translate([0,0,len-ch])
            cylinder(d1=od, d2=od-2*ch, h=ch);
    }
}

module knurl_cuts() {
    // Create shallow vertical flutes around the outside
    for (i = [0:knurl_count-1]) {
        rotate([0,0, i*360/knurl_count])
            translate([od/2 - knurl_depth/2, 0, 0])
                cylinder(d=knurl_depth, h=len, center=false);
    }
}

difference() {
    if (knurl) {
        difference() {
            insert_body();
            knurl_cuts();
        }
    } else {
        insert_body();
    }

    // Through-hole for screw/thread
    translate([0,0,-0.2])
        cylinder(d=id, h=len+0.4);
}