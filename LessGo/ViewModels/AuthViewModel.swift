import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // Authentication state
    @Published var isSigningUp = false
    @Published var isSigningIn = false
    @Published var isVerifying = false
    
    // Form data
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    @Published var phoneNumber = ""
    
    // Validation
    @Published var isEmailValid = false
    @Published var isPasswordValid = false
    @Published var isDisplayNameValid = false
    @Published var isPhoneValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
        checkAuthenticationState()
    }
    
    private func setupValidation() {
        // Email validation
        $email
            .map { $0.isValidEmail }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellables)
        
        // Password validation
        $password
            .map { $0.isValidPassword }
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellables)
        
        // Display name validation
        $displayName
            .map { $0.count >= Constants.User.minDisplayNameLength && $0.count <= Constants.User.maxDisplayNameLength }
            .assign(to: \.isDisplayNameValid, on: self)
            .store(in: &cancellables)
        
        // Phone validation
        $phoneNumber
            .map { $0.isEmpty || $0.isValidPhone }
            .assign(to: \.isPhoneValid, on: self)
            .store(in: &cancellables)
    }
    
    private func checkAuthenticationState() {
        // TODO: Check if user is already authenticated (e.g., from UserDefaults, Keychain, or Firebase)
        // For now, we'll assume no user is authenticated
        isAuthenticated = false
        currentUser = nil
    }
    
    var canSignUp: Bool {
        return isEmailValid && isPasswordValid && isDisplayNameValid && isPhoneValid && password == confirmPassword
    }
    
    var canSignIn: Bool {
        return isEmailValid && isPasswordValid
    }
    
    func signUp() async {
        guard canSignUp else {
            showError(message: "Please fill in all required fields correctly")
            return
        }
        
        isSigningUp = true
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implement actual sign up logic with Firebase or your backend
            // For now, we'll simulate the process
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Create user
            let user = User(
                id: UUID().uuidString,
                email: email,
                displayName: displayName
            )
            
            // Simulate success
            currentUser = user
            isAuthenticated = true
            
            // Clear form
            clearForm()
            
        } catch {
            showError(message: "Failed to create account: \(error.localizedDescription)")
        }
        
        isSigningUp = false
        isLoading = false
    }
    
    func signIn() async {
        guard canSignIn else {
            showError(message: "Please enter valid email and password")
            return
        }
        
        isSigningIn = true
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implement actual sign in logic with Firebase or your backend
            // For now, we'll simulate the process
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Simulate authentication success
            let user = User(
                id: UUID().uuidString,
                email: email,
                displayName: "Demo User"
            )
            
            currentUser = user
            isAuthenticated = true
            
            // Clear form
            clearForm()
            
        } catch {
            showError(message: "Failed to sign in: \(error.localizedDescription)")
        }
        
        isSigningIn = false
        isLoading = false
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        clearForm()
    }
    
    func verifyEmail() async {
        guard currentUser != nil else { return }
        
        isVerifying = true
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: Implement actual email verification logic
            // For now, we'll simulate the process
            
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Simulate verification success
            currentUser?.isVerified = true
            currentUser?.verificationDate = Date()
            
        } catch {
            showError(message: "Failed to verify email: \(error.localizedDescription)")
        }
        
        isVerifying = false
        isLoading = false
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        phoneNumber = ""
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    func dismissError() {
        showError = false
        errorMessage = nil
    }
}

