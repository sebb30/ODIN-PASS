//
//  deleted content 1.swift
//  ODIN PASS
//
//  Created by Sebastian Buchner on 13/7/2024.
//

import SwiftUI

struct CircularCropView: View {
    @Binding var image: UIImage?

    @State private var dragLocation: CGSize = .zero
    @State private var cropSize: CGFloat = 100 // Adjust crop size as needed
    let outputImageSize: CGFloat = 10 // Adjust output image size as needed

    var body: some View {
        VStack {
            if let image = image {
                GeometryReader { geometry in
                    ZStack {
                        Color.black
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: outputImageSize, height: outputImageSize) // Adjust the frame size of the image
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .offset(dragLocation)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        self.dragLocation = value.translation
                                    }
                                    .onEnded { value in
                                        self.dragLocation.width += value.translation.width
                                        self.dragLocation.height += value.translation.height
                                    }
                            )
                    }
                    .frame(width: cropSize, height: cropSize)
                }
                .frame(maxWidth: .infinity, alignment: .center) // Center the circular image within the available space
            } else {
                Text("No image selected")
            }

            Button("Crop") {
                // Perform cropping action
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}


struct deleted_content_1: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    deleted_content_1()
}
