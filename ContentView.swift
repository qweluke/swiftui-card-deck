import SwiftUI

enum CardBrand: String {
  case visa = "Visa"
  case mastercard = "MasterCard"
  case aura = "Aura"
  case fuelCard = "Fuel Card"
}

struct CardModel {
  let id: String
  let color: Color
  let owner: String
  let cardNumber: Int
  let cvv: Int
  let bank: String
  let brand: CardBrand
}

class CardDeckViewModel: ObservableObject {
  @Published private(set) var stack = [CardModel]()
  @Published var currentIndex: Int = 0
  
  func onCardSwipe(_ nextIndex: Int) {
    DispatchQueue.main.async {
      withAnimation {
        self.currentIndex = nextIndex
      }
    }
  }
  
  func fetchCards() async throws {
    // perform real API call
    try await Task.sleep(nanoseconds: 1_000_000_000)
    
    self.stack = [
      CardModel(id: UUID().uuidString, color: .blue, owner: "Lukasz Malicki", cardNumber: 4760833830626376, cvv: 935, bank: "AIG Bank Polska S.A.", brand: .visa),
      CardModel(id: UUID().uuidString, color: .red, owner: "David Walker", cardNumber: 377947908816629, cvv: 700, bank: "American Express", brand: .aura),
      CardModel(id: UUID().uuidString, color: .green, owner: "Madison Mitchell", cardNumber: 5078601995956159, cvv: 471, bank: "Aura", brand: .mastercard),
      CardModel(id: UUID().uuidString, color: .pink, owner: "Alexis Wright", cardNumber: 6319037971359158, cvv: 443, bank: "Duet", brand: .fuelCard)
    ]
  }
}


struct CardDeckView: View {
  
  @StateObject private var deckVM: CardDeckViewModel = .init()
  
  var body: some View {
    ZStack {
      
      ForEach(deckVM.stack.indices, id: \.self) { index in
        let card = deckVM.stack[index]
        let cardPosition = index - deckVM.currentIndex
        
        
        if index >= deckVM.currentIndex {
          VStack {
            
            Spacer()
            
            DraggableCardView(content: {
              CardView(card: card)
            }, onSwipe: { swipeDirection in
              deckVM.onCardSwipe(index + 1)
            }, overlay: { dragPercent, dragTranslate, dragDirection in
              // Handle drag overlay if needed
              // eg add trash icon or bookmark it
            })
            .frame(height: 250)
            .scaleEffect(1 - 0.06 * CGFloat(cardPosition), anchor: .top)
            .offset(y: CGFloat(cardPosition) * -7.5)
            
            Spacer()
          }
          .zIndex(Double(cardPosition) * -1)
          .padding(.horizontal, 10)
          
        } else {
          EmptyView()
        }
        
        
      }
      
      if deckVM.currentIndex >= deckVM.stack.count {
        VStack {
          Button(action: {
            withAnimation {
              deckVM.currentIndex = 0
            }
          }, label: {
            Text("Start Over")
          })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
    }
    .task {
      do {
        try await deckVM.fetchCards()
      } catch {
        print("Error fetching cards: \(error)")
      }
    }
  }
}

struct CardView: View {
  let card: CardModel
  
  var body: some View {
    ZStack {
      card.color
      
      // card chip imitation
      RoundedRectangle(cornerRadius: 5)
        .fill(Color.orange)
        .frame(width: 50, height: 40)
        .position(CGPoint(x: 60.0, y: 90.0))
      
      VStack(alignment: .leading, spacing: 15) {
        
        HStack {
          Spacer()
          
          Text(card.bank)
            .font(.headline)
            .foregroundStyle(.white)
        }
        
        Spacer()
        
        Text("\(card.cardNumber.toCreditCardFormat())")
          .font(.headline)
          .foregroundStyle(.white)
        
        HStack(spacing: 20) {
          HStack {
            Text("CVV/CVV2")
              .font(.caption)
              .foregroundStyle(.white)
            
            Text("\(card.cvv)")
              .font(.headline)
              .foregroundStyle(.white)
          }
          
          HStack {
            Text("Good thru")
              .font(.caption)
              .foregroundStyle(.white)
            
            Text("08/2023")
              .font(.headline)
              .foregroundStyle(.white)
          }
        }
        
        Text(card.owner)
          .textCase(.uppercase)
          .kerning(2)
          .font(.headline)
          .foregroundStyle(.white)
        
      }
      .padding(20)
    }
    .frame(height: 250)
    .frame(maxWidth: 420)
    .clipShape(RoundedRectangle(cornerRadius: 15))
  }
}

extension Int {
  func toCreditCardFormat() -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.positiveFormat = "####,####"
    numberFormatter.negativeFormat = "-####,####"
    numberFormatter.groupingSeparator = " "
    
    if let formattedNumber = numberFormatter.string(from: NSNumber(value: self)) {
      return formattedNumber
    } else {
      return "Error formatting number"
    }
  }
}

struct CardDeckView_Previews: PreviewProvider {
  static var previews: some View {
    CardDeckView()
  }
}
