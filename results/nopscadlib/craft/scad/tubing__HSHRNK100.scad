// Heatshrink sleeving / tubing (single connected solid)

// Parameters
length = 15; //[8:60:1]
center = true; //[0:1:1]
forced_id = 0; //[0:20:1]
type_index = 1; //[1:3:1]
lib_id_1 = 1.6; //[0.8:3.2:0.1]
lib_od_1 = 3.2; //[1.6:6.4:0.1]
lib_id_2 = 2.4; //[1.2:4.8:0.1]
lib_od_2 = 4.8; //[2.4:9.6:0.1]
lib_id_3 = 3.2; //[1.6:6.4:0.1]
lib_od_3 = 6.4; //[3.2:12.8:0.1]
eps_overlap = 1; //[0.5:2:0.1]

$fn = 96;

// Helpers
function od_sel() = (type_index==1) ? lib_od_1 : (type_index==2) ? lib_od_2 : lib_od_3;
function id_sel() = (forced_id>0) ? forced_id : ((type_index==1) ? lib_id_1 : (type_index==2) ? lib_id_2 : lib_id_3);

module heatshrink_sleeve(len=length, od=od_sel(), id=id_sel(), centered=center) {
    // Ensure valid wall thickness and non-zero geometry
    od2 = max(od, 0.2);
    id2 = min(max(id, 0.0), od2 - 0.2);
    h2  = max(len, 0.2);

    color([0.85, 0.85, 0.8])
    difference() {
        cylinder(r=od2/2, h=h2, center=centered);
        cylinder(r=id2/2, h=h2 + 2*eps_overlap, center=centered);
    }
}

// Output: ONE connected solid (the sleeve itself)
heatshrink_sleeve();