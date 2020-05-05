//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    
    func didFailWithError(error: Error)
    func didFetchPrice(price: String, currency: String)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "97BA8EE3-955B-4079-867E-1FF2260710BE"
    
    var delegate : CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String)
    {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        if let url = URL(string: urlString)
        {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if (error != nil)
                {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data
                {
                    if let price = self.parseJson(safeData)
                    {
                        let priceString = String(format: "%.2f", price)
                        self.delegate?.didFetchPrice(price: priceString, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJson(_ data: Data) -> Double?
    {
        let decoder = JSONDecoder()
        do
        {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let price = decodedData.rate
            return price
        }
        catch
        {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
