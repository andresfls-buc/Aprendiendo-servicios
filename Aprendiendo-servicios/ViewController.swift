//
//  ViewController.swift
//  Aprendiendo-servicios
//
//  Created by Andres Landazabal on 2025/06/21.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Referencias UI
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Constantes
    private let apiEndpoint = "https://jsonplaceholder.typicode.com/users/1" // Endpoint funcional de prueba
    private let timeoutInterval: TimeInterval = 15.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        fetchService()
    }
    
    // MARK: - Configuración Inicial
    private func setupInitialUI() {
        nameLabel.text = ""
        statusLabel.text = "Cargando..."
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - Servicio API
    private func fetchService() {
        // 1. Validar URL
        guard let url = URL(string: apiEndpoint) else {
            showError("URL inválida")
            return
        }
        
        // 2. Configurar sesión con timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        let session = URLSession(configuration: config)
        
        // 3. Realizar petición
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleResponse(data: data, response: response, error: error)
            }
        }
        
        task.resume()
    }
    
    // MARK: - Manejo de Respuesta
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        activityIndicator.stopAnimating()
        
        // 1. Manejar errores de conexión
        if let error = error {
            showError("Error de conexión: \(error.localizedDescription)")
            return
        }
        
        // 2. Verificar respuesta HTTP
        guard let httpResponse = response as? HTTPURLResponse else {
            showError("Respuesta inválida")
            return
        }
        
        print("Status Code:", httpResponse.statusCode)
        
        // 3. Validar código de estado
        guard (200...299).contains(httpResponse.statusCode) else {
            showError("Error HTTP: \(httpResponse.statusCode)")
            return
        }
        
        // 4. Validar datos recibidos
        guard let data = data else {
            showError("No se recibieron datos")
            return
        }
        
        // 5. Parsear y mostrar datos
        parseJSON(data: data)
    }
    
    // MARK: - Procesamiento JSON
    private func parseJSON(data: Data) {
        do {
            // 1. Intentar parsear como JSON
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            // 2. Debug: Imprimir respuesta completa
            print("Respuesta JSON:", jsonObject)
            
            // 3. Extraer datos específicos
            if let userData = jsonObject as? [String: Any] {
                updateUI(with: userData)
            } else {
                showError("Formato de datos inesperado")
            }
        } catch {
            showError("Error al procesar JSON: \(error.localizedDescription)")
            
            // Debug: Mostrar contenido recibido
            if let responseString = String(data: data, encoding: .utf8) {
                print("Contenido recibido:", responseString)
            }
        }
    }
    
    // MARK: - Actualización UI
    private func updateUI(with data: [String: Any]) {
        // Extraer valores con defaults seguros
        let userName = data["name"] as? String ?? "Usuario desconocido"
        let userEmail = data["email"] as? String ?? "Email no disponible"
        
        // Actualizar UI
        nameLabel.text = "\(userName)\n\(userEmail)"
        statusLabel.text = "Carga exitosa"
        statusLabel.textColor = .systemGreen
    }
    
    private func showError(_ message: String) {
        nameLabel.text = "❌ Error"
        statusLabel.text = message
        statusLabel.textColor = .systemRed
    }
    
    // MARK: - Acción para reintentar
    @IBAction func retryButtonTapped(_ sender: UIButton) {
        setupInitialUI()
        fetchService()
    }
}
