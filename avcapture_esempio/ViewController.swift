//
//  ViewController.swift
//  avcapture_esempio
//
//  Created by Francesco Mattiussi on 19/03/2019.
//  Copyright © 2019 Francesco Mattiussi. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    var layer_preview: AVCaptureVideoPreviewLayer! //il layer contenente l'output della fotocamera
    var sessione: AVCaptureSession! //inizializza la sessione di cattura
    var immagine = AVCaptureStillImageOutput() //inizializza l'immagine statica che verrà scattata
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualizza() //carica la vista della webcam secondo gli argomenti specificati nella sua funzione
        
        // Do any additional setup after loading the view.
    }
    
    let desktop = "/Users/francesco/Desktop/" //cartella di salvataggio della foto

    @IBOutlet weak var vista: NSView! //view sul quale verrà aapplicato il layer contenente la vista della fotocamera
    
    @IBAction func scatta(_ sender: NSButton) { //funzioni eseguite al momento della pressione del tasto scatta
        self.immagine.captureStillImageAsynchronously(from: immagine.connection(with: .video)!) { (buffer: CMSampleBuffer?, error: Error?) in //cattura l'immagine e specifica il sottostante completionhandler
            let immmagine_grezza = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!) //dati grezzi immagine
            let dati_immagine = NSImage(data: immmagine_grezza!) // creazione della UIImage
            DispatchQueue.main.async { //esegue l'azione su un thread asincrono per non intasare il thread principale
                self.anteprima_foto.image = dati_immagine! //asseggna all'imageview l'immagine appena ottenuta
            }
        }
        
    }
    
    @IBOutlet weak var textfield: NSTextField!
    
    @IBAction func salva(_ sender: Any) { //funzioni di salvataggio dell'immagine eseguite al click sul tasto salva
        let destinazione = desktop + textfield.stringValue + ".png" //crea la destinazione specificando la cartella, il nome del file e l'estensione
        if textfield.stringValue == "" { //se non viene inserito nessun titolo all'immagine viene mostrato un messaggio di errore
            let alert = NSAlert()
            alert.addButton(withTitle: "OK!")
            alert.messageText = "Devi per forza dare un nome al file!"
            alert.runModal()
        } else if anteprima_foto.image == nil { //se non è stata scattata nessuna foto mosta un messaggio di errore
            let alert = NSAlert()
            alert.addButton(withTitle: "OK!")
            alert.messageText = "Scatta prima una foto"
            alert.runModal()
        } else { //se tutti i requisiti sono soddisfatti procede con il salvataggio
            try! NSBitmapImageRep(data: anteprima_foto.image!.tiffRepresentation!)!.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: destinazione)) //crea l'immagine in formato png e la salva nella destinazione indicata
            let alert = NSAlert()
            alert.addButton(withTitle: "Perfetto") //mostra un messaggio di successo
            alert.messageText = "Salvato!"
            alert.runModal()
        }
    }
    
    
    
    @IBOutlet weak var anteprima_foto: NSImageView! //outlet dell'imageview che mostrerà la foto appena scattata
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func visualizza() { //funzione di configurazione della vista della webcam
        immagine = AVCaptureStillImageOutput() //imposta l'immagine statica
        sessione = AVCaptureSession() //imposta la sessione di cattura
        sessione.addOutput(immagine) //imposta l'immagine statica come output della sessione
        sessione.sessionPreset = AVCaptureSession.Preset.medium //indica la qualità dell'output
        let webcamCaptureDevice: AVCaptureDevice = AVCaptureDevice.default(for: .video)! //imposta la webcam come dispositivo di cattura
        let webcamInput: AVCaptureDeviceInput = (try! AVCaptureDeviceInput(device: webcamCaptureDevice)) //imposta la webcam come dispositivo di input
        sessione.addInput(webcamInput) //aggiunge la webcam come input della sessione
        let view: NSView = vista //nome safe per la vista su cui applicare il layer
        view.wantsLayer = true //la vista richiede un layer
        layer_preview = AVCaptureVideoPreviewLayer(session: sessione) as AVCaptureVideoPreviewLayer //attribuisce la sessione al layer
        view.layer = layer_preview //attribuisce il layer alla view
        sessione.startRunning() //inizia la sessione
        
    }
    

}

