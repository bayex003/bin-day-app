// Sources/Models/OSAddress.swift
import Foundation

/// Simple app-level model for an OS address record.
struct OSAddress: Identifiable, Equatable {
    let id: String          // usually the UPRN
    let label: String       // full address line for display
    let postcode: String?   // e.g. "M30 8HA"
    let uprn: String?       // unique property reference number
}
