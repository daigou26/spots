//
//  Created on 2022/02/07
//

import SwiftUI

struct UpdateMainImageView: View {
    @EnvironmentObject var spotDetailViewModel: SpotDetailViewModel
    @ObservedObject var imagePickerViewModel = ImagePickerViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var goNext = false
    @State var updating = false
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        Group {
            ZStack(alignment: .center) {
                VStack {
                    if let preview = imagePickerViewModel.selectedImagePreview {
                        Image(uiImage: preview).resizable().scaledToFill().frame(height: width / 1.6).clipped().padding(.bottom, 15)
                    } else if let imageUrl = spotDetailViewModel.spot?.imageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image.resizable()
                                .scaledToFill()
                                .frame(height: width / 1.6)
                                .clipped()
                                .padding(.bottom, 15)
                        } placeholder: {
                            Rectangle().fill(Color.background).frame(height: width / 1.6).padding(.bottom, 15)
                        }
                    } else {
                        Rectangle().fill(Color.background).frame(height: width / 1.6).padding(.bottom, 15)
                    }
                    
                    if imagePickerViewModel.libraryStatus == .Denied {
                        Spacer()
                        Text("写真へのアクセスを許可してください").foregroundColor(.gray)
                        Button(action: {
                            // Go to settings
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }, label: {
                            Text("許可する").foregroundColor(.white).fontWeight(.bold).padding(.vertical, 10).padding(.horizontal).background(Color.main).cornerRadius(10)
                        })
                        Spacer()
                    } else {
                        ScrollView {
                            VStack {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 5) {
                                    ForEach(imagePickerViewModel.photos, id: \.self) { photo in
                                        ThumbnailView(photo: photo).onTapGesture {
                                            imagePickerViewModel.extractPreviewData(asset: photo.asset)
                                        }
                                    }
                                }
                                
                                if imagePickerViewModel.libraryStatus == .Limited {
                                    Text("追加で写真を選択する").foregroundColor(.gray).padding(.top, 20)
                                    Button(action: {
                                        // Go to settings
                                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                                    }, label: {
                                        Text("写真を選択").foregroundColor(.white).fontWeight(.bold).padding(.vertical, 10).padding(.horizontal).background(Color.main).cornerRadius(10)
                                    }).padding(.bottom, 30)
                                }
                            }
                        }
                    }
                }
                if updating {
                    ProgressView().scaleEffect(x: 1.5, y: 1.5, anchor: .center).progressViewStyle(CircularProgressViewStyle(tint: Color.white)).zIndex(1)
                    Rectangle().fill(Color.black).opacity(0.4).edgesIgnoringSafeArea(.all)
                }
            }
        }.navigationBarBackButtonHidden(true).toolbar {
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    imagePickerViewModel.selectedImagePreview = nil
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left").font(.system(size: 16).bold()).foregroundColor(.black)
                }.disabled(updating)
            }
            ToolbarItem(placement: .navigationBarTrailing){
                Button("保存") {
                    Task {
                        updating = true
                        var res = false
                        if let id = spotDetailViewModel.spot?.id, let image = imagePickerViewModel.selectedImagePreview?.jpegData(compressionQuality: 0) {
                            res = await spotDetailViewModel.updateMainImage(spotId: id, image: image)
                        }
                        updating = false
                        if res {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }.disabled(updating)
            }
        }.onAppear {
            if imagePickerViewModel.libraryStatus == .Denied {
                imagePickerViewModel.setUp(Int(width))
            }
        }
    }
}

struct UpdateMainImageView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateMainImageView().environmentObject(SpotDetailViewModel())
    }
}
