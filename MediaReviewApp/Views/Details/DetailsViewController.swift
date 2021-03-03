//
//  DetailsViewController.swift
//  MediaReviewApp
//
//  Created by Gabriel Moraes on 26/09/20.
//  Copyright © 2020 Gabriel Moraes. All rights reserved.
//

import Foundation
import UIKit

enum DetailSubView {
    case detalhes
    case assistaTambem
}

class DetailsViewController: UIViewController,Storyboarded {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel:DetailsViewModel?
    private var subViewVisivel:DetailSubView = .assistaTambem
    var coordinator:DetailsCoordinator?
    var assistaTambemMedia:[Any] = []
    var mediasFetched:[RecommendMedia] = []
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        viewModel?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.topItem?.title = "Details"
        //tableView.reloadData()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.coordinator?.notifyWillDisappear()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIDevice.current.orientation.isLandscape {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @IBAction func changeSegment(_ sender: TabSegmentControl) {
        sender.selectSegment()
        subViewVisivel = sender.selectedSegmentIndex == 0 ? .assistaTambem : .detalhes
        self.tableView.reloadRows(at:  [IndexPath(row: 1, section: 0)], with: .fade)
    }
    
}


extension DetailsViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 500
        }
        let sizeOfSubViews = self.view.frame.height - 500
        return sizeOfSubViews > 342 ? sizeOfSubViews:342
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row  == 0 {
            
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: "MediaInfoTableViewCell") as? MediaInfoTableViewCell {
                if let mediaId = viewModel?.getMedia(){
                    cell.mediaId = mediaId
                }
                guard let imgData = viewModel?.getImgData() else {return UITableViewCell()}
                let image = UIImage(data: imgData)
                let favorited = viewModel?.getFavoritado()
                let videoPath = viewModel?.getvideoPath()
                let isConnectedToInternet = viewModel?.isConnectedToInternet ?? false
                cell.configMinhaListaBtn(favoritado: (favorited ?? false),enabled:isConnectedToInternet)
                cell.backgroundImageView.image = image
                cell.mediaPosterView.image = image
                cell.tituloLbl.text = viewModel?.getTitle()
                cell.tipoLbl.text = viewModel?.getTypeSubLbl()
                cell.tipo = viewModel?.getType()
                cell.descricao.text = viewModel?.getOverView()
                cell.descricao.textColor = .white
                cell.delegate = self
                
                cell.minhaListaBtn.isSelected = favorited ?? false
                let canPlay = viewModel?.isConnectedToInternet == true ? (videoPath?.isEmpty == false): isConnectedToInternet
                cell.videoId = videoPath
                cell.configYoutubeVideo(canPlayVideo:canPlay)
                cell.backgroundColor = .yellow
                self.view.setNeedsLayout()
                
                return cell
            }
            
        } else if indexPath.row  == 1 {
            
            if subViewVisivel == .assistaTambem{
                if let cell = self.tableView.dequeueReusableCell(withIdentifier: "AssistaTambemTableViewCell") as? AssistaTambemTableViewCell {
                    cell.media = viewModel?.getRecommendMedia() ?? []
                    return cell
                    
                }
                
            } else if subViewVisivel == .detalhes {
                
                if let cell = self.tableView.dequeueReusableCell(withIdentifier: "DetalhesSubViewTableViewCell") as? DetalhesSubViewTableViewCell {
                    if let mediaData = viewModel?.getMediaData()?.last{
                        cell.tituloValLbl.text = mediaData.name
                        cell.generoValLbl.text = viewModel?.getGenres()
                        cell.anoLancamentoValLbl.text = mediaData.release_date
                        cell.popularidadeValLbl.text =  String(mediaData.popularity)
                        cell.votacaoMediaValLbl.text = String(mediaData.vote_average)
                        cell.quantidadeMediaValLbl.text = String(mediaData.vote_count)
                        cell.adultoValLbl.text = mediaData.adult == true ? "Yes":"No"
                        
                        return cell
                    }
                }
            }
        }

        return UITableViewCell()
    }
    
}

extension DetailsViewController:MediaInfoCellMessager{
    func playVideo(videoID: String) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController {
            nextViewController.videoID = videoID
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    
    func AdicionarEmMinhaLista(id: Int32,favoritado: Bool) {
        viewModel?.updateData(id:id,favorite: favoritado)
    }
    
    func returnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DetailsViewController:DetailsViewModelDelegate{
    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func update() {
        DispatchQueue.main.async {
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: 1,
                                                         section: 0)],
                                          with: .automatic)
            }, completion: nil)
        }
    }
    
    func showErrorMsg() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Connection error", message: "There was a problem with your connection, so some activities have been disabled", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel, handler: { action in
                self.tableView.reloadData()
            })
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true,completion:nil)
        }
    }
    
    
}

