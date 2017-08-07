//
//  PokeToSend.swift
//  PokeFinder
//
//  Created by Stephan Dowless on 2/3/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

class SendPokemon {
    var location: CLLocation!
    var pokemonID: Int!
    
    init(location: CLLocation, pokemonID: Int) {
        self.location = location
        self.pokemonID = pokemonID + 1
    }
}
