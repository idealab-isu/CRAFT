// Heatshrink sleeving - hollow tube (single connected solid), oriented for clearer views

$fn = 128;

// Parameters
sleeve_L = 50;        //[25:100:1]
sleeve_ID = 6;        //[3:12:0.5]
sleeve_wall = 0.5;    //[0.25:1.5:0.05]
clearance = 0.02;     // small radial clearance to avoid coincident surfaces
void_extra = 0.5;     // extend inner void slightly past ends for a clean through-hole

// Derived
sleeve_OD = sleeve_ID + 2*sleeve_wall;

// Base tube (hollow)
module heatshrink_sleeve() {
  difference() {
    // Outer tube
    cylinder(h = sleeve_L, r = sleeve_OD/2, center = true);

    // Inner void: slightly longer and slightly larger radius to ensure robust boolean
    cylinder(h = sleeve_L + 2*void_extra, r = sleeve_ID/2 + clearance, center = true);
  }
}

// Orient along X so front/back/left/right show length (not just cross-section)
rotate([0, 90, 0]) heatshrink_sleeve();