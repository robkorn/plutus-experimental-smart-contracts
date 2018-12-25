Naive Lottery SC
-----------------
This is a very naively implemented "lottery" SC. Only 3 numbers, the winning ticket doesn't get hashed, submitted numbers aren't checked for duplicates, and I'm sure there's more.

Nonetheless it works for a simple proof of concept.

### How The Lottery Works

- Player calls watchSCAddress first.
- Lottery holder calls startGame and provides the 3 winning numbers in addition to the amount of ada he wishes to put in as a prize.
- Player calls submitTicket with his/her guess of what the 3 winning numbers are.
- If player guesses the winning numbers, they collect the prize. Otherwise the lottery holder can withdraw at any time using the numbers he originally provided.
