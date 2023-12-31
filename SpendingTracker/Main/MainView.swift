//
//  MainView.swift
//  SpendingTracker
//
//  Created by Саид-Насир Исмаилов on 2023/07/20.
//

import SwiftUI



struct MainView: View {
    @State private var shouldPresentAddCardForm = false
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !cards.isEmpty {
                    TabView {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom, 50)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 280)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    //hack
    //                .onAppear {
    //                    shouldPresentAddCardForm.toggle()
    //                }
                } else {
                    emptyPromptMessage
                }
                
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardForm, onDismiss: nil) {
                        AddCardForm()
                    }
            }
            .navigationTitle("Credit Cards")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        addItemButton
                        deleteAllButton
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addCardButton
                }
            }
        }
    }
    
    private var emptyPromptMessage: some View {
        VStack {
            Text("You currently have no cards in the system.")
                .padding(.vertical)
                .multilineTextAlignment(.center)
            Button {
                shouldPresentAddCardForm.toggle()
            } label: {
                Text("+ Add your first card")
                    .foregroundColor(Color(.systemBackground))
            }
            .padding()
            .background(Color(.label))
            .cornerRadius(5)
        }.font(.system(size: 24, weight: .semibold))
    }
    
    struct CreditCardView: View {
        let card: Card
        
        @State private var shouldShowActionSheet = false
        @State private var shouldShowEditForm = false
        
        @State var refreshID = UUID()
        
        private func handleDelete() {
            let viewContext = PersistenceController.shared.container.viewContext
            
            viewContext.delete(card)
            do {
                try viewContext.save()
            } catch {
                print("Failed to save the new data: \(error)")
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("\(card.name ?? "Random Card")")
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                    Button {
                        shouldShowActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .actionSheet(isPresented: $shouldShowActionSheet) {
                        .init(title: Text(self.card.name ?? ""),
                              message: Text("Options"),
                              buttons: [
                                .default(Text("Edit"), action: {
                                    shouldShowEditForm.toggle()
                                }),
                                .destructive(Text("Delete Card"), action: handleDelete),
                                .cancel()
                              ])
                    }
                }
                
                HStack {
                    let imageName = card.type?.lowercased() ?? ""
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                    Spacer()
                    Text("Balance: $5,000")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text("\(card.number ?? "")")
                
                Text("Credit Limit: $\(card.limit)")
                
                HStack { Spacer() }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                
                VStack {
                    if let colorData = card.color,
                       let uiColor = UIColor.color(data: colorData),
                       let actualColor = Color(uiColor){
                        LinearGradient(colors: [
                            actualColor.opacity(0.6), actualColor
                        ], startPoint: .top, endPoint: .bottom)
                    } else {
                        Color.blue
                    }
                }
                
            )
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
            .fullScreenCover(isPresented: $shouldShowEditForm) {
                AddCardForm(card: self.card)
            }
        }
    }
    
    var addCardButton: some View {
        Button {
            // trigger action
            shouldPresentAddCardForm.toggle()
        } label: {
            Text("+ Card")
                .foregroundColor(Color(.systemBackground))
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.label))
                .cornerRadius(5)
        }
    }
    
    var addItemButton: some View {
        Button {
            withAnimation {
                let viewContext = PersistenceController.shared.container.viewContext
                let card = Card(context: viewContext)
                card.timestamp = Date()

                do {
                    try viewContext.save()
                } catch {
//                    let nsError = error as NSError
//                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        } label: {
            Text("Add Item")
        }
    }
    
    var deleteAllButton: some View {
        Button {
            cards.forEach { card in
                viewContext.delete(card)
            }
            
            do {
                try viewContext.save()
            }
            catch {
                
            }
            
        } label: {
            Text("Delete All")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
