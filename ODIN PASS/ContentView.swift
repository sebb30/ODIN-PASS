//
//  full content with image picker.swift
//  ODIN PASS
//
//  Created by Sebastian Buchner on 13/7/2024.
//

import SwiftUI

extension Image {
    func uiImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let renderer = UIGraphicsImageRenderer(size: view!.bounds.size)
        let image = renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
}

struct TopRoundedRectangle: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(tangent1End: topLeft, tangent2End: topRight, radius: radius)
        if corners.contains(.topRight) {
            path.addLine(to: topRight)
        } else {
            path.addArc(tangent1End: topRight, tangent2End: bottomRight, radius: radius)
        }
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.addLine(to: topLeft)
        if corners.contains(.topLeft) {
            path.addLine(to: topLeft)
        } else {
            path.addArc(tangent1End: topLeft, tangent2End: bottomLeft, radius: radius)
        }
        return path
    }
}



struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isShown: Bool

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                parent.image = uiImage
            }
            parent.isShown = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShown = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true // Enable image editing (including cropping)
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
}

class ClockViewModel: ObservableObject {
    @Published var currentTime: String = ""
    @Published var currentDate: String = ""
    @Published var profileImage: UIImage? // Change type to UIImage?
    @Published var userName: String = ""
    @Published var location: String = "" // New location field
    @Published var destination: String = "" // New destination field

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init() {
        updateTime()
        loadProfileImage()
        loadUserName()
        loadLocation()
        loadDestination()
    }

    @objc func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.currentTime = formatter.string(from: Date())

        formatter.dateFormat = "dd MMMM yyyy"
        self.currentDate = formatter.string(from: Date())
    }

    func saveImageToUserDefaults(_ image: UIImage?) {
        guard let imageData = image?.jpegData(compressionQuality: 1) else { return }
        UserDefaults.standard.set(imageData, forKey: "profileImage")
    }

    func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage") {
            self.profileImage = UIImage(data: imageData)
        }
    }

    func saveUserNameToUserDefaults(_ name: String) {
        UserDefaults.standard.set(name, forKey: "userName")
    }

    func loadUserName() {
        if let savedName = UserDefaults.standard.string(forKey: "userName") {
            self.userName = savedName
        }
    }
    
    // Functions to handle location and destination
    func saveLocationToUserDefaults(_ location: String) {
        UserDefaults.standard.set(location, forKey: "location")
    }

    func loadLocation() {
        if let savedLocation = UserDefaults.standard.string(forKey: "location") {
            self.location = savedLocation
        }
    }

    func saveDestinationToUserDefaults(_ destination: String) {
        UserDefaults.standard.set(destination, forKey: "destination")
    }

    func loadDestination() {
        if let savedDestination = UserDefaults.standard.string(forKey: "destination") {
            self.destination = savedDestination
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ClockViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingImagePicker = false
    @State private var isLoading = true // Added state for loading screen

    var body: some View {
        ZStack {
            // Main content
            VStack {
                // Header
                VStack {
                    ZStack {
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 110)
                            .edgesIgnoringSafeArea(.all)
                            .padding(.bottom, 13)
                            .cornerRadius(10)
                        
                        VStack {
                            HStack{
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("Ticket info")
                                    .foregroundColor(.white)
                                Spacer()
                                Spacer()
                                Button("Close") {
                                    // Action to be performed when close button is tapped
                                }
                                .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, -20)
                            HStack {
                                Spacer()
                                Image("logo")
                                    .resizable(resizingMode: .stretch)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 70, height: 70)
                                
                                Spacer()
                                
                                Image("translink")
                                    .resizable(resizingMode: .stretch)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 180, height: 70)
                                    .padding()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, -10) // Add padding to reduce vertical space
                        }
                    }
                }
                
                // Time Display
                VStack {
                    
                    Text(viewModel.currentTime)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, -4)
                    
                    Text(viewModel.currentDate)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.gray)
                        .onReceive(viewModel.timer) { _ in
                            self.viewModel.updateTime()
                        }
                        .padding(.top, -3)
                        .padding(.bottom, 20)
                }
                
                // Divider
                Rectangle()
                    .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.818))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .cornerRadius(3.0)
                    .padding(.top, 3)
                
                // User Profile Section
                HStack {
                    ZStack {
                        if let profileImage = viewModel.profileImage {
                            Image(uiImage: profileImage)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                        } else {
                            Image("profilepic")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                                .foregroundStyle(.black)
                        }
                    }
                    .padding(.vertical, 5.0)
                    .padding(.leading)
                    .onTapGesture {
                        self.isShowingImagePicker.toggle()
                    }
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(image: self.$viewModel.profileImage, isShown: self.$isShowingImagePicker)
                    }
                    .onDisappear {
                        viewModel.saveImageToUserDefaults(viewModel.profileImage)
                    }
                    .onAppear {
                        viewModel.loadProfileImage()
                    }
                    
                    VStack {
                        TextField("Enter your name", text: $viewModel.userName)
                            .onChange(of: viewModel.userName) { oldName, newName in
                                viewModel.saveUserNameToUserDefaults(newName)
                            }
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 20, weight: .bold))
                            .padding(.bottom, -8)
                            .padding(.trailing, 5)
                        
                        HStack {
                            Text("The University of Queensland")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 0)
                                .padding(.bottom, -1)
                            Spacer()
                        }
                        
                        
                        HStack {
                            ZStack {
                                Rectangle()
                                    .fill(Color("AccentColor"))
                                    .frame(height: 20)
                                    .frame(width: 70)
                                    .cornerRadius(10.0)
                                Text("STUDENT")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.white)
                            }
                            Spacer()
                        }
                    }
                }
                
                // Divider
                Rectangle()
                    .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.818))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .cornerRadius(3.0)
                
                // Bus Info
                HStack {
                    Image(systemName: "bus.fill")
                        .resizable()
                        .padding(.leading, 2)
                        .frame(width: 22, height: 19)
                        .aspectRatio(contentMode: .fit)
                        .colorMultiply(colorScheme == .dark ? .white : .black)
                    
                    Text("Bus")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.leading)
                .padding(.bottom, -2)
                .padding(.vertical, 10)
                
                // Divider
                Rectangle()
                    .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.818))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .cornerRadius(3.0)
                
                // Journey Details
                HStack() {
                    VStack(spacing: 0) {
                        Circle()
                            .stroke(lineWidth: 3)
                            .foregroundStyle(.blue)
                            .frame(height: 12)
                            .frame(width: 12)
                        
                        Rectangle()
                            .frame(height: 60)
                            .frame(width: 4)
                            .foregroundStyle(.blue)
                        
                            
                        Circle()
                            .stroke(lineWidth: 3)
                            .foregroundStyle(.blue)
                            .frame(height: 12)
                            .frame(width: 12)
                    }
                    .padding()
                    .padding(.horizontal, 10)
                    
                    
                    VStack {
                        HStack {
                            Text("From")
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                        
                        TextField("Enter location", text: $viewModel.location)
                            .onChange(of: viewModel.location) { oldLocation, newLocation in
                                viewModel.saveLocationToUserDefaults(newLocation)
                            
                            }
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.headline)
                            .padding(.bottom, 5)

                            .padding(.top, -10)
                        
                        HStack {
                            Text("To")
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                        
                        TextField("Enter destination", text: $viewModel.destination)
                            .onChange(of: viewModel.destination) { oldDestination, newDestination in
                                viewModel.saveDestinationToUserDefaults(newDestination)
                            }
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.headline)
                            .padding(.bottom, -2)
                            .padding(.top, -10)
                    }
                    Button {
                        let tempLocation = viewModel.location
                        viewModel.location = viewModel.destination
                        viewModel.destination = tempLocation
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "arrow.triangle.swap")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24) // Adjust the size of the SF Symbol
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .padding(.trailing, 20)
                }
                
                // Divider
                Rectangle()
                    .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.818))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .cornerRadius(3.0)
                
                // Image
                Image("Go card")
                    .resizable(resizingMode: .stretch)
                    .scaledToFit()
                    .frame(width: 320, height: 200) // Adjust width and height as needed
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 8)
                
                Text("Single-use one-way ticket")
                    .fontWeight(.medium)
                    .padding(.bottom, -4)
                    .ignoresSafeArea(.all)
            }
            .opacity(isLoading ? 0 : 1) // Hide content when loading
            
            // Loading screen
            if isLoading {
                ZStack {
                    // Loading screen content
                    
                    ZStack {
                        Image("biglogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 1000, height: 1000)
                            .ignoresSafeArea(.all)
                            .foregroundColor(.accentColor)
                        
                    }
                    
                }
                .opacity(1) // Make loading screen fully visible
              
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeInOut(duration: 0.7)) {
                            self.isLoading = false // Hide loading screen after 2 seconds
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

