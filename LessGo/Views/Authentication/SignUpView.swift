import SwiftUI

// TEMPORARILY DISABLED - Sign up view commented out for now
// Uncomment when authentication is needed again
/*
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case displayName
        case email
        case phone
        case password
        case confirmPassword
    }
    
    var body: some View {
        VStack(spacing: Constants.Design.largeSpacing) {
            // Title
            VStack(spacing: Constants.Design.spacing) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Join LessGo to start buying and selling locally")
                    .font(.subheadline)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            
            // Form Fields
            VStack(spacing: Constants.Design.spacing) {
                // Display Name Field
                VStack(alignment: .leading, spacing: Constants.Design.smallSpacing) {
                    Text("Display Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.label)
                    
                    TextField("Enter your display name", text: $authViewModel.displayName)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.name)
                        .focused($focusedField, equals: .displayName)
                        .onSubmit {
                            focusedField = .email
                        }
                    
                    if !authViewModel.displayName.isEmpty && !authViewModel.isDisplayNameValid {
                        Text("Display name must be \(Constants.User.minDisplayNameLength)-\(Constants.User.maxDisplayNameLength) characters")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.error)
                    }
                }
                
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
                            focusedField = .phone
                        }
                    
                    if !authViewModel.email.isEmpty && !authViewModel.isEmailValid {
                        Text("Please enter a valid email address")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.error)
                    }
                }
                
                // Phone Number Field
                VStack(alignment: .leading, spacing: Constants.Design.smallSpacing) {
                    Text("Phone Number (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.label)
                    
                    TextField("Enter your phone number", text: $authViewModel.phoneNumber)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phone)
                        .onSubmit {
                            focusedField = .password
                        }
                    
                    if !authViewModel.phoneNumber.isEmpty && !authViewModel.isPhoneValid {
                        Text("Please enter a valid phone number")
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
                    
                    SecureField("Create a password", text: $authViewModel.password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .password)
                        .onSubmit {
                            focusedField = .confirmPassword
                        }
                    
                    if !authViewModel.password.isEmpty && !authViewModel.isPasswordValid {
                        Text("Password must be \(Constants.Validation.passwordMinLength)-\(Constants.Validation.passwordMaxLength) characters")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.error)
                    }
                }
                
                // Confirm Password Field
                VStack(alignment: .leading, spacing: Constants.Design.smallSpacing) {
                    Text("Confirm Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.label)
                    
                    SecureField("Confirm your password", text: $authViewModel.confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .confirmPassword)
                        .onSubmit {
                            Task {
                                await authViewModel.signUp()
                            }
                        }
                    
                    if !authViewModel.confirmPassword.isEmpty && authViewModel.password != authViewModel.confirmPassword {
                        Text("Passwords don't match")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.error)
                    }
                }
            }
            
            // Sign Up Button
            Button(action: {
                Task {
                    await authViewModel.signUp()
                }
            }) {
                HStack {
                    if authViewModel.isSigningUp {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Create Account")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: Constants.Design.buttonHeight)
                .background(authViewModel.canSignUp ? Constants.Colors.primary : Constants.Colors.primary.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(Constants.Design.cornerRadius)
                .font(.headline)
            }
            .disabled(!authViewModel.canSignUp || authViewModel.isSigningUp)
            
            // Terms and Privacy
            VStack(spacing: Constants.Design.smallSpacing) {
                Text("By creating an account, you agree to our")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                HStack(spacing: Constants.Design.smallSpacing) {
                    Button("Terms of Service") {
                        // TODO: Show terms of service
                    }
                    .font(.caption)
                    .foregroundColor(Constants.Colors.primary)
                    
                    Text("and")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    Button("Privacy Policy") {
                        // TODO: Show privacy policy
                    }
                    .font(.caption)
                    .foregroundColor(Constants.Colors.primary)
                }
            }
        }
        .padding(.horizontal, Constants.Design.largePadding)
        .onTapGesture {
            focusedField = nil
        }
    }
}
*/

#Preview {
    // SignUpView()
    //     .environmentObject(AuthViewModel())
    Text("Sign Up View - Temporarily Disabled")
}

