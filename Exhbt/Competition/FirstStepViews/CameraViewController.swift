//
//  CameraVCViewController.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    private var captureSession: AVCaptureSession = {
        let temp = AVCaptureSession()
        temp.sessionPreset = .high
        return temp
    }()
    private var stillImageOutput: AVCapturePhotoOutput = {
        let temp = AVCapturePhotoOutput()
        return temp
    }()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let temp = AVCaptureVideoPreviewLayer(session: self.captureSession)
        temp.videoGravity = .resizeAspectFill
        temp.connection?.videoOrientation = .portrait
        return temp
    }()
    
    weak var delegate: ImagePickedDelegate?
    private let captureButtonSize: CGFloat = 80
    private var previewReady = false
    
    private lazy var previewView: UIView = {
        let temp = UIView()
        temp.backgroundColor = .black
        return temp
    }()
    
    private lazy var captureButton: UIButton = {
        let tempInnerView = UIView()
        tempInnerView.backgroundColor = .clear
        tempInnerView.layer.borderColor = UIColor.darkGray.cgColor
        tempInnerView.layer.borderWidth = 1.0
        tempInnerView.layer.cornerRadius = (self.captureButtonSize - 10) / 2
        tempInnerView.layer.masksToBounds = true
        tempInnerView.isUserInteractionEnabled = false
        
        let temp = UIButton()
        temp.backgroundColor = .white
        temp.layer.cornerRadius = self.captureButtonSize / 2
        temp.layer.masksToBounds = true
        
        temp.addSubview(tempInnerView)
        tempInnerView.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview().offset(5)
            make.trailing.bottom.equalToSuperview().offset(-5)
        }
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.checkIfAccessAllowed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.previewReady {
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.captureSession.stopRunning()
    }
    
    private func checkIfAccessAllowed() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            self.setupCamera()
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Camera", message: "Camera access is necessary to take photos.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }))
                
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func setupCamera() {
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            return
        }
        
        if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
            captureSession.addInput(input)
            captureSession.addOutput(stillImageOutput)
            setupLivePreview()
        }
    }
    
    private func setupLivePreview() {
        self.previewView.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
        DispatchQueue.main.async {
            self.previewLayer.frame = self.previewView.bounds
        }
        self.previewReady = true
    }
    
    private func setupViews() {
        self.view.addSubview(self.previewView)
        self.previewView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.captureButton)
        self.captureButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(self.captureButtonSize)
            make.centerX.equalTo(self.view.snp.centerX)
            make.bottom.equalTo(self.view.snp.bottom).offset(-40)
        }
        self.captureButton.addTarget(self, action: #selector(capturePressed), for: UIControl.Event.touchUpInside)
    }
    
    @objc private func capturePressed(sender: UIButton!) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        self.stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        
        delegate?.photoWasPicked(image: image, fromGallery: false, imageUUID: UUID().uuidString)
    }
}
