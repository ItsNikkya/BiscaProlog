colorofcard(red,c(_,S)):-S=hearts;S=diamonds.

colorofcard(black,c(_,S)):-S=clubs;S=spades.

card(c(R,S)):-ranks(LR),suits(LS),member(R,LR),member(S,LS).

% given

ranks([2,3,4,5,6,queen,jack,king,7,ace]).
suits([hearts,diamonds,spades,clubs]).

rankshigher(R1,R2):-
    ranks(R),append(_,[R2|LR],R),member(R1,LR).

samesuit(c(_,S),c(_,S)).

color(hearts,red).
color(diamonds,red).
color(spades,black).
color(clubs,black).

colorcard(C,c(R,S)):-color(S,C),ranks(LR),member(R,LR).

points(ace,11):-!.
points(7,10):-!.
points(king,4):-!.
points(jack,3):-!.
points(queen,2):-!.
points(X,0):-integer(X), X>=2, X=<6.

% Begin our code
:- use_module(library(lists)).

% Based on the card predicate above, this generates the deck.
% deck(-Deck)
deck(D) :-
	findall(c(R,S), card(c(R,S)),D).

% shuffles the deck
% D is the deck (generated by deck/1), SD is the shuffled deck (to be "sorted" by random_permutation/2)
% shuffle(+Deck, -Shuffled Deck)
shuffle(D, SD) :- 
	deck(D), random_permutation(D, SD).

% representation of a hand - in bisca there are (up to?) three cards in a player's hand
% not being used at the moment
hand([c(R1, S1), c(R2, S2), c(R3, S3)]).

% trump/3: returns a clean deck with the trump card last, outputted for later use
% Make Prolog Great Again!
% trump(+Deck, -Flattened Deck, -Card)

trump(SD, X, c(R,S)):- 
	pick_first(c(R,S), SD1, SD),
	flatten(SD1,X).

% pick_first/2: picks the first card of a deck, and returns a mess of lists inside lists with trump card last
% pick_first(-Card, -Deck, +Deck)
pick_first(c(R,S), [SD|c(R,S)], [c(R,S)|SD]).

% deal_cards/5: deals cards for both players
% on an empty shuffled deck it does 
% dealcards(+Deck, -Hand1, -Hand2, -Remaining Deck, -Counter)

deal_cards([],[],[],[],_):- !.
deal_cards(RD,[],[],RD, 0):-!.

deal_cards(D, [S1|H1], [S2|H2], RD, C) :-
	C2 is C-1,
	dc(S1, RD1, D),
	dc(S2, RD2, RD1),
	deal_cards(RD2, H1, H2, RD, C2).

% dc/3: returns the first card of the deck, and the modified deck
% dc(-Card, -Deck, +Deck)
dc(_,[],[]).
dc(H, SD, [H|SD]).

%TODO
play_round([],[],[],P1,P2).
%remove assert

% handplayer1 handplayer2 deck 0 0 = init
play_round(Winner,Hand1, Hand2, Deck, PointsWon1, PointsWon2):-
	Winner == 1,
	player_select_play_first(Hand1, Card1),
	play_card(Hand1, Card1, NewHand1),!,
	select_play(Hand1, Card1, Card2),
	play_card(Hand2, Card2, NewHand2),
	round_won(Winner,NewHand1,NewHand2,Card1, Card2, Deck, WHand1, PointsWon1, LHand2, PointsWon2, NewDeck,NP1,NP2, NWinner),
	play_round(NWinner,WHand1,LHand2,NewDeck,NP1, NP2);
	
	select_play_first(Hand1, Card1),
	play_card(Hand1, Card1, NewHand1),!,
	player_select_play(Hand1, Card1, Card2),
	play_card(Hand2, Card2, NewHand2),
	round_won(Winner,NewHand1,NewHand2,Card1, Card2, Deck, WHand1, PointsWon1, LHand2, PointsWon2, NewDeck,NP1,NP2,NWinner),
	play_round(NWinner,WHand1,LHand2,NewDeck,NP1, NP2).

%count_trumps/2: counts the number of trump cards on hand, to be used in selecting cards to be played
%count_trumps(+Hand, -Counter)
count_trumps([], 0).
count_trumps([c(R,S)|H], Ctr):-
	isTrump(S),
	Ctr2 is Ctr+1,
	count_trumps(H, Ctr2).

	
%select_play_first/2: If first, computer chooses a card to be played
%TODO
select_play_first(H1,C1).
	
%select_play/3: If not first, selects which card to play - it will try to match suits
%TODO
select_play(H1,C1,C2).

%player_select_play_first/2 and player_select_play/3: indicate player's turn to play. player_select_play also shows what card the computer played.
%player_select_play_first(-Hand, +Card)
player_select_play_first(H1,C1):-
	writeln('You play first!'),
	write('Trump is '),
	isTrump(X),
	write(X),
	write('Your hand: '),
	writeln(H1),
	select_card(H1,C1).
%player_select_play(-Hand, -Card, +Card)
player_select_play(H1,C1,C2):-
	writeln('You play second!'),
	write('Trump is '),
	isTrump(X),
	writeln(X),
	write('Your hand:'),
	writeln(H1),
	write('Your opponent played: '),
	writeln(C1),
	select_card(H1,C2).

%select_card/2: actually prompts the player to pick a card from their hand
%select_card(+Hand, +Card)
select_card(X,Y):-
	write('Write 1, 2 or 3 to select a card at that position for play'),
	read(N),
	nth1(N,X,Y).


%addPoints/4: score updater
%addPoints(+Rank, +Rank, -Points, -Points)
addPoints(R1,R2,Points,NPoints):-
	points(R1,P1),
	points(R2,P2),
	NPoints is Points + P1 + P2.

%round_won/13: determines who wins the hand by comparing ranks if same suits
%round_won(old winner, old hand 1, old hand 2, card 1, card 2, deck, winner's hand, points won by player 1, loser's hand, points won by player 2 if that's the case, new deck, points, points, new winner) 
round_won(Winner, H1, H2, c(R1,S1), c(R2,S1), Deck, WHand1, PointsWon1, LHand2, PointsWon2, NewDeck,NP1, NP2, NWinner):-
	rankshigher(R1,R2),
	get_card(Deck,H1,WHand1,ND),
	get_card(ND,H2,LHand2,NewDeck),
	addPoints(R1,R2,PointsWon1,NP1),
	NP2 is PointsWon2,
	NWinner is Winner;

	get_card(Deck,H2,WHand1,ND),
	get_card(ND,H2,LHand2,NewDeck),
	addPoints(R1,R2,PointsWon2,NP2),
	NP1 is PointsWon1,
	NWinner is Winner*-1.

%round_won/13: determines who wins the hand by existance of trump cards
%round_won(old winner, old hand 1, old hand 2, card 1, card 2, deck, winner's hand, points won by player 1, loser's hand, points won by player 2 if that's the case, new deck, points, points, new winner)
round_won(Winner, H1, H2, c(R1,S1), c(R2,S2), Deck, WHand1, PointsWon1, LHand2, PointsWon2, NewDeck, NP1, NP2, NWinner):-
	isTrump(S2),
	get_card(Deck,H2,WHand1,ND),
	get_card(ND,H1,LHand2,NewDeck),
	addPoints(R1,R2,PointsWon2,NP2),
	NP2 is PointsWon2
	NWinner is Winner;
	
	get_card(Deck,H1,WHand1,ND),
	get_card(ND,H2,LHand2,NewDeck),
	addPoints(R1,R2,PointsWon1,NP1),
	NP1 is PointsWon1,
	Nwinner is Winner*-1.
	
%TODO: get_card/4

%play_card/3: removes card from player's hand
%play_card(+Hand, -Card, -New Hand)
play_card(H1,C1,NH1):-
	member(C1,H1), delete(H1,C1,NH1).


% start: game setup and communication of trump suit and player hand
% we will assume P1 is the human player
% TODO: make the game actually start

start(P) :- 
	deck(D), shuffle(D,SD),
	trump(SD, SD1, c(R,S)),
	assert(isTrump(S)),
	deal_cards(SD1, P1, P2, RD, 3),
	write('Trump is '), writeln(S),
	writeln('Your hand:'), writeln(P1),
	writeln('Do you want to go first? 1 for yes, -1 for no'),
	read(P).