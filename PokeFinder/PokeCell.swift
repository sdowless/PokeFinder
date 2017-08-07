//
//  PokeCell.swift
//  PokeFinder
//
//  Created by Stephan Dowless on 2/2/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit

class PokeCell: UITableViewCell {

    @IBOutlet weak var pokeLbl: UILabel!
    @IBOutlet weak var pokeImg: UIImageView!


    func configureCell(poke: Pokemon) {
        pokeLbl.text = poke.name.capitalized
        pokeImg.image = UIImage(named: "\(poke.pokeID)")
    }
    
}
