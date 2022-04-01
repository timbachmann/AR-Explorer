//
//  DetailView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.03.22.
//

import SwiftUI
import OpenAPIClient

struct DetailView: View {
    
    @State private var detailImage: Image?
    @State private var detailDate: Text?
    @State private var detailSource: Text?
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State var image: ApiImage
    @Binding var images: [ApiImage]
    @Binding var showSelf: Bool
    
    var body: some View {
        VStack {
            detailImage?
                .resizable()
                .scaledToFit()
            Spacer()
            detailDate?
                .fontWeight(Font.Weight.heavy)
            detailSource?
                .fontWeight(Font.Weight.regular)
        }
        .padding()
        .onAppear { loadImage() }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
            showSelf = false
        }){
            HStack {
                Image(systemName: "chevron.backward")
                Text("Back")
            }
        })
    }
}
extension DetailView {
    
    func loadImage(){
        print(image.data)
        if image.data == Data() {
            print(image.data)
            ImageAPI.getImageById(imageId: image.id) { (response, error) in
                guard error == nil else {
                    print(error ?? "Unknown Error")
                    return
                }

                if (response != nil) {
                    var currImage = images.remove(at: images.firstIndex{$0.id == image.id}!)
                    currImage.data = response!.data
                    images.append(currImage)
                    image = currImage
                    setImage()
                    dump(response)
                }
            }
        } else {
            setImage()
        }
    }
    
    func setImage() {
        let uiImage = UIImage(data: image.data)
        detailImage = Image(uiImage: uiImage!)
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let date: Date = formatter.date(from: image.date)!
        formatter.dateFormat = "dd.MM.yyyy - HH:mm:ss"
        
        detailDate = Text(formatter.string(from: date))
        detailSource = Text(image.source)
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
