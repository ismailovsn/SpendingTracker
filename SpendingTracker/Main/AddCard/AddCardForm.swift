//
//  AddCardForm.swift
//  SpendingTracker
//
//  Created by Саид-Насир Исмаилов on 2023/07/27.
//

import SwiftUI

struct AddCardForm: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
        
    var body: some View {
        NavigationView {
            Form {
                Text("Add card form")
                
                TextField("Name", text: $name)
            }
            .navigationTitle("Add Credit Card")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
            }
        }
    }
}

struct AddCardForm_Previews: PreviewProvider {
    static var previews: some View {
        AddCardForm()
    }
}
