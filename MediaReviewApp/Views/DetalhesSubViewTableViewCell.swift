//
//  DetalhesSubViewTableViewCell.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

class DetalhesSubViewTableViewCell:UITableViewCell{
    
    
    @IBOutlet weak var semResultadoView: SemResultadoView!
    @IBOutlet weak var tituloValLbl: UILabel!
    @IBOutlet weak var generoValLbl: UILabel!
    @IBOutlet weak var anoLancamentoValLbl: UILabel!
    @IBOutlet weak var popularidadeValLbl: UILabel!
    @IBOutlet weak var votacaoMediaValLbl: UILabel!
    @IBOutlet weak var quantidadeMediaValLbl: UILabel!
    @IBOutlet weak var adultoValLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
