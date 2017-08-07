//
//  PokemonSelectVC.swift
//  PokeFinder
//
//  Created by Stephan Dowless on 2/2/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit
import MapKit

class PokemonSelectVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var pokeLocation: CLLocation!
    var sendPoke: SendPokemon!
    var pokeArray = [Pokemon]()
    var poke: Pokemon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configureArray()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokeCell", for: indexPath) as? PokeCell
        configureCell(cell: cell!, indexPath: indexPath)
        
        return cell!
    }
    
    func configureCell(cell: PokeCell, indexPath: IndexPath) {
        
        let poke = pokeArray[indexPath.row]
        cell.configureCell(poke: poke)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemon.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let selectedPokemon = indexPath.row
        print("Selected Pokemon: \(selectedPokemon)")
        print("Pokemon Location: \(pokeLocation)")
        
        sendPoke = SendPokemon(location: pokeLocation, pokemonID: selectedPokemon)
        
        performSegue(withIdentifier: "MainVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainVC"  {
            let destination = segue.destination as! ViewController
            destination.pokeLocation = sendPoke.location
            destination.selectedPokemon = sendPoke.pokemonID
            
            print("Selected Pokemon: \(sendPoke.pokemonID)")
            print("Pokemon Location: \(sendPoke.location)")
        }
    }
    
    func configureArray() {
        
        for i in 0..<pokemon.count {
            let pokeName = pokemon[i]
            let pokeID = i + 1
            
            let poke = Pokemon(name: pokeName, pokeID: pokeID)
            pokeArray.append(poke)
        }
        
    }
}


