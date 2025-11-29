import Foundation

struct RecyclingItem: Identifiable {
    let id = UUID()
    let name: String
    let examples: String
    let bin: BinType
    let keywords: [String]

    /// Simple text search across name + keywords + examples
    func matches(_ query: String) -> Bool {
        if query.isEmpty { return true }
        let q = query.lowercased()
        if name.lowercased().contains(q) { return true }
        if examples.lowercased().contains(q) { return true }
        return keywords.contains(where: { $0.lowercased().contains(q) })
    }
}

struct RecyclingData {
    static let items: [RecyclingItem] = [
        // GENERAL WASTE (BLACK)
        RecyclingItem(
            name: "Nappies & sanitary products",
            examples: "Used nappies, sanitary towels, wipes",
            bin: .general,
            keywords: ["nappy", "nappies", "sanitary", "pads", "wipes"]
        ),
        RecyclingItem(
            name: "Crisp packets & sweet wrappers",
            examples: "Crisp bags, sweet wrappers, foil packets",
            bin: .general,
            keywords: ["crisps", "crisp packet", "sweet wrapper", "foil packet"]
        ),
        RecyclingItem(
            name: "Polystyrene & plastic film",
            examples: "Foam packaging, plastic film, bubble wrap",
            bin: .general,
            keywords: ["polystyrene", "foam", "bubble wrap", "plastic film"]
        ),
        RecyclingItem(
            name: "Broken glassware & crockery",
            examples: "Broken cups, plates, drinking glasses",
            bin: .general,
            keywords: ["broken glass", "crockery", "plate", "mug"]
        ),

        // BROWN RECYCLING
        RecyclingItem(
            name: "Bottles & jars",
            examples: "Glass bottles, jars (emptied and rinsed)",
            bin: .recyclingBrown,
            keywords: ["bottle", "glass bottle", "jar", "wine bottle", "jam jar"]
        ),
        RecyclingItem(
            name: "Cans & tins",
            examples: "Food tins, drink cans, aerosol cans (empty)",
            bin: .recyclingBrown,
            keywords: ["tin", "can", "aerosol", "coke can", "beans tin"]
        ),
        RecyclingItem(
            name: "Plastic bottles & tubs",
            examples: "Shampoo bottles, milk bottles, yoghurt pots",
            bin: .recyclingBrown,
            keywords: ["plastic bottle", "milk bottle", "yoghurt pot", "shampoo bottle"]
        ),

        // BLUE RECYCLING
        RecyclingItem(
            name: "Paper & envelopes",
            examples: "Letters, envelopes (no plastic windows if possible)",
            bin: .recyclingBlue,
            keywords: ["paper", "envelope", "letters", "junk mail"]
        ),
        RecyclingItem(
            name: "Cardboard packaging",
            examples: "Cereal boxes, online delivery boxes (flattened)",
            bin: .recyclingBlue,
            keywords: ["cardboard", "box", "amazon box", "cereal box"]
        ),
        RecyclingItem(
            name: "Newspapers & magazines",
            examples: "Magazines, newspapers, brochures",
            bin: .recyclingBlue,
            keywords: ["newspaper", "magazine", "brochure"]
        ),

        // FOOD WASTE
        RecyclingItem(
            name: "Cooked & uncooked food",
            examples: "Leftovers, peelings, bread, rice, pasta",
            bin: .food,
            keywords: ["food", "leftovers", "peelings", "bread", "rice", "pasta"]
        ),
        RecyclingItem(
            name: "Tea bags & coffee grounds",
            examples: "Used tea bags, coffee grounds",
            bin: .food,
            keywords: ["tea bag", "coffee grounds"]
        ),
        RecyclingItem(
            name: "Egg shells & fruit cores",
            examples: "Egg shells, apple cores, banana skins",
            bin: .food,
            keywords: ["egg shell", "apple core", "banana skin"]
        ),

        // GARDEN WASTE
        RecyclingItem(
            name: "Grass cuttings & leaves",
            examples: "Mown grass, fallen leaves",
            bin: .garden,
            keywords: ["grass", "grass cuttings", "leaves"]
        ),
        RecyclingItem(
            name: "Plants & prunings",
            examples: "Small branches, plant cuttings",
            bin: .garden,
            keywords: ["plants", "prunings", "branches", "twigs"]
        ),
        RecyclingItem(
            name: "Flowers & weeds",
            examples: "Cut flowers, dead plants, non-invasive weeds",
            bin: .garden,
            keywords: ["flowers", "weeds", "dead plants"]
        ),

        // THINGS THAT NEVER GO IN ANY BIN (just guidance)
        RecyclingItem(
            name: "Batteries & electronics",
            examples: "Household batteries, phones, laptops – take to a recycling point.",
            bin: .general, // but note in UI this shouldn't go in any wheelie bin
            keywords: ["battery", "batteries", "phone", "laptop", "electronics"]
        )
    ]
}
