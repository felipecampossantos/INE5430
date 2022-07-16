pos(boss,15,15).
checking_cells.
resource_needed(1).

+my_pos(X,Y) 
   :  checking_cells & not building_finished
   <- //!check_for_resources.
   !check_for_found_resources.

+!check_for_resources
   :  resource_needed(R) & found(R)
   <- !stop_checking;
      !take(R,boss);
      !continue_mine.   

+!check_for_resources
   :  resource_needed(R) & not found(R)
   <- 
   .wait(100);
   //!check_for_found_resources.
  move_to(next_cell).

+!check_for_found_resources:
  resource_needed(R) & .count(resource_location(_,R,_,_), N) & N > 0
  <- .findall(locs(H,X,Y), resource_location(H,R,X,Y), P);  // adds to P all known locations for resource R
      .sort(P,T);                                           // adds to T the ordered list P (as hipotenuse is the first parameter, it will sort by it)
      .nth(0, T, L);                                        // adds to L the first element of T (smallest hipotenuse)
      .print(L).


+!check_for_found_resources:
  resource_needed(R) & .count(resource_location(_,R,_,_), N) & not N > 0
  <- //.wait(100);
    //move_to(next_cell);
    !check_for_resources.


// if some resource was found, but not the one they need right now, add its location to the beliefs
+found(FOUND): not resource_needed(FOUND) & resource_needed(CURRENT) & FOUND > CURRENT
   <- ?my_pos(X,Y);                                         // find current location
      ?pos(boss,BX,BY);                                     // gets boss location
      hipotenuse(math.abs(BX-X), math.abs(BY-Y), H);       //calculates distance from builder
      .print("Resource found at (",X,",",Y,") and hipotenuse is ", H);
      -resource_location(H,FOUND,X,Y);                      // first removes belief so it doesnt duplicate in case it is not the first time agent is passing here
      +resource_location(H,FOUND,X,Y);                      // add this resource location to beliefs 
      //.broadcast(untell, resource_location(H,FOUND,X,Y)); // remove first, same reason above
      .broadcast(tell, resource_location(H,FOUND,X,Y)).     // warn others about this location

+!stop_checking : true
   <- ?my_pos(X,Y);
      +pos(back,X,Y);
      -checking_cells.

+!take(R,B) : true
   <- .wait(100);
   	  mine(R);
      !go(B);
      drop(R).

+!continue_mine : true
   <- !go(back);
      -pos(back,X,Y);
      +checking_cells;
      !check_for_resources.

+!go(Position) 
   :  pos(Position,X,Y) & my_pos(X,Y)
   <- true.

+!go(Position) : true
   <- ?pos(Position,X,Y);
      .wait(100);
      move_towards(X,Y);
      !go(Position).

@psf[atomic]
+!search_for(NewResource) : resource_needed(OldResource)
   <- +resource_needed(NewResource);
      // drop all beliefs about old resource
      .abolish(resource_location(_,OldResource,_,_));
      -resource_needed(OldResource).

@pbf[atomic]
+building_finished : true
   <- .drop_all_desires;
      !go(boss).
      

// calculates hipotenuse
hipotenuse(X,Y,H) :- H = math.sqrt((X**2) + (Y**2)).