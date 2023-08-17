//
//  FormTextFieldView.swift
//  Sibaro
//
//  Created by Soroush Arasteh on 8/14/23.
//

import SwiftUI

struct FormTextFieldView: View {
    
    var title: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.leading, 5)
            TextField(title, text: $value, axis: .vertical)
                .textFieldStyle(.plain)
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .autocorrectionDisabled()
                .padding(.vertical, 10)
                .frame(minHeight: 40, maxHeight: 150, alignment: .top)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                }
        }
    }
}

struct FormTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        FormTextFieldView(title: "Title", value: .constant("Just a placeholder"))
    }
}
