//
//  TimeFormatterProtocol.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 06.03.2023.
//

protocol TimeFormatterProtocol: FormatterProtocol {
    var timeFormatterOptions: TimeFormatterOptions { get set }
}
