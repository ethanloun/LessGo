import SwiftUI

// TEMPORARILY DISABLED - Sign in view commented out for now
// Uncomment when authentication is needed again
/*
struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email
        case password
    }
    
    var body: some View {
        VStack(spacing: Constants.Design.largeSpacing) {
            // Title
            VStack(spacing: Constants.Design.spacing) {
                Text("Welcome Back")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Sign in to your account")
                    .font(.subheadline)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            // Form Fields
            VStack(spacing: Constants.Design.spacing) {
                // Email Field
                VStack(alignment: .leading, spacing: Constants.Design.smallSpacing) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.label)
                    
                    TextField("Enter your email", text: $authViewModel.email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .email)
                        .onSubmit {
                            focusedField = .password
                        }
                    
                    if !authViewModel.email.isEmpty && !authViewModel.isEmailValid {
                        Text("Please enter a valid email address")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.error)
                    }
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: Constants.Design.smallSpacing) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.label)
                    
                    SecureField("Enter your password", text: $authViewModel.password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .onSubmit {
                            Task {
                                await authViewModel.signIn()
                            }
                        }
                    
                    if !authViewModel.password.isEmpty && !authViewModel.isPasswordValid {
                        Text("Password must be at least \(Constants.Validation.passwordMinLength) characters")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.error)
                    }
                }
            }
            
            // Sign In Button
            Button(action: {
                Task {
                    await authViewModel.signIn()
                }
            }) {
                HStack {
                    if authViewModel.isSigningIn {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: Constants.Design.buttonHeight)
                .background(authViewModel.canSignIn ? Constants.Colors.primary : Constants.Colors.primary.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(Constants.Design.cornerRadius)
                .font(.headline)
            }
            .disabled(!authViewModel.canSignIn || authViewModel.isSigningIn)
            
            // Forgot Password
            Button("Forgot Password?") {
                // TODO: Implement forgot password functionality
            }
            .font(.subheadline)
            .foregroundColor(Constants.Colors.primary)
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .onTapGesture {
            focusedField = nil
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(Constants.Design.padding)
            .background(Constants.Colors.secondaryBackground)
            .cornerRadius(Constants.Design.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Design.cornerRadius)
                    .stroke(Constants.Colors.separator, lineWidth: 1)
            )
    }
}
*/

#Preview {
    // SignInView()
    //     .environmentObject(AuthViewModel())
    Text("Sign In View - Temporarily Disabled")
}

