/**
* Name: basic
* Author: spiro
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/* Insert your model definition here */
global {
	point sceneloc <- {50, 0};
	point sceneloc1 <- {10, 90};
	int guest_num <- 3;
	
	int balance <- 5000;
	int minCost <- 100;
	int maxCost <- 1000;
	init{
		
		create participant number: guest_num  {
	//		location <- sceneloc1 ;
		}
		
		create auction_scene number: 2 {
			location <- sceneloc;
		}
		
		create initiator number: 1 {
			location <- sceneloc;
		}
	}
	
}
/*
 *  ******************** GLOBAL ENDS HERE ****************************
 */

/*
 *  ******************** SPECIES START HERE *************************
 */


	
species participant skills:[fipa, moving] {
	
	point target_point <- nil;
	int preferedPrice <- rnd(500, 1000);
	bool cfp1 <- false;
	
	
	reflex wander when:target_point = nil {
		do wander;
	}
	
		reflex go_to_scene  {
	
		if (location distance_to sceneloc1 > 4) {
			do goto target:sceneloc1;
	}
	
	}
	
	reflex read_informs when:(!empty(informs)) {
		message messageInc <- (informs at 0);
		string product <- string(messageInc.contents[0]);
		if (string(product) = "T-Shirt"){
			do start_conversation (to: list(initiator), protocol: 'fipa-inform', performative: 'inform', contents:["Interested"]);
		}
		else if (string(product) != "T-Shirt") {
			do refuse with:(message: messageInc, contents: ['Not Interested']);
		}
	}


	reflex do_i_propose when:(!empty(cfps) and !cfp1) {
		message messageInc <- (cfps at 0);
		int product_price <- int(messageInc.contents[0]);
		write name + " willing to buy for price: " + preferedPrice;
		if (product_price > preferedPrice) {
			write "@@@@@@@ " + name + " rejects " + product_price;
			do propose with:(message: messageInc, contents: ["Lower it", preferedPrice]);
			cfp1 <- true;
		}
	}
	
	reflex read_rejected when: (!empty(reject_proposals)) {
		message messageInc <- (reject_proposals at 0);
		write (name + " rejected, " + string(messageInc.contents[0]) + " than " + int(messageInc.contents[1]));
	}

	
	reflex read_accepted when:(!empty(accept_proposals)) {
		message messageInc <- (accept_proposals at 0);
		int newPrice <- int(messageInc.contents[0]);
		if newPrice <= preferedPrice {
			write "We have a deal";
		}
		do start_conversation (to:list(initiator), protocol: 'fipa-inform', performative: 'inform', contents: ['I WILL BUY IT']);
		
	}

	
	aspect base {
		draw pyramid(3)at:{location.x, location.y, 0} color: #darkred;
		draw sphere(1) at:{location.x, location.y,2}color: #darkred;
		
		//x<-x +3;
		//y<-y -3;
	}
}


species initiator skills:[fipa, moving]{
		
	list<participant> agreedBuyers;
	
	list<string> products <- ['T-Shirt', 'CD', 'Instrument'];
	int num <- rnd(0,2);
	string product;
	bool isSold <- false;
	
	bool auctionStart <- false;
	bool inform1 <- false;

	bool ready <- false;

	int shirtPrice <- 2000;
	int reduction <- rnd(100, 200);
	int lowestPrice <- 600;
	
	int counter <- 0;
	
	reflex auction_starts when:(time = rnd(10, 25)) {
		write "(Time " + time + "): Auction is starting now";
		auctionStart <- true;
		ready <- true;
		
			
	}
		
		
	reflex heading_to_scene when:(ready =true) {
	 		if (location distance_to sceneloc1 > 4) {
			do goto target:{sceneloc1.x,sceneloc1.y-10};
		}
	}
	//The auction starts with the initiator informing about the product    
	reflex send_inform when: (!inform1 and counter = 0 and auctionStart  and location distance_to sceneloc1 < 15) {
		if(num = 0) {
			product <- products[0];
		}
		else if(num = 1) {
			product <- products[1];
		}
		else if(num = 2) {
			product <- products[2];
		}
		
		do start_conversation (to :: list(participant), protocol :: 'fipa-inform', performative :: 'inform', contents :: ['T-Shirt']);
		write ("(Time " + time + "): " + name + " sends inform message to all participants with content: T-Shirt");
		write "Selling for price: " + shirtPrice;
		inform1 <- true; 
	}
	
	reflex read_inform_from_participant_and_send_price when: (!empty(informs) and counter <= 2) {
		message messageInc <- (informs at 0);
		string interested_or_not <- messageInc.contents[0];
		if interested_or_not = "Interested" {
			agreedBuyers <+ messageInc.sender;
			counter <- counter + 1;
			write ("(Time " + time + "): " +string(messageInc.sender) + " wants to participate");
			write ("(Time " +string(time) + "): " + name + " sends a cfp message to: " + string(messageInc.sender));
			do start_conversation (to: list(agreedBuyers), protocol: 'fipa-contract-net', performative: 'cfp', contents: [shirtPrice] );
		}
	}
	
	reflex accept_reject_proposes when:(!empty(proposes) and !isSold) {
		message messageInc <- (proposes at 0);
		int price <- int(messageInc.contents[1]);
		if( price < lowestPrice) {
			do reject_proposal (message: messageInc, contents:["can't go any lower", lowestPrice]);
		}
		else if(price > lowestPrice) {
			int newPrice <- shirtPrice - reduction;
			write "Proposal from " +messageInc.sender + " accepted, new price is: "+ newPrice;
			do accept_proposal (message: messageInc, contents:[newPrice]);
		}
	}
	
	reflex will_you_buy when:(!empty(informs) and length(agreedBuyers) = 3 and !isSold) {
		message messageInc <- (informs at 0);
		string contents <- string(messageInc.contents[0]);
		if(contents = "I WILL BUY IT") {
			write "SOOOOOOOOOOOOOOOOOOOOOOLD TO " + string(messageInc.sender);
			isSold <- true;
		}
		
	}
	
	
	aspect base {
		draw pyramid(3)at:{location.x, location.y, 0} color: #blue;
		draw sphere(1) at:{location.x, location.y,2}color: #blue;
	}
}

species auction_scene {
	
	rgb color <- #green;
	
	aspect base {
		draw circle(6) color: #green;
		draw square(15)at:sceneloc1 color: #red;
	}
	
}

/*
 *  *************************** SPECIES END HERE **************************
 */

experiment main {
	
	output {
		
		display map type: opengl {
			species participant aspect: base;
			species initiator aspect: base;
			species auction_scene aspect: base;
		}
	}
}

