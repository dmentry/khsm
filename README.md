# Lucky Person (Счастливчик)
It is implementation of famous Who Wants to Be a Millionaire? game. You should answer questions which difficulty is growing constantly and earn money for correct answers. 
There are three her users, upload photos to events. Also there is possibility to put the mark on the map (e.g. rendezvous point). 

Player is asked increasingly difficult general knowledge questions. Each features four possible answers, to which the contestant must give the correct answer. 
Doing so wins them a certain amount of money, with tackling more difficult questions increasing their prize fund. 
During their game, the player has a set of lifelines that they may use only once to help them with a question, as well as two "safety nets" – 
if a contestant gets a question wrong, but had reached a designated cash value during their game, player will leave with that amount as their prize. 
If a contestant feels unsure about an answer and does not wish to play on, they can walk away with the money they have won.

# Try application
https://luckyperson.herokuapp.com

# System
Ruby 2.7.0

Rails 4.2.6

# Installation
git clone git@github.com:dmentry/khsm.git

## Before run
bundle && bundle exec rake db:migrate

### Run locally server
bundle exec rails s

### Open in browser

http://127.0.0.1:3000
