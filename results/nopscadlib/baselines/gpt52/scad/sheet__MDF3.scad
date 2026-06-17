$fn=64;

module sheet_mdf(length=600, width=400, thickness=6) {
    cube([length, width, thickness], center=true);
}

sheet_mdf();