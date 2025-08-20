import SwiftUI

struct HomeSearchBarView: View {
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: Constants.Design.spacing) {
            HStack(spacing: Constants.Design.smallSpacing) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                TextField("Search listings...", text: $searchText)
                    .focused($isFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(Constants.Colors.label)
                    .submitLabel(.search)
                    .onTapGesture {
                        isFocused = true
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        isFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
            }
            .padding(.horizontal, Constants.Design.padding)
            .padding(.vertical, Constants.Design.smallPadding)
            .background(Constants.Colors.sampleCardBackground)
            .cornerRadius(Constants.Design.cornerRadius)
            
            if isFocused {
                Button("Cancel") {
                    searchText = ""
                    isFocused = false
                }
                .foregroundColor(Constants.Colors.label)
                .transition(.move(edge: .trailing))
                .padding()
            }
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .animation(.easeInOut(duration: Constants.Animation.defaultDuration), value: isFocused)
        .onAppear {
            // Ensure the text field can receive focus
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if searchText.isEmpty {
                    isFocused = false
                }
            }
        }
    }
}

#Preview {
    HomeSearchBarView(searchText: .constant(""))
        .padding()
}

