import SwiftUI

// TEMPORARILY DISABLED - Authentication view commented out for now
// Uncomment when authentication is needed again
/*
struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.Design.largeSpacing) {
                // Header
                VStack(spacing: Constants.Design.spacing) {
                    Image(systemName: "bag.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Constants.Colors.primary)
                    
                    Text(Constants.appName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.label)
                    
                    Text("Buy and sell locally with trust")
                        .font(.subheadline)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Constants.Design.largePadding * 2)
                
                Spacer()
                
                // Authentication Form
                if isSignUp {
                    SignUpView()
                } else {
                    SignInView()
                }
                
                Spacer()
                
                // Toggle between Sign In and Sign Up
                Button(action: {
                    withAnimation(.easeInOut(duration: Constants.Animation.defaultDuration)) {
                        isSignUp.toggle()
                    }
                }) {
                    HStack {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        Text(isSignUp ? "Sign In" : "Sign Up")
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.primary)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, Constants.Design.largePadding)
            }
            .padding(.horizontal, Constants.Design.largePadding)
            .background(Constants.Colors.background)
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK") {
                authViewModel.dismissError()
            }
        } message: {
            Text(authViewModel.errorMessage ?? "An error occurred")
        }
    }
}
*/

#Preview {
    // AuthenticationView()
    //     .environmentObject(AuthViewModel())
    Text("Authentication View - Temporarily Disabled")
}

