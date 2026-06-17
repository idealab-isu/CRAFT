// Parameters
mast_height = 150;
mast_diameter = 10;
base_diameter = 30;
base_height = 5;
mounting_hole_diameter = 3;
mounting_hole_spacing = 20;
connector_stub_height = 10;
connector_stub_diameter = 8;
tapered_tip_height = 15;
tapered_tip_diameter = 5;
knurling_depth = 0.5;
knurling_pitch = 2;
branding_text = "Antenna";
branding_text_size = 5;

// Main Antenna Model
module antenna() {
    // Base Mount
    base_mount();
    
    // Mast
    translate([0, 0, base_height])
        mast();
    
    // Connector Stub
    translate([0, 0, base_height + mast_height])
        connector_stub();
    
    // Tapered Tip
    translate([0, 0, base_height + mast_height + connector_stub_height])
        tapered_tip();
    
    // Branding Text
    translate([0, -mast_diameter/2 - 2, base_height + mast_height/2])
        rotate([90, 0, 0])
        linear_extrude(height=1)
            text(branding_text, size=branding_text_size, halign="center", valign="center");
}

// Base Mount with Mounting Holes
module base_mount() {
    difference() {
        cylinder(h=base_height, d=base_diameter);
        for (i = [0, 180]) {
            translate([mounting_hole_spacing/2 * cos(i), mounting_hole_spacing/2 * sin(i), 0])
                cylinder(h=base_height + 1, d=mounting_hole_diameter);
        }
    }
}

// Mast with Knurling
module mast() {
    difference() {
        cylinder(h=mast_height, d=mast_diameter);
        knurling();
    }
}

// Knurling Effect
module knurling() {
    for (i = [0 : 360/knurling_pitch : 360]) {
        rotate([0, 0, i])
            translate([mast_diameter/2, 0, 0])
                rotate([90, 0, 0])
                    cylinder(h=mast_height, d=knurling_depth, center=true);
    }
}

// Connector Stub
module connector_stub() {
    cylinder(h=connector_stub_height, d=connector_stub_diameter);
}

// Tapered Tip
module tapered_tip() {
    cone(h=tapered_tip_height, d1=tapered_tip_diameter, d2=0);
}

// Cone helper function
module cone(h, d1, d2) {
    cylinder(h=h, d1=d1, d2=d2);
}

// Render the antenna
antenna();