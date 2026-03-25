$fn=64;

module flat_bar(len=0.9, wid=0.0, thk=0.1){
    cube([len, wid, thk], center=true);
}

flat_bar();